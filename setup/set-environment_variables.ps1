<#
.SYNOPSIS
    Sets environment variables via
    envionmentFunctions.Set-EnviornmentVariable foreach hardcoded element
    in script intern array $toSet.
#>

Set-StrictMode -Version Latest
trap { throw $Error[0] }
$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\..\script\modules\registryFunctions" -Verbose:`
    $([Management.Automation.ActionPreference]"SilentlyContinue")


$repoBaseDir = (gi "$PSScriptRoot/..").fullname

$toSet = @(
    @{
        Variable = "Color";
        Value = "Green"
    },
    @{
        Variable = "XDG_CONFIG_HOME";
        Value = "$repoBaseDir\config"
    },
    @{
        Variable = "PSModulePath";
        Value = @(
            "$repoBaseDir\script\modules",
            "$env:UserProfile\.nuget\ExternalModules"
        );
        Append = $true;
    },
    @{
        Variable = "PSModulePath";
        Value = "C:\Program Files\WindowsPowerShell\Modules";
        Append = $true;
        Environment = "machine"
    },
    @{
        Variable = "Path";
        Value = @(
            "$repoBaseDir\script",
            "$repoBaseDir\script\setup"
        );
        Append = $true;
    },
    @{
        Variable = "Path";
        Value = {
            (gp -LiteralPath `
                'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full').
                InstallPath
        };
        Append = $true;
        Environment = "machine"
    },
    @{
        Variable = "VSCICOMNTOOLS";
        Value = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\";
        Append = $false;
        Environment = "machine"
    },
    @{
        Variable = "Path";
        Value = {
	    gi "$repoBaseDir\bin\**\bin" | ?{$_.PSIsContainer} | %{$_.FullName} | ?{ gci $_ | ? {$_ -like "*.exe"}}
            gci $repoBaseDir\bin | ?{$_.PSIsContainer} | %{$_.FullName} | ?{ gci $_ | ? {$_ -like "*.exe"}}
            (gi $repoBaseDir\bin).FullName | ?{ gci $_ | ? {$_ -like "*.exe"}}
        };
        Append = $true;
    },
    @{
        Variable = "DevelopmentRoot";
        Value = "$env:HomeDrive"
    },
    @{
        Variable = "Branch";
        Value = "next/next-main"
    }
)


$changed = $false
$toSet |
    %{
        Write-Host "Check setting [$(($_).variable)]";
        if(Set-EnvironmentVariable @_ -Verbose:$VerbosePreference){
            $changed=$true
        }
        Write-Host ([Environment]::NewLine)
    }
return $changed
