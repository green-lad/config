<#
.SYNOPSIS
    Grants the current user the right to create symbolic links.

.LINK
    https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/create-symbolic-links
#>

param (
    [string]$Username = $env:USERNAME,
    [string]$Domain = $env:USERDOMAIN
)

Set-StrictMode -Version Latest
trap { throw $Error[0] }
$ErrorActionPreference = "Stop"

function addSymLinkPermissionsViaIdString {
    $User = [System.Security.Principal.NTAccount]::new($Domain, $Username)
    $id = $User.Translate([System.Security.Principal.SecurityIdentifier]).Value

    if( [string]::IsNullOrEmpty($ID) ) {
        Write-Error "Account with id [$id] not found!"
        return $false
    }
    $tmp = [System.IO.Path]::GetTempFileName()
    #TODO: check if following can be executed
    secedit.exe /export /cfg "$($tmp)" *> $null
    $rightSetting = gc $tmp | ?{$_ -match "SeCreateSym*"} | %{($_ -split "=")[1].Trim()}
    rm $tmp
    $changesMade = $false
    if( ($rightSetting -notlike "*$id*") -and ($rightSetting -notlike "*$env:UserName*")) {
        if( [string]::IsNullOrEmpty($rightSetting) ) {
            $currentSetting = "*$id"
        } else {
            $currentSetting = "$rightSetting,*$id"
        }
        $outfile = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
SECreateSymbolicLinkPrivilege = $($currentSetting)
"@
        $tmp2 = [System.IO.Path]::GetTempFileName()
        $outfile | Set-Content -Path $tmp2 -Encoding Unicode -Force
        Push-Location (Split-Path $tmp2)
        try {
            secedit.exe /configure /db "secedit.sdb" /cfg "$($tmp2)" /areas USER_RIGHTS *> $null
            $changesMade = $true
        } finally { 
            Pop-Location
            rm $tmp2
        }
    }

    return $changesMade
}

return addSymLinkPermissionsViaIdString
