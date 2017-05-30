#===============================================================================
# NAME      : SC2012_Svc_Accounts.ps1
# LANGUAGE  : Windows PowerShell
# AUTHOR    : Bryan Dady
# DATE      : 08/23/2012
# COMMENT   : PowerShell script to create new Managed Service Accounts for System Center
#           : Developed and tested on a Windows Server 2012 Domain Controller
#===============================================================================
$erroractionpreference = "Continue" # shows error message, but continue
$error.clear()
# DEBUG MODE : $erroractionpreference = "Inquire"; "`$error = $error[0]"
$myName = $MyInvocation.MyCommand.Name

#===============================================================================
$now = get-date -format g
"$now # Starting $myName"

#===============================================================================
# Setup domain info; details that will be consistent for each call to New-ADUser
$dnPath = "CN=Users,DC=demo,DC=strat,DC=is"; #"CN=Managed Service Accounts,DC=demo,DC=strat,DC=is"
$accountType = "user";
$dcServer = Get-ADDomainController
#===============================================================================
# Optional parameter
# $dcServer = "localhost"; # "WIN-4Q9J89K1EI0.demo.strat.is" 
#===============================================================================

# Start doing some work

# New Service Account(s) for VMM
#New-ADUser -DisplayName:"SC-VMM Service" -Name:"SC-VMM Service" -SamAccountName:"svcSCVMM" -GivenName:"SC-VMM" -Surname:"Service" -Type:"$accountType" -UserPrincipalName:"svcSCVMM@demo.strat.is" -Path:"$dnPath" 
Set-ADAccountPassword -Identity svcSCVMM -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "wertT%4321" -Force)

# New Service Account(s) for Orchestrator
New-ADUser -DisplayName:"SC-O Service" -Name:"SC-Orch Service" -SamAccountName:"svcSCO" -GivenName:"SC-Orch" -Surname:"Service" -Type:"$accountType" -UserPrincipalName:"svcSCO@demo.strat.is" -Path:"$dnPath"
Set-ADAccountPassword -Identity svcSCO -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "wertT%4321" -Force)

# New Service Account(s) for DPM
New-ADUser -DisplayName:"SC-DPM Service" -Name:"SC-DPM Service" -SamAccountName:"svcSCDPM" -GivenName:"SC-DPM" -Surname:"Service" -Type:"$accountType" -UserPrincipalName:"svcSCDPM@demo.strat.is" -Path:"$dnPath"
Set-ADAccountPassword -Identity svcSCDPM -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "wertT%4321" -Force)

# New Service Account(s) for Service Manager
New-ADUser -DisplayName:"SC-SM Service" -Name:"SC-SM Service" -SamAccountName:"svcSCSM" -GivenName:"SC-SM" -Surname:"Service" -Type:"$accountType" -UserPrincipalName:"svcSCSM@demo.strat.is" -Path:"$dnPath"
Set-ADAccountPassword -Identity svcSCSM -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "wertT%4321" -Force)

#===============================================================================
$now = get-date -format g
"`n$now # Exiting $myName"
