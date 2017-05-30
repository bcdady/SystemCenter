#===============================================================================
# NAME      : SQL2012_Setup.ps1
# LANGUAGE  : Windows PowerShell
# AUTHOR    : Bryan Dady
# DATE      : 02/16/2002
# COMMENT   : PowerShell script to install SQL 2012 using a config file
#===============================================================================
$erroractionpreference = "Continue" # shows error message, but continue
$error.clear()
# DEBUG MODE : $erroractionpreference = "Inquire"; "`$error = $error[0]"
$myPath = $MyInvocation.MyCommand.Path
$myName = $MyInvocation.MyCommand.Name

#===============================================================================
#  Last Modified - 08/28/2012
#  $version=1.1
#  History: 1.0 Script created from template
#           1.1 Script translated from cmd/bat to PowerShell
#
#===============================================================================
$now = get-date -format g
"$now # Starting $myName"

# Expect configuration file passed as first argument to this cmd script

# Install SQL Server 2012 from the Command Prompt.
# http://msdn.microsoft.com/en-us/library/ms144259.aspx

# Build an absolute path to the working directory
$installRoot = split-path $MyPath;
$installRoot = split-path $installRoot -parent; #$installRoot = split-path $installRoot -parent #chop the path twice

# Check the args; see if we can find the file
# Setup SQL Server 2012
$pathToSetup = join-path $installRoot "SQL Server 2012\SQLFULL_x64_ENU\Setup.exe"; # set this to a fully qualified path if the setup is not in the same directory as this script

if (test-path $args) {
    $configFile = $args

    if (test-path $pathToSetup) {
        Write-Host -foregroundcolor "green" "`nSetup SQL Server 2012, using $configFile"
        & $pathToSetup /IACCEPTSQLSERVERLICENSETERMS /ConfigurationFile=$configFile | out-null
    } else {
        write-warning "Unable to locate SQL setup at $pathToSetup. If you intend to install SQL Server locally, double-check the path to the setup, and try again."; 
        break;
    }
} else {
    write-warning Unable to locate SQL Config File at '$args'
    break;
}

    

#===============================================================================
$now = get-date -format g
"`n$now # Exiting $myName"