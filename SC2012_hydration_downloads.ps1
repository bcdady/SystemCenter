$DrivePath = Read-Host -Prompt "- Enter the destination path, eg. C:\sc2012_prereq_files\"
$DownloadSCSuite = Read-Host -Prompt "- Do you want to Download the entire SC 2012 RC Suite? If you answer N, only Config Mgr will be downloaded. <Y or N>"
Write-Host "Beginning to download required files."
Import-Module BitsTransfer
## Prompt for the destination path

## Check that the path entered is valid
If (Test-Path "$DrivePath" -Verbose)
{
	## If destination path is valid, create folder if it doesn't already exist
	$DestFolder = "$DrivePath"
	New-Item -ItemType Directory $DestFolder -ErrorAction SilentlyContinue
}
Else
{
	Write-Warning " - Destination path appears to be invalid."
	Write-Host " - Defaulting to C:\sc2012_prereq_files\ "
	$DestFolder = "C:\sc2012_prereq_files\"
}
	Try
	{
		## Check if destination Folder already exists
        Write-Host "Verifying Destination Folder Exists, and we can write to it."
		If (Test-Path "$DestFolder")
		{
			
            ## Begin download
            Write-Host "Beginning Download of Pre-Req's for Hydration"
            
            Start-BitsTransfer -Source "http://www.deploymentresearch.com/DRFiles/HydrationCM2012RC2.zip" -Destination "$DestFolder\HydrationCM2012RC2.zip" -DisplayName "Downloading `'HydrationCM2012RC2.zip`' to $DestFolder" -Priority High -Description "From DeploymentResearch.com..." -ErrorVariable err
            Start-BitsTransfer -Source "http://download.microsoft.com/download/b/3/a/b3a89fae-f7bf-4e7c-b208-223b991e9c30/MicrosoftDeploymentToolkit2010_x64.msi" -Destination "$DestFolder\MicrosoftDeploymentToolkit2010_x64.msi" -DisplayName "Downloading `'MicrosoftDeploymentToolkit2010_x64.msi`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
			Start-BitsTransfer -Source "http://download.microsoft.com/download/b/3/a/b3a89fae-f7bf-4e7c-b208-223b991e9c30/MicrosoftDeploymentToolkit2010_x86.msi" -Destination "$DestFolder\MicrosoftDeploymentToolkit2010_x86.msi" -DisplayName "Downloading `'MicrosoftDeploymentToolkit2010_x86.msi`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err		
            Start-BitsTransfer -Source "http://support.microsoft.com/hotfix/KBHotfix.aspx?kbnum=2633146&kbln=en-us" -Destination "$DestFolder\SQLServer2008R2-KB2633146-x64.exe" -DisplayName "Downloading `'SQLServer2008R2-KB2633146-x64.exe`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
			Start-BitsTransfer -Source "http://www.microsoft.com/downloads/info.aspx?na=41&srcfamilyid=b9aa2dba-7f20-4c0c-9afd-1eebee5a94ea&srcdisplaylang=en&u=http%3a%2f%2fdownload.microsoft.com%2fdownload%2f7%2f7%2f6%2f776727E8-57EE-4AB5-BC69-6CCDF04A2A70%2fSQLServer2008R2SP1-KB2528583-x64-ENU.exe" -Destination "$DestFolder\SQLServer2008R2SP1-KB2528583-x64-ENU.exe" -DisplayName "Downloading `'SQLServer2008R2SP1-KB2528583-x64-ENU.exe`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
			Start-BitsTransfer -Source "http://download.microsoft.com/download/8/E/9/8E9BBC64-E6F8-457C-9B8D-F6C9A16E6D6A/KB3AIK_EN.iso" -Destination "$DestFolder\KB3AIK_EN.iso" -DisplayName "Downloading `'KB3AIK_EN.iso`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
			Start-BitsTransfer -Source "http://care.dlservice.microsoft.com/download/D/8/0/D808E432-5AC6-4DA5-A087-21947AC4AC5F/1033/SQLFULL_x64_ENU.exe" -Destination "$DestFolder\SQLFULL_x64_ENU.exe" -DisplayName "Downloading `'SQLFULL_x64_ENU.exe`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
			Start-BitsTransfer -Source "http://care.dlservice.microsoft.com/download/7/5/E/75EC4E54-5B02-42D6-8879-D8D3A25FBEF7/7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso" -Destination "$DestFolder\Server2008r2_sp1.iso" -DisplayName "Downloading `'Server2008r2_sp1.iso`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
			
            Write-Host "Beginning Download of System Center 2012 Components"
            
            IF ($DownloadSCSuite="Y")
                {
                Start-BitsTransfer -Source "http://care.dlservice.microsoft.com/dl/download/8/C/4/8C4F744E-0F2C-438C-8786-362D687B2517/SCOM2012RC.exe" -Destination "$DestFolder\SCOM2012RC.exe" -DisplayName "Downloading `'SCOM2012RC.exe`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
			    Start-BitsTransfer -Source "http://care.dlservice.microsoft.com/dl/download/3/4/C/34C7656A-F89E-473C-8CE0-21DA5DB0717C/ConfigMgr_2012_RC2_ENU_7703.exe" -Destination "$DestFolder\ConfigMgr_2012_RC2_ENU_7703.exe" -DisplayName "Downloading `'ConfigMgr_2012_RC2_ENU_7703.exe`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
			    Start-BitsTransfer -Source "http://care.dlservice.microsoft.com/dl/download/A/9/5/A956026A-18AB-4046-B47E-301AFABF9E34/System_Center_2012_Orchestrator_RC.EXE" -Destination "$DestFolder\System_Center_2012_Orchestrator_RC.EXE" -DisplayName "Downloading `'System_Center_2012_Orchestrator_RC.EXE`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
			    Start-BitsTransfer -Source "http://care.dlservice.microsoft.com/dl/download/0/F/6/0F6679F0-9E9C-432A-B44C-7BCCBB36D82E/DPM_EVAL_RC.zip" -Destination "$DestFolder\DPM_EVAL_RC.zip" -DisplayName "Downloading `'DPM_EVAL_RC.zip`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
			    Start-BitsTransfer -Source "http://care.dlservice.microsoft.com/dl/download/0/6/8/068DBD4A-6544-4CC7-966A-810FC0D89E4D/VMM.EVAL.RC.exe" -Destination "$DestFolder\VMM.EVAL.RC.exe" -DisplayName "Downloading `'VMM.EVAL.RC.exe`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
		        Start-BitsTransfer -Source "http://care.dlservice.microsoft.com/dl/download/F/5/F/F5F22F42-7566-4246-A0C6-FF81FD5CA250/SCSM2012_RC.exe" -Destination "$DestFolder\SCSM2012_RC.exe" -DisplayName "Downloading `'SCSM2012_RC.exe`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
		        Start-BitsTransfer -Source "http://care.dlservice.microsoft.com/dl/download/5/0/A/50AFAC54-781E-4711-B85C-BE064B423C58/SC2012_UnifiedInstaller_RC.exe" -Destination "$DestFolder\SC2012_UnifiedInstaller_RC.exe" -DisplayName "Downloading `'SC2012_UnifiedInstaller_RC.exe`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
			    Start-BitsTransfer -Source "http://care.dlservice.microsoft.com/dl/download/7/A/C/7AC5564B-DB1A-47B3-8F7E-E464445EE5B6/AppController.Beta.exe" -Destination "$DestFolder\AppController.Beta.exe" -DisplayName "Downloading `'AppController.Beta.exe`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
			    }
                
                ELSE
                
                {
                Start-BitsTransfer -Source "http://care.dlservice.microsoft.com/dl/download/3/4/C/34C7656A-F89E-473C-8CE0-21DA5DB0717C/ConfigMgr_2012_RC2_ENU_7703.exe" -Destination "$DestFolder\ConfigMgr_2012_RC2_ENU_7703.exe" -DisplayName "Downloading `'ConfigMgr_2012_RC2_ENU_7703.exe`' to $DestFolder" -Priority High -Description "From Microsoft.com..." -ErrorVariable err
			    }
            
            If ($err) {Throw ""}
		}
		Else
		{
			Write-Host " - Folder does not exist, Cancelling..."
		}
	}
	Catch
	{
		Write-Warning " - An error occurred downloading files"
		break
	}
## View the downloaded files in Windows Explorer
Invoke-Item $DestFolder
Write-Host "Finished downloading required files."