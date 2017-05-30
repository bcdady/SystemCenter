#===============================================================================
# NAME      : DPM_prereqs_WS12.ps1
# LANGUAGE  : Windows PowerShell
# AUTHOR    : Bryan Dady
# DATE      : 09/07/2012
# COMMENT   : PowerShell script to check, enable and configure basic System Center 
# 			  Data Protection Manager 2012 pre-requisites on Windows Server 2012
#===============================================================================
$erroractionpreference = "Continue" # shows error message, but continue
$error.clear()
# DEBUG MODE : $erroractionpreference = "Inquire"; "`$error = $error[0]"
$myPath = $MyInvocation.MyCommand.Path
$myName = $MyInvocation.MyCommand.Name

#===============================================================================
function checkProcess([string]$processName) {
    #Write-Output checkProcess"($processName,$mode)"
    write-host -foregroundcolor "green" "`nWaiting for Windows Installer to complete ..."
    #start-sleep 10
#    $processName = "msiexec.exe"
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
        write-warning " ... "
        # check again
        $process = Get-Process $processName -ErrorAction SilentlyContinue #| out-null
    }
    write-progress -activity "Waiting for $processName" -status "." -Completed #-percentcomplete (100)
}

#===============================================================================
$now = get-date -format g
"$now # Starting $myName"

