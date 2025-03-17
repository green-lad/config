<#
.SYNOPSIS
    Sets environment variables via
    envionmentFunctions.Set-EnviornmentVariable foreach hardcoded element
    in script intern array $toSet.
#>

[cmdletbinding()]
param(
	[string]$Language = "en-US"

)

Set-StrictMode -Version Latest
trap { throw $Error[0] }
$ErrorActionPreference = "Stop"

Import-Module -Name International -UseWindowsPowerShell *> $null
$ls = (Get-WinUserLanguageList).LanguageTag

$i = $ls.IndexOf($Language)
if($i -eq 0) {
    return $false
}

if($i -eq -1) {
    $i = $ls.Count
    $ls.Add($Language)
}

$tmp = $ls[0]
$ls[0] = $ls[$i]
$ls[$i] = $tmp

Set-WinUserLanguageList -Force $ls
return $true
