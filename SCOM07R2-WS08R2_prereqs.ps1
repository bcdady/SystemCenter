#===============================================================================
# NAME      : SCOM07R2-WS08R2_prereqs.ps1
# LANGUAGE  : Windows PowerShell
# AUTHOR    : Bryan Dady
# DATE      : 01/16/2012
# COMMENT   : PowerShell script to check, enable and configure basic System Center 
# 			  Operations Manager 2007 R2 pre-requisites on Windows Server 2008 R2
#===============================================================================
$erroractionpreference = "Continue" # shows error message, but continue
$error.clear()
# DEBUG MODE : $erroractionpreference = "Inquire"; "`$error = $error[0]"
$myName = $MyInvocation.MyCommand.Name

#===============================================================================
$now = get-date -format g
"$now # Starting $myName"

#===============================================================================
# Confirm WIndows Server OS 
Write-Host "`nChecking for Server OS and Version";
$thisOS = Get-WmiObject -Class Win32_OperatingSystem -namespace “root\cimv2” -computer . 
# $thisOS.OSArchitecture : 64-bit
# $thisOS.Caption -match "Microsoft Windows Server 2008 R2"
# switch ($thisOS.Caption) 
# { 
#     {$_ -match "Windows Server" }
#     { if ($thisOS.version -lt 6.0) {
# 	    write-warning "Caution: This script has not been tested on this server operating system:"
# 	    write-host -ForegroundColor Yellow `t $thisOS.Caption.trim() '(' $thisOS.version '),' $thisOS.OSArchitecture;
# 	  } else {
# 		write-host Verified $thisOS.Caption.trim(), $thisOS.OSArchitecture
#         break;
#       }
#     } 
#     default { write-warning Unsupported Operating System: $thisOS.Caption
#     	break;
#     }
# }
# Enable Windows Server Feature pre-requisites 
Write-Host -foregroundcolor "green" "`nEnable Windows Servermanager PowerShell Module, and install SCOM prerequisite features"
Import-Module Servermanager
start-sleep 1
# Display Name                                            Name
# ------------                                            ----
# [ ] Web Server (IIS)                                    Web-Server
#     [ ] Web Server                                      Web-WebServer
#         [ ] Common HTTP Features                        Web-Common-Http
#             [ ] Static Content                          Web-Static-Content
#             [ ] Default Document                        Web-Default-Doc
#             [ ] Directory Browsing                      Web-Dir-Browsing
#             [ ] HTTP Errors                             Web-Http-Errors
#             [ ] HTTP Redirection                        Web-Http-Redirect
#         [ ] Application Development                     Web-App-Dev
#             [ ] ASP.NET                                 Web-Asp-Net
#             [ ] .NET Extensibility                      Web-Net-Ext
#             [ ] ISAPI Extensions                        Web-ISAPI-Ext
#             [ ] ISAPI Filters                           Web-ISAPI-Filter
#         [ ] Security                                    Web-Security
#             [ ] Windows Authentication                  Web-Windows-Auth
#             [ ] Request Filtering                       Web-Filtering
#     [ ] Management Tools                                Web-Mgmt-Tools
#         [ ] IIS Management Console                      Web-Mgmt-Console
#         [ ] IIS Management Scripts and Tools            Web-Scripting-Tools
#         [ ] Management Service                          Web-Mgmt-Service
#         [ ] IIS 6 Management Compatibility              Web-Mgmt-Compat
#             [ ] IIS 6 Metabase Compatibility            Web-Metabase
#             [ ] IIS 6 WMI Compatibility                 Web-WMI

# [X] .NET Framework 3.5.1 Features                       NET-Framework
#     [X] .NET Framework 3.5.1                            NET-Framework-Core
# Create array of all pre-requisite features
$features =@("Web-Static-Content", "Web-Default-Doc", "Web-Dir-Browsing", "Web-Http-Errors", "Web-Http-Redirect", "Web-Asp-Net", "Web-Net-Ext", "Web-ISAPI-Ext", "Web-ISAPI-Filter", "Web-Windows-Auth", "Web-Filtering", "Web-Mgmt-Console", "Web-Scripting-Tools", "Web-Mgmt-Service", "Web-Metabase", "Web-WMI", "NET-Framework-Core");

#Add-WindowsFeature [-Name] <string[]> [-IncludeAllSubFeature] [-logPath <string>] [-WhatIf] [-Restart] [-Concurrent] [<CommonParameters>]
foreach ($item in $features) {
	Add-WindowsFeature -Name $item -logPath Add-WindowsFeature_$item.log -Concurrent
}

# Install ASP.NET Ajax Extensions 1.0 for ASP.NET 2.0 from http://go.microsoft.com/fwlink/?LinkID=89064&clcid=0x409
$pathToMSI =  resolve-path .\ASPAJAXExtSetup.msi; # set this to a fully qualified path if the MSI is not in the same directory as this script
if (test-path $pathToMSI) {
	write-host "`nInstalling MSI package $pathToMSI";
	& $env:SystemRoot\system32\msiexec.exe /package $pathToMSI /passive
} else {
	write-warning Unable to locate MSI package to setup SCOM pre-requisite ASP.NET Ajax Extensions 1.0 for ASP.NET 2.0 
	break;
}

write-host -foregroundcolor "green" "`nWaiting for Windows Installer to complete ..."
start-sleep 10
$processName = "msiexec.exe"
$process = Get-Process -name $processName -ErrorAction SilentlyContinue # | out-null
while ($process) {
    # it appears to be running; let's wait for it
    $counter = 0; # we always start from zero
    $waitTime = 5 # Define how many seconds we want to wait per loop
    while ($counter -lt $waitTime) {
        write-progress -activity "Waiting for Windows Installer" -status "ctrl-c to break the loop" -percentcomplete ($counter/$waitTime*100)
        Start-Sleep -Seconds 1;
        $counter++;
    }
    write-warning "still waiting for Windows Installer"
    # check again
    $process = Get-Process $processName -ErrorAction SilentlyContinue #| out-null
}
write-progress -activity "Waiting for $processName" -status "." -Completed #-percentcomplete (100)

Write-Host -foregroundcolor "green" "`nThis server is now ready to proceed with SQL and/or SCOM server setup"

#===============================================================================
$now = get-date -format g
"`n$now # Exiting $myName"