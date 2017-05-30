strPath = Left(WScript.ScriptFullName,InStrRev(WScript.ScriptFullName,"\"))
Set wshShell = WScript.CreateObject ("WSCript.shell")
cmdline1 = "reg.exe" & " " & "ADD" & " " & "HKLM\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" & " " & "/f" & " " & "/v" & " " & "ExecutionPolicy" & " " & "/t" & " " & "REG_SZ" & " " & "/d" & " " & "Unrestricted"
wshshell.run cmdline1
Set wshshell = nothing

Set wshShell = WScript.CreateObject ("WSCript.shell")
cmdline1 = "powershell.exe" & " " & ".\SC2012_hydration_downloads.ps1"
wshshell.run cmdline1
Set wshshell = nothing