#===============================================================================
# Confirm WIndows Server OS 
Write-Host "`nChecking for Server OS and Version";
$thisOS = Get-WmiObject -Class Win32_OperatingSystem -namespace “root\cimv2” -computer . 
# $thisOS.OSArchitecture : 64-bit
# $thisOS.Caption -match "Microsoft Windows Server 2008 R2"
switch ($thisOS.Caption) 
{ 
    {$_ -match "Windows Server" }
    { if ($thisOS.version -lt 6.0) {
	    write-warning "Caution: This script has not been tested on this server operating system:"
	    write-host -ForegroundColor Yellow `t $thisOS.Caption.trim() '(' $thisOS.version '),' $thisOS.OSArchitecture;
	  } else {
		write-host Verified $thisOS.Caption.trim(), $thisOS.OSArchitecture
        break;
      }
    } 
    default { write-warning Unsupported Operating System: $thisOS.Caption
    	break;
    }
}
#===============================================================================
# Enable Windows Server Feature pre-requisites 
Write-Host -foregroundcolor "green" "`nEnable Windows Servermanager PowerShell module, and install prerequisite features"
Import-Module Servermanager
start-sleep 1
# Display Name                                            Name
# ------------                                            ----
# [ ] Web Server (IIS)                                    Web-Server
#     [ ] Web Server                                      Web-WebServer
#         [ ] Common HTTP Features                        Web-Common-Http
#             [X] Static Content                          Web-Static-Content
#             [X] Default Document                        Web-Default-Doc
#             [X] Directory Browsing                      Web-Dir-Browsing
#             [X] HTTP Errors                             Web-Http-Errors
#             [ ] HTTP Redirection                        Web-Http-Redirect
#         [X] Application Development                     Web-App-Dev
#             [X] ASP.NET                                 Web-Asp-Net
#             [X] .NET Extensibility                      Web-Net-Ext
#             [X] ISAPI Extensions                        Web-ISAPI-Ext
#             [X] ISAPI Filters                           Web-ISAPI-Filter
#         [ ] Security                                    Web-Security
#             [ ] Windows Authentication                  Web-Windows-Auth
#             [X] Request Filtering                       Web-Filtering
#     [ ] Management Tools                                Web-Mgmt-Tools
#         [ ] IIS Management Console                      Web-Mgmt-Console
#         [ ] IIS Management Scripts and Tools            Web-Scripting-Tools
#         [ ] Management Service                          Web-Mgmt-Service
#         [ ] IIS 6 Management Compatibility              Web-Mgmt-Compat
#             [X] IIS 6 Metabase Compatibility            Web-Metabase
#             [X] IIS 6 WMI Compatibility                 Web-WMI

# [X] .NET Framework 3.5.1 Features                       NET-Framework
#     [X] .NET Framework 3.5.1                            NET-Framework-Core
# Create array of all pre-requisite features

$features =@("Web-Net-Ext", "Web-App-Dev", "Web-Asp-Net", "Web-Default-Doc", "Web-Dir-Browsing", "Web-Http-Errors", "Web-Mgmt-Tools", "Web-Metabase", "Web-WMI", "Web-ISAPI-Ext", "Web-ISAPI-Filter", "Web-Filtering", "Web-Static-Content", "NET-Framework-Core");

#Add-WindowsFeature [-Name] <string[]> [-IncludeAllSubFeature] [-logPath <string>] [-WhatIf] [-Restart] [-Concurrent] [<CommonParameters>]
#foreach ($item in $features) {
#	Add-WindowsFeature -Name $item -logPath Add-WindowsFeature_$item.log; # -Concurrent
#}

#===============================================================================
# build an absolute path to the MSI installer
$installRoot = split-path $MyPath;
$installRoot = split-path $installRoot -parent; #$installRoot = split-path $installRoot -parent #chop the path twice
$pathToSetup = join-path $installRoot "Prerequisites\Win8 ADK\adksetup.exe"; # set this to a fully qualified path if the MSI is not in the same directory as this script
if (test-path $pathToSetup) {
	write-host "`nInstalling MSI package $pathToSetup (Windows Assessment and Deployment Kit)";
	& $pathToSetup /features OptionId.DeploymentTools OptionId.VolumeActivationManagementTool OptionId.WindowsPerformanceToolkit /quiet | out-null
} else {
	write-warning Unable to locate MSI package to setup VMM pre-requisite Windows Automated Installation Kit 
	echo $pathToSetup; #DEBUG
    break;
}

#===============================================================================
$pathToMSI = join-path $installRoot "Prerequisites\SQL Server 2012\sqlncli.msi"; # set this to a fully qualified path if the MSI is not in the same directory as this script
if (test-path $pathToMSI) {
    write-host "`nInstalling MSI package $pathToMSI (Microsoft SQL Server 2008 R2 Native Client)";
    & $env:SystemRoot\system32\msiexec.exe /package $pathToMSI IACCEPTSQLNCLILICENSETERMS=YES /passive | out-null
} else {
    write-warning Unable to locate MSI package to setup VMM pre-requisite Microsoft SQL Server 2008 R2 Native Client 
    break;
}

#===============================================================================
$pathToMSI = join-path $installRoot "Prerequisites\SQL Server 2012\SqlCmdLnUtils.msi"; # set this to a fully qualified path if the MSI is not in the same directory as this script
if (test-path $pathToMSI) {
    write-host "`nInstalling MSI package $pathToMSI (Microsoft SQL Server 2008 R2 Command Line Utilities)";
    & $env:SystemRoot\system32\msiexec.exe /package $pathToMSI /passive | out-null
} else {
    write-warning Unable to locate MSI package to setup VMM pre-requisite Microsoft SQL Server 2008 R2 Command Line Utilities 
    break;
}
#call checkProcess function for each MSI
#checkProcess msiexec.exe; #

#===============================================================================
# Setup SQL Server :: Uncomment this section IF SQL is needed locally
# Adjust Drive Letter for ISO path as necesarry
#$sqlDrive = "D:"
#$configFile = 'SQL_DB_VirtualMachineManager.txt'
#
#if (test-path $sqlDrive\Setup.exe) {
#    Write-Host -foregroundcolor "green" "`nSetup SQL Server 2008, using $configFile"
#    & $sqlDrive\Setup.exe /ConfigurationFile=$configFile | out-null
#} else {
#    write-warning "Unable to locate SQL setup at $sqlDrive\Setup.exe. If you intend to install SQL Server locally, double-check that the correct ISO is mounted, and try again."; 
#    break;
#}

#===============================================================================
Write-Host -foregroundcolor "green" "`nThis server is now ready to proceed with VMM server setup"

$pathToSetup = join-path $installRoot "SystemCenter2012\VirtualMachineManager\setup.exe"; # set this to a fully qualified path if the MSI is not in the same directory as this script
if (test-path $pathToSetup) {
    write-host "`nInstalling Virtual Machine Manager $pathToSetup";
    & $pathToSetup /server /prep /i /f .\amd64\Setup\VMServer.ini | out-null

} else {
    write-warning Unable to locate VMM setup files
    break;
}
# call checkProcess function for each MSI


#===============================================================================
$now = get-date -format g
"`n$now # Exiting $myName"