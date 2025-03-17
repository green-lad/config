<#
.SYNOPSIS
    Creates (default) / deletes (if $Clean is set) links which are hardcoded in the script.
    The links are hardlinks for files (unless $UseSymLinkForFiles is set) and symlinks for directories.
    Alternative you can pass $Value and $Path as argument to process one link.

.PARAMETER UseSymLinkForFiles
    Use symlinks (symbolic links) for files instead

.PARAMETER Clean
    Delete links instead of creating them

.PARAMETER Path
    Create one link with this path

.PARAMETER Value
    Create one link with this value

.OUTPUTS
    System.Boolean. Return indicates whether the execution changed the system.
    In case of an exception the system can have changed.
#>

param (
    [Parameter(ParameterSetName = 'hardcoded')]
    [Parameter(ParameterSetName = 'explicit')]
        [switch] $UseSymLinkForFiles,

    [Parameter(ParameterSetName = 'hardcoded')]
    [Parameter(ParameterSetName = 'explicit')]
    [switch] $Clean,

    [Parameter(ParameterSetName = 'hardcoded')]
    [Parameter(ParameterSetName = 'explicit')]
    [switch] $Cautious,

    [Parameter(Mandatory = $true, ParameterSetName = 'explicit')]
	[string] $Path,

    [Parameter(Mandatory = $true, ParameterSetName = 'explicit')]
        [string] $Value = "$env:UserProfile"
)

Set-StrictMode -Version Latest
trap { throw $Error[0] }
$ErrorActionPreference = "Stop"

$repoBaseDir = "$PSScriptRoot/.."

# $msbuild="C:\Windows\Microsoft.NET\Framework64\v4.0.30319\"
$links = @(
    @{
        path="$PROFILE";
        value="$repoBaseDir/profile.ps1";
        linkType="HardLink"
    },
    #@{
    #    path="$env:UserProfile/.gitconfig";
    #    value="$repoBaseDir/config/git/gitconfig";
    #    linkType="HardLink"
    #},
    @{
        path="$repoBaseDir/bin/tf";
        value='C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer';
        linkType="SymbolicLink"
    },
    @{
        path="~/startup";
        value="~/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup";
        linkType="HardLink"
    },
    @{
        path="~/AppData/Local/Google/Chrome/User Data/Default/Preferences";
        value="$repoBaseDir/config/chrome/Preferences.json";
        linkType="HardLink"
    },
    @{
        path="~/AppData/Local/Google/Chrome/User Data/Default/Bookmarks";
        value="$repoBaseDir/config/chrome/Bookmarks.json";
        linkType="HardLink"
    },
    @{
        path="C:/ProgramData/Microsoft/Windows/Start Menu/Programs/ConEmu/ConEmu.lnk";
        value="$repoBaseDir/bin/ConEmu/ConEmu.exe";
        linkType="Shortcut"
    },
    @{
        path="$repoBaseDir/bin/ConEmu/ConEmu.xml";
        value="$repoBaseDir/config/ConEmu/ConEmu.xml";
        linkType="HardLink"
    }
)

if ($Path) {
    $links = @(@{$Path=$Value})
}

function ExpandValue {
    foreach($link in $links) {
        $path = $link.path
        $value = $link.value
        if(!(Test-Path $value)) {
            throw "The value [$value] for path [$path] does not exist."
        }
        else {
            $link.value = (gi $value).FullName
        }
    }
}

ExpandValue

$changed = $false

function GetHardLinks {
    param([string]$file)
    $fullPath = (gi $file).fullname
    $externalScript="$PSScriptRoot/../script/Get-HardLinks.ps1"
    return & $externalScript $fullPath
}

# src: https://stackoverflow.com/questions/9701840/how-to-create-a-shortcut-using-powershell
function CreateShortcut {
    param (
        [string]$value,
        [string]$path,
        [string]$ArgumentsToSourceExe
    )
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($path)
    $Shortcut.TargetPath = $value
    $Shortcut.Arguments = $ArgumentsToSourceExe
    $Shortcut.Save()
}

function CreateLinkCreationScriptBlock {
    param (
        [string]$path,
        [string]$value,
        [string]$linkType
    )
    if ($linkType -eq "Shortcut") {
        return [ScriptBlock]::Create("CreateShortcut -Path `"$path`" -Value `"$value`"")
    }
    return [ScriptBlock]::Create("New-Item -Path `"$path`" -Value `"$value`" -ItemType `"$linkType`"")
}

if($Clean) {
    if($(Read-Host -p ("Are you sure you want to delete the following links: " +
        "$($links | convertto-json) (N/y)")) -eq 'y') {
        foreach($link in $links) {
            Write-Host "Check removing [$(($link).path)]";
            if((Test-Path $link.path) -and ((gi $link.path).LinkType)) {
                Write-Verbose "Deleting link $($link.path)"
                (gi $link.path).Delete()
            }
            Write-Host "------------------------------------";
        }
    }
    return $true
}

foreach($link in $links) {
    $linkType = if($useSymLinkForFiles) {"SymbolicLink"} else {"HardLink"}
    if ($link.ContainsKey("linkType")) {
        Write-Host $link.path
        $linkType = $link.linkType
    }
    Write-Host "Check creating [$(($link).path)]";
    if(Test-Path $link.value -type Container) {
        $LinkType = "SymbolicLink"
    }
    if(Test-Path $link.path) {
        $item = gi $link.path
	
        $target = $item.Target
        if ($link.linkType -eq "Shortcut") {
            $sh = New-Object -ComObject WScript.Shell
            $target = $sh.CreateShortcut("$($link.path)").TargetPath
        }
        if(($target -eq $link.value) -or `
            ((GetHardLinks $link.path) -contains $link.value)) {
            Write-Host "Path [$($link.path)] already has the right value."
        }
        elseif(!$Cautious) {
            (gi $link.path).Delete()
            $changed = $true
        }
        else {
            throw "Path [$($link.path)] already exists with unexpected."
        }
    }
    if(-not (Test-Path $link.path)) {
        $parent = Split-Path $link.path
        if(-not (Test-Path -Type Container $parent)) {
            Write-Host "trying to create parent folder [$parent]"
            mkdir $parent
        }

        $command = CreateLinkCreationScriptBlock @link
        Write-Verbose "$command"
        Invoke-Command $command
        $changed = $true
    }
    Write-Host ([Environment]::NewLine)
}

return $changed
