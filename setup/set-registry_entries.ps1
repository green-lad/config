<#
.SYNOPSIS
    Sets hardcoded system configurations ($registryEntriesToSet) in the registry.

.DESCRIPTION
    External dependencies:
        Creating key remapping: $PSScriptRoot\..\script\get-scancodemap.ps1
        Setting registry entries: registryFunctions.Set-RegistryEntry.
#>

Set-StrictMode -Version Latest
trap { throw $Error[0] }
$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\..\script\modules\registryFunctions" -Verbose:`
    $([Management.Automation.ActionPreference]"SilentlyContinue")

$repoBaseDir = "$PSScriptRoot/.."

$remap = [ordered]@{
	"capslock" = "esc";
	"insert" = "deactivate"
}

$registryEntriesToSet = @(
    @{
        Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout";
        Value = $(& "$PSScriptRoot\..\script\get-scancodemap.ps1" -Map $remap);
        Name = "Scancode Map";
        Type = "binary";
        About = "Remaps keyinput from -> to: [$remap]."
		ActiveAfter = "Lock out"
    },
    @{
        Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Value = "SHL"
        Name = "DisabledHotkeys"
        Type = "string"
		ActiveAfter = "Killing explorer.exe"
    },
    @{
        Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
        Value =
        0x30,0x00,0x00,0x00,0xfe,0xff,0xff,0xff,
        0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x8c,0x00,0x00,0x00,0x5a,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x8c,0x00,0x00,0x00,0x38,0x04,0x00,0x00,
        0x90,0x00,0x00,0x00,0x01,0x00,0x00,0x00
        Name = "Settings"
        Type = "binary"
        About = "Moves the taskbar to the left, controlled by 13th value @{left=0x00; top=0x01; right=0x02; bottom=0x03}, restart of explorer.exe needed"
		ActiveAfter = "Killing explorer.exe"
    },
    @{
        Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Value = "0"
        Name = "SnapAssist"
        Type = "DWORD"
        About = "Disables snap assist."
		ActiveAfter = "Killing explorer.exe"
    },
    @{
        Path = "HKCU:\software\microsoft\windows\shell\associations\urlassociations\ftp\userchoice"
        Value = "chromehtml"
        Name = "progid"
        Type = "string"
        About = "Sets chrome as default browser for ftp."
		ActiveAfter = "Killing explorer.exe"
    },
    @{
        Path = "HKCU:\software\microsoft\windows\shell\associations\urlassociations\https\userchoice"
        Value = "chromehtml"
        Name = "progid"
        Type = "string"
        About = "Sets chrome as default browser for https."
		ActiveAfter = "Killing explorer.exe"
    },
    @{
        Path = "HKCU:\Control Panel\Keyboard"
        Value = "0"
        Name = "KeyboardDelay"
        Type = "String"
        About = "Repeat delay of keyboard."
		ActiveAfter = "Lock out"
    },
    @{
        Path = "HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe"
        Value = "Consolas"
        Name = "FaceName"
        Type = "String"
        About = "Sets the font type for the console window"
		ActiveAfter = "Reopen terminal"
    },
    @{ Path = "HKLM:\Software\Classes\*\shell\vim"
        Value = "Vim"
        Name = "(Default)"
        Type = "string"
        About = "Defines the text for the vim context item in the explorer."
		ActiveAfter = "Killing explorer.exe"
    },
    @{ Path = "HKLM:\Software\Classes\*\shell\vim\command"
        Value = "`"$repoBaseDir\bin\nvim\bin\nvim-qt.exe`" `"%1`""
        Name = "(Default)"
        Type = "string"
        About = "Defines the command for the vim context item in the explorer."
		ActiveAfter = "Killing explorer.exe"
    },
    @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies"
        Value = "1"
        Name = "DisableLockWorkstation"
        Type = "dword"
        About = "Disables Win+L to lock workstation."
		ActiveAfter = "Killing explorer.exe"
    }
)

$changed = $false
$registryEntriesToSet |
    %{
        Write-Host "Check setting [$(($_).path)]";
        if(Set-RegistryEntry @_) {
            $changed = $true
        }
        Write-Host ([Environment]::NewLine)
    }
return $changed
