# ============================================================
# PowerShell Script: 중복 지원 방지 시스템 (다층 기록)
# ============================================================
# 사용법: powershell -ExecutionPolicy Bypass -File submission_logger.ps1 "email@example.com" "010-1234-5678" "John Doe"
# ============================================================

param(
    [string]$Email = "test@example.com",
    [string]$Phone = "010-0000-0000",
    [string]$Name = "Test User"
)

# ============================================================
# 설정
# ============================================================
$AppDataPath = $env:APPDATA
$LogDir = "$AppDataPath\ApplicationLogs"
$LogFile = "$LogDir\submission_log.txt"
$RegistryPath = "HKCU:\Software\ApplicationSubmission"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# ============================================================
# 1. 디렉토리 생성
# ============================================================
if (-Not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# ============================================================
# 2. HWID 추출
# ============================================================
try {
    $HWID = (Get-WmiObject Win32_ComputerSystemProduct).IdentifyingNumber
} catch {
    $HWID = "Unknown"
}

# ============================================================
# 3. Windows 레지스트리에 기록
# ============================================================
if (-Not (Test-Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
}

# 레지스트리 값 설정
Set-ItemProperty -Path $RegistryPath -Name "LastSubmittedEmail" -Value $Email -Force
Set-ItemProperty -Path $RegistryPath -Name "LastSubmittedPhone" -Value $Phone -Force
Set-ItemProperty -Path $RegistryPath -Name "LastSubmittedName" -Value $Name -Force
Set-ItemProperty -Path $RegistryPath -Name "LastSubmittedTime" -Value $Timestamp -Force
Set-ItemProperty -Path $RegistryPath -Name "HWID" -Value $HWID -Force
Set-ItemProperty -Path $RegistryPath -Name "PowerShellExecutedTime" -Value $Timestamp -Force
Set-ItemProperty -Path $RegistryPath -Name "SubmitCount" -Value 1 -Type DWord -Force

# ============================================================
# 4. 로컬 파일에 기록
# ============================================================
$LogContent = @"
============================================================
지원서 제출 기록
============================================================
제출 시간: $Timestamp
이메일: $Email
휴대폰: $Phone
이름: $Name
컴퓨터명: $env:COMPUTERNAME
사용자명: $env:USERNAME
하드웨어ID: $HWID
실행 방식: PowerShell (고급 보안)
============================================================

"@

Add-Content -Path $LogFile -Value $LogContent -Encoding UTF8

# ============================================================
# 5. JSON 형식의 메타데이터 저장
# ============================================================
$JsonPath = "$LogDir\submission_metadata.json"
$Metadata = @{
    email = $Email
    phone = $Phone
    name = $Name
    timestamp = $Timestamp
    hwid = $HWID
    computername = $env:COMPUTERNAME
    username = $env:USERNAME
    scriptVersion = "1.0"
    executedBy = "PowerShell"
} | ConvertTo-Json

Add-Content -Path $JsonPath -Value $Metadata -Encoding UTF8

# ============================================================
# 6. 시스템 이벤트 로그에 기록 (선택사항)
# ============================================================
try {
    # 이 섹션은 관리자 권한 필요
    # Write-EventLog -LogName Application -Source Application -EventId 1001 -EntryType Information -Message "Application Submitted: $Email"
} catch {
    # 권한 없음 - 무시
}

# ============================================================
# 7. 완료 메시지
# ============================================================
Write-Host "제출 기록이 다음 위치에 저장되었습니다:" -ForegroundColor Green
Write-Host "  - 로그 파일: $LogFile" -ForegroundColor Cyan
Write-Host "  - JSON 메타: $JsonPath" -ForegroundColor Cyan
Write-Host "  - 레지스트리: $RegistryPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "이메일: $Email" -ForegroundColor Yellow
Write-Host "휴대폰: $Phone" -ForegroundColor Yellow
Write-Host "이름: $Name" -ForegroundColor Yellow
Write-Host ""
Write-Host "✅ 제출 기록이 안전하게 보관되었습니다." -ForegroundColor Green

# 5초 후 자동 종료
Start-Sleep -Seconds 5
