// Google Apps Script - 중복 지원 감지 및 차단 시스템
// 스프레드시트 설정:
// - "관리" 시트: 중복된 이메일/휴대폰 기록
// - "지원서" 시트: 모든 지원서 기록

const SPREADSHEET_ID = "YOUR_SPREADSHEET_ID"; // 구글 시트 ID로 변경 필요
const SHEET_NAME_SUBMISSIONS = "지원서";
const SHEET_NAME_BLACKLIST = "블랙리스트";
const SHEET_NAME_LOGS = "로그";

// 중복 검사 함수
function checkDuplicateSubmission(email, phoneNumber) {
  try {
    const sheet = SpreadsheetApp.openById(SPREADSHEET_ID).getSheetByName(SHEET_NAME_SUBMISSIONS);
    const data = sheet.getDataRange().getValues();
    
    // 헤더 제외
    for (let i = 1; i < data.length; i++) {
      const row = data[i];
      const existingEmail = row[3]; // 이메일 컬럼 (인덱스 3)
      const existingPhone = row[4]; // 휴대폰 컬럼 (인덱스 4)
      
      // 이메일 또는 휴대폰이 중복되면 true 반환
      if (existingEmail === email || existingPhone === phoneNumber) {
        return {
          isDuplicate: true,
          reason: existingEmail === email ? "이메일" : "휴대폰 번호",
          previousSubmissionDate: row[0] // 이전 제출 날짜
        };
      }
    }
    
    return { isDuplicate: false };
  } catch (error) {
    Logger.log("중복 검사 오류: " + error);
    return { isDuplicate: false, error: error.toString() };
  }
}

// 로그 기록 함수
function logSubmission(email, phoneNumber, formData, isDuplicate = false) {
  try {
    const sheet = SpreadsheetApp.openById(SPREADSHEET_ID).getSheetByName(SHEET_NAME_LOGS);
    const timestamp = new Date().toLocaleString('ko-KR');
    
    sheet.appendRow([
      timestamp,
      email,
      phoneNumber,
      formData.applicant || "",
      formData.team || "",
      isDuplicate ? "❌ 중복 시도" : "✅ 정상",
      JSON.stringify(formData)
    ]);
  } catch (error) {
    Logger.log("로그 기록 오류: " + error);
  }
}

// 블랙리스트에 추가
function addToBlacklist(email, phoneNumber, reason) {
  try {
    const sheet = SpreadsheetApp.openById(SPREADSHEET_ID).getSheetByName(SHEET_NAME_BLACKLIST);
    const timestamp = new Date().toLocaleString('ko-KR');
    
    sheet.appendRow([
      timestamp,
      email,
      phoneNumber,
      reason,
      "차단됨"
    ]);
  } catch (error) {
    Logger.log("블랙리스트 추가 오류: " + error);
  }
}

// 메인 처리 함수
function doPost(e) {
  try {
    // POST 요청에서 데이터 추출
    const data = JSON.parse(e.postData.contents);
    const email = data.email.trim().toLowerCase();
    const phoneNumber = data.phoneNumber.trim();
    
    // 중복 검사
    const duplicateCheck = checkDuplicateSubmission(email, phoneNumber);
    
    if (duplicateCheck.isDuplicate) {
      // 중복 시도 로그
      logSubmission(email, phoneNumber, data, true);
      addToBlacklist(email, phoneNumber, `중복 지원 시도 (${duplicateCheck.reason})`);
      
      return ContentService.createTextOutput(JSON.stringify({
        success: false,
        message: `❌ 이미 지원하셨습니다!\\n이전 지원: ${duplicateCheck.previousSubmissionDate}\\n중복된 항목: ${duplicateCheck.reason}`,
        isDuplicate: true,
        error: "DUPLICATE_SUBMISSION"
      })).setMimeType(ContentService.MimeType.JSON);
    }
    
    // 중복이 아니면 정상 저장
    const sheet = SpreadsheetApp.openById(SPREADSHEET_ID).getSheetByName(SHEET_NAME_SUBMISSIONS);
    const timestamp = new Date().toLocaleString('ko-KR');
    
    sheet.appendRow([
      timestamp,
      data.applicant,
      data.team,
      email,
      phoneNumber,
      data.role,
      data.reason,
      data.userAgent || "",
      data.deviceId || ""
    ]);
    
    // 정상 제출 로그
    logSubmission(email, phoneNumber, data, false);
    
    return ContentService.createTextOutput(JSON.stringify({
      success: true,
      message: "✅ 지원서가 정상적으로 제출되었습니다!",
      isDuplicate: false
    })).setMimeType(ContentService.MimeType.JSON);
    
  } catch (error) {
    Logger.log("오류 발생: " + error);
    return ContentService.createTextOutput(JSON.stringify({
      success: false,
      message: "서버 오류가 발생했습니다.",
      error: error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

// 스프레드시트 초기화 (처음 한 번만 실행)
function initializeSpreadsheet() {
  const spreadsheet = SpreadsheetApp.openById(SPREADSHEET_ID);
  
  // 지원서 시트 생성
  try {
    let sheet = spreadsheet.getSheetByName(SHEET_NAME_SUBMISSIONS);
  } catch {
    sheet = spreadsheet.insertSheet(SHEET_NAME_SUBMISSIONS);
    sheet.appendRow(["제출 시간", "이름", "팀명", "이메일", "휴대폰", "지원 분야", "지원 동기", "User Agent", "Device ID"]);
  }
  
  // 블랙리스트 시트 생성
  try {
    let sheet = spreadsheet.getSheetByName(SHEET_NAME_BLACKLIST);
  } catch {
    sheet = spreadsheet.insertSheet(SHEET_NAME_BLACKLIST);
    sheet.appendRow(["기록 시간", "이메일", "휴대폰", "사유", "상태"]);
  }
  
  // 로그 시트 생성
  try {
    let sheet = spreadsheet.getSheetByName(SHEET_NAME_LOGS);
  } catch {
    sheet = spreadsheet.insertSheet(SHEET_NAME_LOGS);
    sheet.appendRow(["시간", "이메일", "휴대폰", "이름", "팀명", "결과", "상세 데이터"]);
  }
}
