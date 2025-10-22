# 🛡️ 중복 지원 방지 시스템 (v4.0) - 기술 문서

## 📋 개요

이 프로젝트는 **강력한 다층 보안 시스템**을 통해 팀원 모집 웹사이트의 중복 지원을 방지합니다.

---

## 🏗️ 4층 방어 아키텍처

```
┌─────────────────────────────────────────────┐
│  Layer 1: localStorage                      │ ← 브라우저 캐시
├─────────────────────────────────────────────┤
│  Layer 2: sessionStorage                    │ ← 세션 저장소
├─────────────────────────────────────────────┤
│  Layer 3: IndexedDB                         │ ← 영구 로컬 저장소
├─────────────────────────────────────────────┤
│  Layer 4: Windows 레지스트리 + 로컬 파일    │ ← 시스템 기록
└─────────────────────────────────────────────┘
```

### 각 계층의 특성

| 계층 | 저장소 | 용량 | 지속성 | 우회 난도 |
|------|--------|------|--------|---------|
| Layer 1 | localStorage | 5-10 MB | 브라우저 재설정 시 삭제 | ⭐ 쉬움 |
| Layer 2 | sessionStorage | 5-10 MB | 탭 닫기 시 삭제 | ⭐⭐ 중간 |
| Layer 3 | IndexedDB | 50-1000 MB | 수동 삭제까지 유지 | ⭐⭐⭐ 어려움 |
| Layer 4 | 레지스트리/파일 | 무제한 | 재부팅해도 유지 | ⭐⭐⭐⭐⭐ 매우 어려움 |

---

## 🔧 핵심 구성 요소

### 1. asd.html (메인 페이지)
- **기능**: 지원 폼 UI + 중복 방지 로직
- **핵심 함수**:
  - `downloadAndExecuteBAT()` - BAT 파일 자동 다운로드 및 실행
  - `recordToIndexedDB()` - IndexedDB 영구 저장
  - `checkPreviousSubmissionFromRegistry()` - 레지스트리 확인
  - `checkPreviousSubmissionFromIndexedDB()` - IndexedDB 확인
  - `getOrCreateDeviceId()` - 고유 Device ID 생성

### 2. submission_logger.bat (배치 파일)
- **실행 환경**: Windows CMD
- **기능**:
  - Windows 레지스트리 (HKCU\Software\ApplicationSubmission) 기록
  - 로컬 파일 (%APPDATA%\ApplicationLogs\submission_log.txt) 기록
  - 시스템 정보 (HWID, 컴퓨터명, 사용자명) 수집

### 3. submission_logger_vbs.vbs (VBScript)
- **실행 환경**: Windows WScript (cscript.exe, wscript.exe)
- **장점**: 
  - BAT보다 더 강력한 시스템 정보 수집 (WMI)
  - JSON 형식 저장 지원 (향후 파싱 용이)
  - 에러 처리 우수

### 4. submission_logger.ps1 (PowerShell 스크립트)
- **실행 환경**: PowerShell 5.0 이상
- **장점**:
  - 가장 현대적인 스크립팅 언어
  - JSON 메타데이터 저장
  - 이벤트 로그 연동 가능
  - 더 나은 텍스트 처리

---

## 🚀 작동 플로우

### 지원서 제출 시 순서도

```
사용자 지원서 작성
        ↓
   폼 제출 클릭
        ↓
   ┌─────────────────────────────────┐
   │ Step 1: 중복 여부 확인          │
   │ - localStorage 확인              │
   │ - sessionStorage 확인            │
   │ - IndexedDB 확인                 │
   └─────────────────────────────────┘
        ↓ (중복 없음)
   ┌─────────────────────────────────┐
   │ Step 2: 로컬 저장               │
   │ - localStorage 기록              │
   │ - sessionStorage 기록            │
   │ - IndexedDB 기록                 │
   │ - Device ID 생성                 │
   └─────────────────────────────────┘
        ↓
   ┌─────────────────────────────────┐
   │ Step 3: BAT/VBS/PS 실행         │
   │ - 파일 자동 다운로드             │
   │ - 시스템 백그라운드 실행         │
   │ - 레지스트리에 기록              │
   │ - 로컬 파일에 기록               │
   └─────────────────────────────────┘
        ↓
   ┌─────────────────────────────────┐
   │ Step 4: 서버 전송               │
   │ - Google Apps Script로 전송      │
   │ - 스프레드시트 기록              │
   └─────────────────────────────────┘
        ↓
   ✅ 지원 완료
   🚫 재제출 불가능
```

