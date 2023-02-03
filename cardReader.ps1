:: <# BEGIN POWERSHELL AS BATCH HEADER
@ECHO OFF
copy %~s0 %~s0.ps1 >nul
PowerShell.exe -ExecutionPolicy Unrestricted -NoProfile -Command function :: {}; %~s0.ps1 '%1' '%2'
del %~s0.ps1 >nul
:: To avoid potentially leaving a window hanging, you could EXIT
:: This is much nicer if you're calling this from an existing cmd window
pause
:: END POWERSHELL AS BATCH HEADER #>
. {


    # Base variable declaration; for path and string appending
    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\USB\VID_FC02&PID_0101"
    $dP = "\Device Parameters"

    # Specifically declare this array to be of type [string[]] instead of objects so that it 
    # can be appended with strings
    [string[]]$pathChildren = @(Get-ChildItem $keyPath)

    # Calling "Get-ChildItem" on $keyPath string causes "HKLM:" to be replaced with "HKEY_LOCAL_MACHINE"
    # because of the way that "Get-ChildItem" returns the path; this loop iterates through each string
    # in the $pathChildren array to change "HKEY_LOCAL_MACHINE" back to "HKLM:"
    for ($p = 0; $p -lt $pathChildren.Count; $p++) {
        $pathChildren[$p] = $pathChildren[$p] -replace 'HKEY_LOCAL_MACHINE', 'HKLM:'
    }

    # Append $dP to end of every element within the $pathChildren array; this makes the
    # complete path to the specific registry key that contains the entry needed
    for ($i = 0; $i -lt $pathChildren.Count; $i++) {
        $pathChildren[$i] = $pathChildren[$i] += $dP
    }

    # Set the key entries specified from every path specified in $pathChildren to a value of 0
    for ($e = 0; $e -lt $pathChildren.Count; $e++) {
        Set-ItemProperty -Path $pathChildren[$e] -Name "EnhancedPowerManagement" -Value 0
    }

    for ($k = 0; $k -lt $pathChildren.Count; $k++) {
        if ((Get-ItemProperty -Path $pathChildren[$k]) -match "EnhancedPowerManagement") {
            Write-Host "EnhancedPowerManagement set to 0 for all devices listed."
        } else {Write-Host "Failure; try running as ADMINISTRATOR."}
    }


} @Args

