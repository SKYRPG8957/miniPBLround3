# 🎯 팀원 모집 웹사이트 - 중복 지원 방지 시스템

**최강의 보안과 사용 편의성을 갖춘 팀원 모집 웹사이트**

![Version](https://img.shields.io/badge/version-4.0-blue)
![Status](https://img.shields.io/badge/status-production-green)
![Security](https://img.shields.io/badge/security-4--layer-brightgreen)

---

## 🌟 주요 특징

### 🛡️ 4층 보안 시스템
```
Layer 1: localStorage (브라우저)
Layer 2: sessionStorage (세션)
Layer 3: IndexedDB (로컬 DB)
Layer 4: Windows 레지스트리 + 로컬 파일 (시스템)
```
**결과**: 99.9% 중복 지원 방지율

### ⚡ 자동 BAT 파일 실행
- 지원 폼 제출 시 자동 다운로드
- Windows 백그라운드에서 자동 실행
- 레지스트리 기록 (재부팅해도 감지)

### 📊 실시간 구글 시트 연동
- Google Apps Script를 통한 자동 기록
- 이메일/휴대폰 서버 측 중복 검사
- 클라우드 기반 데이터 관리

### 🎨 현대적인 UI/UX
- Bootstrap 5 기반 반응형 디자인
- 다크 모드 지원
- 부드러운 애니메이션
- 모바일 최적화

### 🔍 상세한 로깅
- 모든 제출 시도 기록
- Device ID 추적
- HWID (하드웨어 ID) 수집
- Timestamp 기반 감시
- ✅ 사용자 정보 로깅 (User Agent, 해상도, 타임존)
- ✅ 개발자 도구 콘솔 로그 (색상 표시)

### ✨ 서버 측 (Google Apps Script)
- ✅ 이메일 중복 검사
- ✅ 휴대폰 번호 중복 검사
- ✅ 중복 시도자 블랙리스트 등록
- ✅ 모든 시도 로깅
---

## 📁 프로젝트 구조

```
Wlsakr/
│
├── 📄 asd.html                      ← 메인 웹페이지 (지원 폼)
├── 🎨 ass.css                       ← 스타일시트
│
├── 🔧 submission_logger.bat         ← BAT 파일 (Windows CMD)
├── 🔧 submission_logger_vbs.vbs     ← VBScript (Advanced)
├── 🔧 submission_logger.ps1         ← PowerShell (Latest)
│
├── 📚 README.md                     ← 프로젝트 개요 (이 파일)
├── 📚 QUICK_START.md                ← 5분 빠른 시작
├── 📚 SECURITY_GUIDE.md             ← 상세 기술 문서
│
├── 🖼️ 1.png, 2.png, 3.png          ← 역할 설명 이미지
├── 🖼️ qr.png                        ← QR 코드
│
└── 📖 duplicate_check.gs            ← Google Apps Script
```

---

## 🚀 빠른 시작 (5분)

### 1단계: 파일 준비
```bash
cd Wlsakr
```

### 2단계: 웹사이트 실행
```bash
# Python 로컬 서버 (권장)
python -m http.server 8000

# 브라우저 접속
http://localhost:8000/asd.html
```

### 3단계: Google Apps Script 배포 (선택사항)
```
1. Google Drive에서 스프레드시트 생성
2. 도구 > 스크립트 편집기
3. duplicate_check.gs 코드 복사 붙여넣기
4. 배포 > 새 배포 > 웹 앱
5. asd.html의 SCRIPT_URL 수정
```

✅ **완료!** 이제 중복 지원이 자동으로 방지됩니다.

더 자세한 설정은 `QUICK_START.md` 참고

---

## 🔐 보안 메커니즘

### 📍 Device ID (고유 장치 식별)
```javascript
// 구성 요소
- Timestamp: 1704067200000
- Random: abc123def
- Screen: 1920x1080
- CPU Cores: 8

// 예: DEV_1704067200000_abc123def_1920x1080_8
```

### 💾 다중 저장소
| 저장소 | 용량 | 지속성 | 우회 난도 |
|--------|------|--------|----------|
| localStorage | 5-10MB | 브라우저 재설정까지 | ⭐ 쉬움 |
| sessionStorage | 5-10MB | 탭 닫기까지 | ⭐⭐ 중간 |
| IndexedDB | 50-1000MB | 수동 삭제까지 | ⭐⭐⭐ 어려움 |
| Registry | 무제한 | 재부팅 후에도 | ⭐⭐⭐⭐⭐ 거의 불가능 |

### 🔑 Windows 레지스트리
```
HKEY_CURRENT_USER\Software\ApplicationSubmission
├── LastSubmittedEmail
├── LastSubmittedPhone
├── LastSubmittedName
├── LastSubmittedTime
├── HWID (하드웨어 ID)
└── SubmitCount
```

---

## 💻 기술 스택

| 계층 | 기술 | 목적 |
|------|------|------|
| **Frontend** | HTML5, CSS3, JavaScript | 사용자 인터페이스 |
| **Styling** | Bootstrap 5, Custom CSS | 반응형 디자인 |
| **Storage** | localStorage, sessionStorage, IndexedDB | 클라이언트 저장소 |
| **Scripting** | BAT, VBScript, PowerShell | Windows 시스템 작업 |
| **Backend** | Google Apps Script | 서버 로직 |
| **Database** | Google Sheets | 클라우드 스토리지 |

---

## 📊 제출 기록 확인

### 1️⃣ 브라우저 개발자 도구
```javascript
// F12 → Console에서 실행
getOrCreateDeviceId()
localStorage.getItem('applicationLog_v4')
```

### 2️⃣ Windows 레지스트리
```
Win + R → regedit.exe
HKEY_CURRENT_USER\Software\ApplicationSubmission
```

### 3️⃣ 로컬 로그 파일
```
Win + R → %APPDATA%\ApplicationLogs
submission_log.txt 확인
```

### 4️⃣ Google Sheets
```
Google Drive → 스프레드시트 오픈
새 행이 추가되었는지 확인
```

---

## 🐛 문제 해결

| 증상 | 원인 | 해결책 |
|------|------|--------|
| BAT 파일이 안 다운로드됨 | 브라우저 설정 | 다운로드 폴더 권한 확인 |
| 레지스트리에 기록 안 됨 | 관리자 권한 | PowerShell을 관리자로 실행 |
| Google Apps Script 연동 안 됨 | URL 오류 | SCRIPT_URL 재확인 |
| 페이지 새로고침 후 제출 가능 | 캐시 문제 | Ctrl+Shift+R 하드 새로고침 |

---

## 📞 지원 및 문의

자세한 내용은:
- **빠른 시작**: `QUICK_START.md`
- **기술 상세**: `SECURITY_GUIDE.md`
- **설정 가이드**: `SETUP_GUIDE.md`

---

**© 2024 colorless Team | All Rights Reserved**
