<#
.SYNOPSIS
    Iterates through subscripts and executs them.
    Each subscript either returns an array, a string (required action for script
    to take effect) or a boolean indicating if sth changed through the exectuion.

.PARAMETER Ask
    - before every subscript ask wether to run it
    - sets $VerbosePreference to "Continue"
#>

[cmdletbinding()]
param(
    [switch] $Ask,
    [switch] $StopIfSubscriptThrows,
    [string] $modulesPath = "$PSScriptRoot\script\modules",
    [string[]] $scriptPath = @("$PSScriptRoot\setup"),
    [string] $ErrorActionPreference = "Stop"
)

Set-StrictMode -Version Latest
trap { throw $Error[0] }

function AddRepoSpecificPSModules {
    param([string]$path)
    $modulePath = $(gi $path).fullname
    $setPaths = $env:PSModulePath -split ';'

    if($setPaths -notcontains $modulePath) {
        $env:PSModulePath += ";$modulesPath"
    }
}

function Separator { Write-Host -ForegroundColor green ("-" * 80) }

function RunScripts {
    param([String[]] $scripts)

    $initialErrorCount = $error.count
    $curErrorCount = $initialErrorCount
    $commandsToRun = @()
    $unknownCommands = @()
    $stopExecution = $false
    $exitCode = 0

    foreach($script in $scripts) {
        Separator
        $executeIt = $true
	$ret = $false
        Write-Host "execute: $script"
        if($ask){
            $read = (Read-Host -prompt "continue (Y/n/s)")
            if($read -eq "s") {
                exit $exitCode
            }
            $executeIt = $read -ne "n"
        }
        if($executeIt) {
	    try {
                if($ask) {
                    $ret = (& "$script" -Verbose)
                }
                else {
		    $ret = (& "$script")
		}
	    }
	    catch {
	        $message = "{0}{1}{2}" -f $_.Exception, [Environment]::NewLine, $_.ScriptStackTrace
		$exitCode = $exitCode + 1
		if($StopIfSubscriptThrows) {
		    throw $message
		}
		else {
		    Write-Host $message -f red
		}
	    }
            if($ret){
                Write-Host "Returned [$ret], environment changed" -foregroundcolor green
            }
        }
    }

    Separator
    return $exitCode
}

$bin = "$PSScriptRoot\bin"
if(-not (Test-Path $bin)) {
    Expand-Archive "$PSScriptRoot\bin.zip" $bin
}

AddRepoSpecificPSModules $modulesPath
$subscripts = gci -path $scriptPath -filter *.ps1 -file | %{$_.fullname}
exit (RunScripts $subscripts)
