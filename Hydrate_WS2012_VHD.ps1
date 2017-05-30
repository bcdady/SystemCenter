<#
Convert-WindowsImage.ps1 -SourcePath <String> -VHDPath <String> -WorkingDirectory <String> -SizeBytes <UInt64> -VHDFormat <String> -VHDType <String>
[-UnattendPath <String>] [-Edition <String>] 

PARAMETERS
    -SourcePath <String>
        The complete path to the WIM or ISO file that will be converted to a Virtual Hard Disk.
        The ISO file must be valid Windows installation media to be recognized successfully.

    -VHDPath <String>
        The name and path of the Virtual Hard Disk to create.
        Omitting this parameter will create the Virtual Hard Disk is the current directory, (or,
        if specified by the -WorkingDirectory parameter, the working directory) and will automatically
        name the file in the following format:

        <build>.<revision>.<architecture>.<branch>.<timestamp>_<skufamily>_<sku>_<language>.<extension>
        i.e.:
        8250.0.amd64chk.winmain_win8beta.120217-1520_client_professional_en-us.vhd(x)

    -WorkingDirectory <String>
        Specifies the directory where the VHD(X) file should be generated.
        If specified along with -VHDPath, the -WorkingDirectory value is ignored.
        The default value is the current directory ($pwd).

    -SizeBytes <UInt64>
        The size of the Virtual Hard Disk to create.
        For fixed disks, the VHD(X) file will be allocated all of this space immediately.
        For dynamic disks, this will be the maximum size that the VHD(X) can grow to.
        The default value is 40GB.

    -VHDFormat <String>
        Specifies whether to create a VHD or VHDX formatted Virtual Hard Disk.
        The default is VHD.

    -VHDType <String>
        Specifies whether to create a fixed (fully allocated) VHD(X) or a dynamic (sparse) VHD(X).
        The default is dynamic.

    -UnattendPath <String>
        The complete path to an unattend.xml file that can be injected into the VHD(X).

    -Edition <String>
        The name or image index of the image to apply from the WIM.
        NOTE: For Windows Server 2012, Valid edition names are:
            ServerStandardCore
            ServerStandard
            ServerDataCenterCore
            ServerDataCenter

#>

pushd S:\deploy_scripts
& Convert-WindowsImage.ps1 -SourcePath D:\sources\install.wim -Edition ServerStandard -WorkingDirectory "C:\ProgramData\Virtual Machine Manager Library Files\VHDs"