# ⚙️ 빠른 설정 가이드 (Quick Start)

## 5분 내 시작하기

### 1️⃣ 파일 배치

프로젝트 폴더 구조:
```
Wlsakr/
├── asd.html                    ← 메인 페이지 (웹사이트)
├── ass.css                     ← 스타일시트
├── submission_logger.bat       ← Windows BAT 파일
├── submission_logger_vbs.vbs   ← VBScript 파일
├── submission_logger.ps1       ← PowerShell 스크립트
├── SECURITY_GUIDE.md           ← 상세 기술 문서
├── README.md                   ← 개요 문서
└── 이미지 파일들...
```

### 2️⃣ 웹사이트 실행

**옵션 A: 로컬 서버 (권장)**
```bash
# Python 설치된 경우
python -m http.server 8000

# 또는 Node.js
npx http-server

# 브라우저: http://localhost:8000/Wlsakr/asd.html
```

**옵션 B: 직접 열기**
```
Wlsakr/asd.html → 마우스 우클릭 → 브라우저로 열기
```

### 3️⃣ Google Apps Script 연동 (선택사항)

1. Google Drive 접속: https://drive.google.com
2. 새 스프레드시트 생성
3. 도구 → 스크립트 편집기
4. 다음 코드 붙여넣기:

```javascript
function doPost(e) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Sheet1');
  const data = JSON.parse(e.postData.contents);
  
  // 헤더 추가 (첫 실행만)
  if (sheet.getLastRow() === 0) {
    sheet.appendRow(['이름', '팀명', '직무', '이메일', '휴대폰', '지원동기', 'Device ID', '제출시간']);
  }
  
  // 이메일 중복 검사
  const range = sheet.getRange('D:D');
  const emails = range.getValues();
  for (let i = 1; i < emails.length; i++) {
    if (emails[i][0] === data.email) {
      return ContentService.createTextOutput(
        JSON.stringify({ status: 'duplicate', message: '이미 제출된 이메일입니다.' })
      ).setMimeType(ContentService.MimeType.JSON);
    }
  }
  
  // 새 데이터 추가
  sheet.appendRow([data.applicant, data.team, data.role, data.email, data.phoneNumber, data.reason, data.deviceId, data.submittedAt]);
  
  return ContentService.createTextOutput(
    JSON.stringify({ status: 'success', message: '제출되었습니다.' })
  ).setMimeType(ContentService.MimeType.JSON);
}
```

5. 배포 → 새 배포 → 웹 앱
6. 실행자: 자신의 계정
7. 액세스: 누구나
8. **배포 URL 복사**
9. `asd.html`에서 `SCRIPT_URL` 수정:

```javascript
const SCRIPT_URL = "여기에 배포 URL 붙여넣기";
```

### 4️⃣ 테스트

1. 웹사이트 접속: http://localhost:8000/Wlsakr/asd.html
2. F12 → Console 열기 (개발자 도구)
3. 지원 폼 작성 후 제출
4. 콘솔에서 로그 확인 (색상있는 메시지)
5. 다시 페이지 로드 → "이미 제출됨" 메시지 확인

---

## 🔍 확인 방법

### 제출이 제대로 기록되었는지 확인

#### 방법 1: 브라우저 콘솔 (F12)
```javascript
// 콘솔에서 실행
localStorage.getItem('applicationSubmitted_v4')  // 'true' 나와야 함
JSON.parse(localStorage.getItem('applicationLog_v4'))  // 제출 정보 표시
```

#### 방법 2: Windows 레지스트리
```
1. Win + R
2. regedit.exe 입력
3. HKEY_CURRENT_USER\Software\ApplicationSubmission 이동
4. LastSubmittedEmail 등의 값 확인
```

#### 방법 3: 로컬 파일
```
1. Win + R
2. %APPDATA%\ApplicationLogs 입력
3. submission_log.txt 파일 확인
```

#### 방법 4: Google Sheets
```
Google Drive → 스프레드시트 오픈
새로운 행이 추가되었는지 확인
```

---

## ⚠️ 문제 해결

| 증상 | 원인 | 해결책 |
|------|------|--------|
| BAT 파일이 안 다운로드됨 | 브라우저 설정 | 다운로드 폴더 권한 확인 |
| 레지스트리에 기록 안 됨 | 관리자 권한 없음 | PowerShell을 관리자로 실행 |
| Google Apps Script 연동 안 됨 | URL 오류 | SCRIPT_URL 다시 확인 및 수정 |
| 페이지 새로고침 후 제출 가능 | 브라우저 캐시 | F5 대신 Ctrl+Shift+R로 하드 새로고침 |
| "Already submitted" 메시지 자꾸만 나옴 | 저장소 문제 | 개발자도구 → 저장소 → 모두 삭제 |

---

## 🎯 권장 사항

### 1. 보안
- ✅ HTTPS 사용 (배포 시)
- ✅ CORS 설정 (다른 도메인 접근 제한)
- ✅ 정기적인 로그 검토

### 2. 성능
- ✅ CDN 활용 (이미지 파일)
- ✅ 캐싱 전략 수립
- ✅ IndexedDB 정기 정리

### 3. 사용자 경험
- ✅ 명확한 오류 메시지
- ✅ 진행 상황 표시
- ✅ 모바일 반응형 디자인 확인

---

## 📱 모바일 지원

### 현재 상태
- ✅ 반응형 디자인 (Bootstrap 5)
- ✅ 터치 친화적 UI
- ❌ 모바일에서 BAT 파일 실행 불가능 (Windows만 지원)

### 모바일 최적화 권장사항
```javascript
// User-Agent 감지
if (/mobile|android|iphone/i.test(navigator.userAgent)) {
  // 모바일 특화 기능
  // BAT 실행 대신 대체 메서드 사용
}
```

---

## 🔐 재배포 체크리스트

배포 전 확인 사항:

- [ ] Google Apps Script 배포 URL 수정됨
- [ ] HTTPS 인증서 설정됨
- [ ] 로그 폴더 권한 설정 확인됨
- [ ] 이메일 템플릿 준비됨
- [ ] 지원 폼 필드 검증됨
- [ ] 콘솔 로그 정리됨
- [ ] 테스트 사용자 정보 삭제됨
- [ ] 백업 파일 생성됨

---

## 📞 추가 도움말

- **기술 상세**: `SECURITY_GUIDE.md` 참고
- **프로젝트 개요**: `README.md` 참고
- **개발자 도구**: F12 → Console 탭에서 로그 확인
- **레지스트리 편집**: 주의! 실수하면 시스템 오류 가능

---

**🎉 모든 준비가 완료되었습니다!**

이제 웹사이트를 배포하고 지원자들이 중복으로 신청하지 못하도록 보호되었습니다.
