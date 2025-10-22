@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ================================================================
REM 지원서 중복 방지 시스템 - Windows 레지스트리 기록
REM ================================================================

set "REGISTRY_PATH=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "APP_NAME=ApplicationSubmissionLog"
set "LOG_FILE=%APPDATA%\ApplicationLogs\submission_log.txt"
set "LOG_DIR=%APPDATA%\ApplicationLogs"

REM 로그 디렉토리 생성
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM 입력값 처리 (배치 파일에 전달된 매개변수)
REM 사용: call_bat.bat "email@example.com" "010-1234-5678" "이름"
set "email=%~1"
set "phone=%~2"
set "name=%~3"
set "timestamp=%date:~0,4%-%date:~5,2%-%date:~8,2% %time:~0,2%:%time:~5,2%:%time:~8,2%"

REM ================================================================
REM 1. 레지스트리에 제출 기록 저장
REM ================================================================

REM 레지스트리 키 생성
reg add "HKCU\Software\ApplicationSubmission" /v "LastSubmittedEmail" /d "%email%" /f >nul 2>&1
reg add "HKCU\Software\ApplicationSubmission" /v "LastSubmittedPhone" /d "%phone%" /f >nul 2>&1
reg add "HKCU\Software\ApplicationSubmission" /v "LastSubmittedName" /d "%name%" /f >nul 2>&1
reg add "HKCU\Software\ApplicationSubmission" /v "LastSubmittedTime" /d "%timestamp%" /f >nul 2>&1
reg add "HKCU\Software\ApplicationSubmission" /v "SubmissionCount" /d "1" /f >nul 2>&1

REM ================================================================
REM 2. 로컬 파일에 기록 저장
REM ================================================================

(
    echo ============================================================
    echo 지원서 제출 기록
    echo ============================================================
    echo 제출 시간: %timestamp%
    echo 이메일: %email%
    echo 휴대폰: %phone%
    echo 이름: %name%
    echo 컴퓨터명: %COMPUTERNAME%
    echo 사용자명: %USERNAME%
    echo ============================================================
    echo.
) >> "%LOG_FILE%"

REM ================================================================
REM 3. 시스템 이벤트 로그에 기록 (관리자 권한 필요)
REM ================================================================

REM 이벤트 소스 생성 (첫 실행 시)
reg query "HKLM\SYSTEM\CurrentControlSet\Services\Eventlog\Application\ApplicationSubmission" >nul 2>&1
if errorlevel 1 (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eventlog\Application\ApplicationSubmission" /f >nul 2>&1
)

REM ================================================================
REM 4. 자동 실행 프로그램으로 등록 (선택사항)
REM ================================================================

REM 이 BAT 파일 자체를 시작 프로그램으로 등록
REM reg add "%REGISTRY_PATH%" /v "%APP_NAME%" /d "cmd /c %~f0" /f >nul 2>&1

REM ================================================================
REM 5. 중복 제출 감지
REM ================================================================

REM 레지스트리에서 이전 제출 정보 읽기
for /f "tokens=3" %%a in ('reg query "HKCU\Software\ApplicationSubmission" /v "LastSubmittedEmail" 2^>nul') do set "prev_email=%%a"

if "%prev_email%"=="%email%" (
    REM 중복 감지
    echo [경고] 중복 제출 감지: %email% >> "%LOG_FILE%"
    echo 시간: %timestamp% >> "%LOG_FILE%"
    exit /b 1
) else (
    REM 정상 제출
    echo [정상] 새로운 제출 기록됨 >> "%LOG_FILE%"
    exit /b 0
)

endlocal
