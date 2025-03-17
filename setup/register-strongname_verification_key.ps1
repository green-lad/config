<#
.SYNOPSIS
    Register assemblies which should be skipped by strong name verification.
    As input a strongname (multiple assemblies can have the same name) is required.

.PARAMETER Strongname
    Strongname to register for verfication skipping.

.OUTPUTS
    System.Boolean. Return indicates whether the execution changed the system.
    In case of an exception the system can have changed.
#>

param (
    [string] $Strongname
)

Set-StrictMode -Version Latest
trap { throw $Error[0] }
$ErrorActionPreference = "Stop"

$exe="C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\sn.exe"

if ([regex]::Matches((& $exe -Vl), '(?<=\*,)[a-z,0-9]+')) {
    return $false
}

if (-not $Strongname) {
    $Strongname = Read-Host "Strongname to register for verification skipping"
}
& $exe -Vr "*,$Strongname"
return $true