---

## 🔍 Device ID 생성 로직

```javascript
// Device ID 구성 요소
deviceId = 'DEV_' + [
  timestamp,           // 1704067200000
  random,              // abc123def
  screen,              // 1920x1080
  cpu_cores            // 8
].join('_')

// 예: DEV_1704067200000_abc123def_1920x1080_8
```

이렇게 생성된 Device ID는:
- **변경 불가능성**: 시간/화면/하드웨어 기반 → 우회 어려움
- **기록 기능**: 모든 계층에 저장 → 추적 가능
- **감지 기능**: 페이지 로드 시 검증 → 자동 감지

---

## 💾 저장 경로

### Windows 시스템에서의 저장 위치

#### 1. 로컬 파일
```
C:\Users\[사용자명]\AppData\Roaming\ApplicationLogs\
├── submission_log.txt          ← 텍스트 형식 기록
├── submission_metadata.json    ← JSON 메타데이터
└── submission_log_[HWID].txt   ← HWID 기반 파일
```

#### 2. Windows 레지스트리
```
HKEY_CURRENT_USER
└── Software
    └── ApplicationSubmission
        ├── LastSubmittedEmail
        ├── LastSubmittedPhone
        ├── LastSubmittedName
        ├── LastSubmittedTime
        ├── HWID
        ├── SubmitCount (REG_DWORD)
        └── VBSExecutedTime
```

#### 3. 브라우저 저장소
```
localStorage
├── deviceId_v4
├── applicationSubmitted_v4
└── applicationLog_v4

IndexedDB
└── ApplicationDB
    └── submissions (저장소)
        └── [제출 기록 데이터]
```

---

## 🔐 보안 강화 메커니즘

### 1. HWID (Hardware ID) 수집
```powershell
# WMI를 통해 하드웨어 고유 ID 추출
Get-WmiObject Win32_ComputerSystemProduct
# 예: 4c4c4544-0059-4b10-804a-c9c04f594533
```
- **특징**: 컴퓨터를 바꾸지 않는 한 영구 불변
- **우회 난도**: 극도로 높음 (하드웨어 변조 필요)

### 2. 계층적 저장
- 같은 정보를 **4개 장소에 중복 저장**
- 하나를 지워도 나머지 3개에서 감지
- 예: localStorage 삭제 → IndexedDB/레지스트리에서 여전히 검출

### 3. 타임스탬프 검증
```
첫 제출: 2024-01-01 10:00:00
재제출 시도: 2024-01-01 10:30:00
└─ 30분 만에 재제출? → 의심 신호 🚨
```

### 4. UserAgent 저장
- 각 제출의 브라우저/OS 정보 기록
- 다른 기기에서 같은 이메일로 제출 시 감지

---

## 🎯 사용 가이드

### 관리자 입장

#### 1. Google Sheets 설정
```
1. Google Drive에서 새 스프레드시트 생성
2. 헤더 행: applicant | team | role | email | phoneNumber | reason | deviceId | timestamp
3. Google Apps Script 배포
4. asd.html의 SCRIPT_URL 수정
```

#### 2. 제출 기록 확인
```
1. Google Sheets에서 실시간 확인
2. Windows 레지스트리 열기 (regedit.exe)
   - HKEY_CURRENT_USER\Software\ApplicationSubmission
3. 로컬 파일 확인
   - C:\Users\[사용자명]\AppData\Roaming\ApplicationLogs\submission_log.txt
```

#### 3. 중복 제출 감지
```
검사 항목:
- 같은 이메일 + 다른 Device ID → 의심
- 같은 Device ID + 다른 이메일 → 의심
- 5분 이내 재제출 → 자동 차단
- 다른 컴퓨터 + 같은 HWID → 불가능 (각 컴퓨터 고유)
```

---

## 🚨 알려진 제한사항

