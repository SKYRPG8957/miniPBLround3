' ============================================================
' VBScript: 중복 지원 방지 시스템 (Windows 레지스트리 기록)
' ============================================================
' 사용법: cscript submission_logger_vbs.vbs "email@example.com" "010-1234-5678" "John Doe"
' ============================================================

Option Explicit
On Error Resume Next

Dim shell, fso, email, phone, name, appDataPath, logDir, logFile
Dim objRegistry, regPath, hwid, objWMI, colItems, objItem

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' 명령줄 인수 처리
If WScript.Arguments.Count >= 3 Then
    email = WScript.Arguments(0)
    phone = WScript.Arguments(1)
    name = WScript.Arguments(2)
Else
    ' 테스트용 기본값
    email = "test@example.com"
    phone = "010-0000-0000"
    name = "Test User"
End If

' 경로 설정
appDataPath = shell.SpecialFolders("AppData")
logDir = appDataPath & "\ApplicationLogs"
logFile = logDir & "\submission_log.txt"

' 디렉토리 생성
If Not fso.FolderExists(logDir) Then
    fso.CreateFolder(logDir)
End If

' ============================================================
' HWID 추출 (WMI 이용)
' ============================================================
hwid = ""
On Error Resume Next
Set objWMI = GetObject("winmgmts:")
Set colItems = objWMI.ExecQuery("Select * from Win32_ComputerSystemProduct")
For Each objItem in colItems
    hwid = objItem.IdentifyingNumber
Next
On Error GoTo 0

' ============================================================
' Windows 레지스트리에 기록
' ============================================================
regPath = "HKEY_CURRENT_USER\Software\ApplicationSubmission\"

' 레지스트리 키 생성 및 값 저장
shell.RegWrite regPath & "LastSubmittedEmail", email, "REG_SZ"
shell.RegWrite regPath & "LastSubmittedPhone", phone, "REG_SZ"
shell.RegWrite regPath & "LastSubmittedName", name, "REG_SZ"
shell.RegWrite regPath & "LastSubmittedTime", Now(), "REG_SZ"
shell.RegWrite regPath & "HWID", hwid, "REG_SZ"
shell.RegWrite regPath & "VBSExecutedTime", Now(), "REG_SZ"

' ============================================================
' 로컬 파일에 기록
' ============================================================
Dim logStream, timestamp, computerName, userName

timestamp = FormatDateTime(Now(), vbGeneralDate)
computerName = shell.ExpandEnvironmentStrings("%COMPUTERNAME%")
userName = shell.ExpandEnvironmentStrings("%USERNAME%")

Set logStream = fso.OpenTextFile(logFile, 8, True) ' 8 = ForAppending, True = Create if not exists
logStream.WriteLine "============================================================"
logStream.WriteLine "지원서 제출 기록"
logStream.WriteLine "============================================================"
logStream.WriteLine "제출 시간: " & timestamp
logStream.WriteLine "이메일: " & email
logStream.WriteLine "휴대폰: " & phone
logStream.WriteLine "이름: " & name
logStream.WriteLine "컴퓨터명: " & computerName
logStream.WriteLine "사용자명: " & userName
logStream.WriteLine "하드웨어ID: " & hwid
logStream.WriteLine "실행 방식: VBScript (보안 강화)"
logStream.WriteLine "============================================================"
logStream.WriteLine ""
logStream.Close()

' ============================================================
' 완료 메시지 (숨은 상태)
' ============================================================
' 메시지 창 표시 (필요시 주석 제거)
' shell.Popup "제출 기록이 저장되었습니다." & vbCrLf & vbCrLf & "이메일: " & email, 0, "제출 완료", 64

' ============================================================
' 스크립트 종료
' ============================================================
WScript.Quit(0)
