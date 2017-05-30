#===============================================================================
# NAME      : SCOM12_prereqs.ps1
# LANGUAGE  : Windows PowerShell
# AUTHOR    : Bryan Dady
# DATE      : 03/6/2012
# COMMENT   : PowerShell script to check, enable and configure basic System Center 
# 			  Operations Manager 2012 pre-requisites on Windows Server 2008 R2
#===============================================================================
$erroractionpreference = "Continue" # shows error message, but continue
$error.clear()
# DEBUG MODE : $erroractionpreference = "Inquire"; "`$error = $error[0]"
$myName = $MyInvocation.MyCommand.Name

# *** RFE (2012-04-24): Update script launch to check for S: drive and match 
#	expected layout of SystemCenter 2012 folder structures
# 	test-path
#	e.g. prompt for path-string, test-path path-string to match \Prerequisites\NetFx40\dotNetFx40_Full_x86_x64.exe
	AND \SystemCenter2012\Orchestrator\SetupOrchestrator.exe
	net use S: path-string
#	Re-use for all SC 2012 prereq scripts
# ***

#===============================================================================
# Functions need to be pre-defined
function WaitForSetup($setupFilePath,$params) {
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
    { if ($thisOS.version -lt 6.1) {
	    write-warning "System Center 2012 Requires Windows Server 2008 R2 SP1 or newer"
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

# Enable Windows Server Feature pre-requisites 
Write-Host -foregroundcolor "green" "`nEnable Windows Servermanager PowerShell Module, and install SCOM prerequisite features"
Import-Module Servermanager
start-sleep 1
# Display Name                                            Name
# ------------                                            ----
#[X] Web Server (IIS)                                    Web-Server             
#    [X] Web Server                                      Web-WebServer          
#        [X] Common HTTP Features                        Web-Common-Http        
#            [X] Static Content                          Web-Static-Content     
#            [X] Default Document                        Web-Default-Doc        
#            [X] Directory Browsing                      Web-Dir-Browsing       
#            [X] HTTP Errors                             Web-Http-Errors        
#        [X] Application Development                     Web-App-Dev            
#            [X] ASP.NET                                 Web-Asp-Net            
#        [X] Health and Diagnostics                      Web-Health             
#            [X] HTTP Logging                            Web-Http-Logging       
#            [X] Request Monitor                         Web-Request-Monitor    
#        [X] Security                                    Web-Security           
#            [X] Windows Authentication                  Web-Windows-Auth       
#            [X] Request Filtering                       Web-Filtering          
#        [X] Performance                                 Web-Performance        
#            [X] Static Content Compression              Web-Stat-Compression   
#    [X] Management Tools                                Web-Mgmt-Tools         
#        [X] IIS Management Console                      Web-Mgmt-Console       
#        [X] IIS Management Scripts and Tools            Web-Scripting-Tools    
#        [ ] Management Service                          Web-Mgmt-Service       
#        [ ] IIS 6 Management Compatibility              Web-Mgmt-Compat        
#            [X] IIS 6 Metabase Compatibility            Web-Metabase           
#
# [X] .NET Framework 3.5.1 Features                       NET-Framework
#     [X] .NET Framework 3.5.1                            NET-Framework-Core
# Create array of all pre-requisite features
$features =@("NET-Framework-Core", "Web-Server", "Web-WebServer", "Web-Common-Http", "Web-Static-Content", "Web-Default-Doc", "Web-Dir-Browsing", "Web-Http-Errors", "Web-App-Dev", "Web-Asp-Net", "Web-Health", "Web-Http-Logging", "Web-Request-Monitor", "Web-Security", "Web-Windows-Auth", "Web-Filtering", "Web-Performance", "Web-Stat-Compression", "Web-Mgmt-Tools", "Web-Mgmt-Console", "Web-Scripting-Tools", "Web-Mgmt-Service", "Web-Mgmt-Compat", "Web-Metabase");

#Add-WindowsFeature [-Name] <string[]> [-IncludeAllSubFeature] [-logPath <string>] [-WhatIf] [-Restart] [-Concurrent] [<CommonParameters>]
foreach ($item in $features) {
	Add-WindowsFeature -Name $item -logPath Add-WindowsFeature_$item.log -Concurrent
}

# Install .Net Framework 4
if (test-path S:\Prerequisites\NetFx40\dotNetFx40_Full_x86_x64.exe) {
	Write-Host -foregroundcolor "green" "`nSetup Microsoft .NET Framework 4 Extended"
	S:\Prerequisites\NetFx40\dotNetFx40_Full_x86_x64.exe /passive | out-null
} else {
    write-warning "Unable to locate .NET Framework 4 setup at S:\Prerequisites\NetFx40\"; 
    break;
}

# Configure IIS ISAPI & CGI restriction exceptions
Write-Host -foregroundcolor "green" "`nConfigure IIS ISAPI & CGI restriction exceptions"
Import-Module webadministration  
   
$isapiPath = "$env:windir\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll"
$isapiConfiguration = get-webconfiguration "/system.webServer/security/isapiCgiRestriction/add[@path='$isapiPath']/@allowed"  

if (!$isapiConfiguration.value){  
   set-webconfiguration "/system.webServer/security/isapiCgiRestriction/add[@path='$isapiPath']/@allowed" -value "True" -PSPath:IIS:\  
   Write-Host "Enabled ISAPI - $isapiPath " -ForegroundColor Green  
}  

# Import-Module WebAdministration
# add-pssnapin WebAdministration
# set-webconfiguration "/system.webServer/security/isapiCgiRestriction/add[@path=$env:windir\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll]/@allowed" -value "True" -PSPath:IIS:\  

# (Re) register IIS with ASP.Net, just in case
Write-Host -foregroundcolor "green" "`n(Re) register IIS with ASP.Net"
& $env:windir\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe -r | out-null

# Setup SQL Server 2008
# Adjust Drive Letter for ISO path as necessary
$sqlDrive = "D:"
$configFile = 'SQL_OperationsManager.txt'

if (test-path $sqlDrive\Setup.exe) {
    Write-Host -foregroundcolor "green" "`nSetup SQL Server 2008, using $configFile"
    & $sqlDrive\Setup.exe /ConfigurationFile=$configFile | out-null
} else {
    write-warning "Unable to locate SQL setup at $sqlDrive\Setup.exe. Double check the ISO is mounted, and try again."; 
    break;
}

# Setup SQL Server Report Viewer
# Adjust path as necessary
Write-Host -foregroundcolor "green" "`nSetup Report Viewer"
S:\Prereqs\ReportViewer\ReportViewer.exe /q /l ReportViewer.log | out-null; # -- /passive option was not working: 

Write-Host -foregroundcolor "green" "`nThis server is now ready to proceed with SCOM server setup"

#===============================================================================
$now = get-date -format g
"`n$now # Exiting $myName"