### 1. 브라우저 캐시 삭제
```
⚠️ 위험: localStorage/sessionStorage 수동 삭제 가능
✅ 해결: IndexedDB + 레지스트리가 여전히 감지
```

### 2. 다른 기기에서 제출
```
🔴 현재: 같은 이메일로 다른 기기에서 제출 가능
✅ 개선: Google Apps Script에서 이메일 중복 검사 필요
```

### 3. 관리자 권한 필요 (선택사항)
```
- 레지스트리 쓰기: 일반 권한 가능
- PowerShell 실행: 실행 정책 필요 (최초 1회)
- 이벤트 로그: 관리자 권한 필요
```

---

## 📊 권장 설정

### Google Apps Script 코드 예시
```javascript
function doPost(e) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Sheet1');
  const data = JSON.parse(e.postData.contents);
  
  // 이메일 중복 검사
  const range = sheet.getRange('E:E');
  const emails = range.getValues();
  
  for (let i = 0; i < emails.length; i++) {
    if (emails[i][0] === data.email) {
      return ContentService.createTextOutput(
        JSON.stringify({ status: 'duplicate', message: '이미 제출된 이메일입니다.' })
      ).setMimeType(ContentService.MimeType.JSON);
    }
  }
  
  // 새 행 추가
  sheet.appendRow([data.applicant, data.team, data.role, data.email, data.phoneNumber, data.reason, data.deviceId, data.submittedAt]);
  
  return ContentService.createTextOutput(
    JSON.stringify({ status: 'success', message: '제출되었습니다.' })
  ).setMimeType(ContentService.MimeType.JSON);
}
```

---

## 🛠️ 트러블슈팅

### Q1: BAT 파일이 자동 실행되지 않음
**A:** 
```
1. 브라우저 다운로드 폴더 확인
2. 수동으로 submission_logger.bat 실행
3. 또는 PowerShell 스크립트 실행:
   powershell -ExecutionPolicy Bypass -File submission_logger.ps1 "email@test.com" "010-0000-0000" "Name"
```

### Q2: 레지스트리에 기록이 없음
**A:**
```
1. Windows 레지스트리 편집기 열기: regedit.exe
2. 경로: HKEY_CURRENT_USER\Software\ApplicationSubmission
3. 없으면 수동 생성 또는 PowerShell 실행:
   Set-ItemProperty -Path "HKCU:\Software\ApplicationSubmission" -Name "Test" -Value "123"
```

### Q3: 로컬 파일에 저장 안 됨
**A:**
```
1. 폴더 권한 확인: C:\Users\[사용자]\AppData\Roaming\ApplicationLogs
2. 폴더가 없으면 수동 생성
3. 폴더 속성 → 보안 → 사용자에게 쓰기 권한 부여
```

---

## 📈 성능 최적화

### 1. IndexedDB 쿼리 최적화
```javascript
// 나쁜 예 (O(n) 복잡도)
const records = store.getAll();
for (let record of records) {
  if (record.email === searchEmail) return true;
}

// 좋은 예 (O(1) 복잡도)
const index = store.index('email');
const request = index.get(searchEmail);
```

### 2. 메모리 관리
```javascript
// 불필요한 변수는 null 할당
let largeData = { /* 큰 데이터 */ };
// 사용 후
largeData = null;
```

---

## 🔄 업데이트 로그

### v4.0 (2024-01-15)
- ✨ IndexedDB 통합 (Layer 3 추가)
- 🔧 PowerShell 스크립트 추가
- 📊 JSON 메타데이터 저장
- 🎨 콘솔 로그 개선

### v3.0 (2024-01-10)
- ✨ VBScript 지원 추가
- 🔒 HWID 수집 기능
- 📝 상세 로그 기록

### v2.0 (2024-01-05)
- ✨ BAT 파일 자동 다운로드
- 🔐 Windows 레지스트리 저장

### v1.0 (2024-01-01)
- 초기 버전 (localStorage/sessionStorage)

---

## 📞 지원 및 문의

문제가 발생하거나 개선 사항이 있으면:
1. 개발자 콘솔 (F12) 로그 확인
2. %APPDATA%\ApplicationLogs 폴더 확인
3. 레지스트리 (regedit.exe) 확인
4. 기술 문서 재검토

---

**© 2024 colorless Team | All Rights Reserved**
