$ErrorActionPreference = "Stop"

function getDevelopmentPath {
    param(
        [string]$Subsystem = "$env:Subsystem",
        [string]$Domain = "$env:Domain",
        [string]$Branch = "$env:Branch",
        [string]$DevelopmentRoot = "$env:DevelopmentRoot"
    )
    return "$env:DevelopmentRoot/$env:Branch/$env:Domain/$env:Subsystem"
}

function msbuild {
    param([string]$refreshscope, [string]$target, [string]$configuration)
    return "msbuild.exe /m subsystem.targets /nr:false /p:Configuration={2} /p:RegisterForComInterop=false /p:BuildPackagesParallel=true /p:RootDir=..\..\ /p:TestCategory= /p:REFRESHSCOPE={0} /t:{1} -v:normal" -f $refreshscope, $target, $configuration
}

$commands = @{
    "GetLatest" = @({msbuild "" "GetLatest" $args});
    "GetDependencies" = @({msbuild "pub" "RefreshFromDrop" $args}; {msbuild "pubAndOwnBin" "RefreshFromDropDebug" $args});
    "Build" = @({msbuild  "" "BuildAll" $args})
}

function Build-Simple {
    <#
    .SYNOPSIS
        Builds via common HoC via powershell.

    .TODO
        # - fine steps would be cool: $steps = @( "getPub", "getPubAndOwnBin", "getLatest", "preprocess", "compile", "link", "build", "deploy")
        # - build sub projects via auto tab completion: https://adamtheautomator.com/powershell-parameter-validation/
    #>

    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName="auto")]
        [string]$Subsystem = "$env:Subsystem",
        [Parameter(ParameterSetName="auto")]
        [string]$Domain = "$env:Domain",
        [Parameter(ParameterSetName="auto")]
        [string]$Branch = "$env:Branch",
        [Parameter(ParameterSetName="auto")]
        [string]$DevelopmentRoot = "$env:DevelopmentRoot",
        [Parameter(ParameterSetName="auto")]
        [Parameter(ParameterSetName="explicit")]
        [string]$Step = 'Build',
        [ValidateSet('Debug','Release')]
        [string]$Configuration = 'Debug',
        [Parameter(ParameterSetName="explicit", Mandatory=$true)]
        [string]$ProjectPath
    )
        
    if(!(Enter-Dev -Check)) {
        Write-Error "Not in dev enironment, enter dev env via eg [Enter-Dev] from this module."
    }

    if($PSCmdLet.ParameterSetName -eq "auto") {
        $ProjectPath = "$DevelopmentRoot/$Branch/$Domain/$Subsystem"
    }

    $cwd = pwd
    cd $ProjectPath
    foreach($command in $commands[$Step]) {
        $cmd = & $command $Configuration
        Write-Host -foregroundcolor Green $cmd
        Invoke-Expression $cmd
    }
    cd $cwd
}

Register-ArgumentCompleter -CommandName Build-Simple -ParameterName Step -ScriptBlock {$commands.Keys}

function Test-Dev {
    if($env:DevEnvDir) { return $true }
    else { return $false }
}

function Enter-Dev {
    param (
        [ValidateSet('Enterprise','Professional','Community')]
        [string]$licence = "Enterprise",
        [switch]$check
    )

    $isDev = Test-Dev
    if($check) {
        return $isDev
    }
    elseif(!$isDev) {
        $cwd = pwd
        $vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -property installationpath | ?{$_ -match "Enterprise$"}
        $devShellModulePath = "$vsPath\common7\tools\Microsoft.VisualStudio.DevShell.dll"
        Import-Module $devShellModulePath
        Enter-VsDevShell -VsInstallPath $vsPath > $null
        cd $cwd
    }
}

function Get-DevEnv {
    $infos = [ordered]@{
        "VS Path" = (& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -property installationpath | ?{$_ -match "Enterprise$"});
        "DevelopmentRoot" = "$env:DevelopmentRoot";
        "Branch" = "$env:Branch";
        "Domain" = "$env:Domain";
        "Subsystem" = "$env:Subsystem";
        "Deduced DevelopmentPath" = getDevelopmentPath
    }
    return $infos
}

function Set-DevLocation {
}

function Open-Cts {
}

Export-ModuleMember *-*
