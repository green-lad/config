<#
    .SYNOPSIS
        Powershell profile for custom session settings
    .USAGE
        Source it in one of the default profile paths (for location see: https://devblogs.microsoft.com/scripting/understanding-the-six-powershell-profiles/)
#>

# used to keep functions and datastructures private within the profile
$profileScript = {
    if(( [System.Environment]::GetCommandLineArgs() | ?{$_ -like "-NonI*"}) -and (-not [System.Environment]::UserInteractive)) {
        return;
    }
    $aliase = @{
        procmon="C:\Tools!!!\Sysinternals\SysinternalsSuite\Procmon.exe"
        vim="nvim"
        wkoprog="C:\Program=Files=(x86)\DATEV\PROGRAMM\KORG\wkoprog.exe"
        dkmain="$env:DevelopmentPath\$env:Branch\eo\bin\rscl\dkmain.exe"
        dkmaind="$env:DevelopmentPath\$env:Branch\eo\bin\rscl\dkmaind.exe"
        where="C:\Windows\System32\where.exe"
        tf="C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe"
        tfpub='msbuild /m subsystem.targets /nr:false /p:Configuration=Release /p:Platform="Mixed Platforms" /p:RegisterForComInterop=false /p:BuildPackagesParallel=true /p:RootDir=..\..\..\ /p:TestCategory= /p:REFRESHSCOPE=pub  /t:RefreshFromDrop  -v:normal'
        # tf="D:\Users\t20946a\dotfiles\bin\Team Explorer\TF.exe"
    }

    function view-history {
        nvim ((Get-PSReadlineOption).HistorySavePath)
    }

    function private:setAliase {
        param
        (
            [Parameter(Mandatory=$true, Position=0)]
            [hashtable] $Hash
        )

        foreach($key in $Hash.Keys) {
            Set-Alias -force -scope global -name "$key" -value $Hash[$key] -option AllScope
        }
    }
    setAliase -Hash $aliase

    function private:Set-Look {
        function global:Prompt {
            $color = if(!$([System.Environment]::GetEnvironmentVariable("Color"))) {"Green"} else {"$env:Color"}
            $oc = $host.ui.RawUI.ForegroundColor
            $disabledColor="DarkGray"
            $enabledColor="Yellow"

            $adminSignColor=$disabledColor
            $adminSign="$ "
            if([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")){
                $adminSignColor=$enabledColor
            }

            $devSignColor=$disabledColor
            if($env:DevEnvDir) {
                $devSignColor=$enabledColor
            }

            $currentPath=([string]$pwd).Replace("$env:userprofile", "~")
            $promptEnd=" >"
            $Host.UI.RawUI.ForegroundColor = "$adminSignColor"
            $Host.UI.Write($adminSign)
            $host.UI.RawUI.ForegroundColor = "$color"
            $Host.UI.Write($currentPath) 
            $Host.UI.RawUI.ForegroundColor = "$devSignColor"
            $Host.UI.Write($promptEnd) 
            $host.UI.RawUI.ForegroundColor = $disabledColor
            $date = "$(Get-Date)"
            $startposx = $Host.UI.RawUI.WindowSize.Width - $date.length - 1
            $startposy = $Host.UI.RawUI.CursorPosition.Y

            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $startposx,$startposy
            $host.UI.RawUI.ForegroundColor = "DarkGray"
            $Host.UI.Write($date)
            $startposx = $currentPath.length + $adminSign.length + 2
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $startposx,$startposy
            $host.UI.RawUI.ForegroundColor = $oc
            return " "
        }
    }

    function private:Configure-PsReadline {
		function set-options {
            $options = @{
                "editmode" = "vi";
                "vimodeindicator" = "cursor";
            	"predictionsource" = "none";
                "colors" = '@{
                    "Error" = [ConsoleColor]::DarkRed
                    "String" = "darkcyan"
                    "Command" = "$([char]0x1b)[35;93m"
                    "Comment" = "darkgreen"
                }'
            }
            $supported_options = (Get-Command Set-PSReadLineOption).Parameters.Keys
            foreach ($option_name in $options.Keys) {
                if ($option_name -in $supported_options) {
                    Invoke-Expression "Set-PSReadLineOption -$option_name $($options[$option_name])"
                }
            }
        }

        function set-keybindings {
            Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
            Set-PSReadLineKeyHandler -Chord Ctrl+e -ScriptBlock {
                [Microsoft.PowerShell.PSConsoleReadLine]::Copy()
                [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            } 
            Set-PSReadLineKeyHandler -Chord Ctrl+e -ViMode Command -ScriptBlock {
                [Microsoft.PowerShell.PSConsoleReadLine]::Copy()
                [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            } 
            Set-PsReadLineKeyHandler -Chord Ctrl+l -ScriptBlock {
                [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen()
            }
        }

        set-options
        set-keybindings
    }

    function global:Set-StartDir {
        param
        (
            [Parameter(Mandatory=$false)]
            [string] $dirpath = "",
            [Parameter(Mandatory=$false)]
            [switch] $cd
        )
        $startDir = "$env:UserProfile/cur"
        if($dirpath) {
            New-Item -Type SymbolicLink -value $dirpath -path $startDir -Force
        }
        if($cd) {
            if($startDir -and (Test-Path $startDir) -and $((gi $startDir).LinkType -eq "SymbolicLink")) {
                cd "$($(gi $startDir).Target)"
            }
            else {
                cd ~
            }
        }
    }

    function Add-ExtendedTypeSystemPropertyHardLInksToFileInfo {
        Update-TypeData -Force -TypeName System.IO.FileInfo -MemberName HardLinks -MemberType ScriptProperty -Value {
            if ($env:OS -ne 'Windows_NT') { 
                # Note: throw and Write-Error are quietly ignored in a ScriptProperty script block.
                Write-Warning "The .HardLinks property is only supported on Windows." 
                return [string[]] @()
            }

            ./script/Get-HardLinks.ps1
        }
    }

    Set-Look
    if (Get-Module PSReadLine) {
        Import-Module PSReadLine
        Configure-PsReadline
    }
    Set-StartDir -cd
    Add-ExtendedTypeSystemPropertyHardLInksToFileInfo

    # the expansion of ~ changed starting 7.4.0 breaking among others nvim when opening files
    # Tmp FIX: override the known tab expansion function TabExpansion2 to replace ~
    function global:TabExpansion2
    {
        <# Options include:
            RelativeFilePaths - [bool]
                Always resolve file paths using Resolve-Path -Relative.
                The default is to use some heuristics to guess if relative or absolute is better.

        To customize your own custom options, pass a hashtable to CompleteInput, e.g.
                return [System.Management.Automation.CommandCompletion]::CompleteInput($inputScript, $cursorColumn,
                    @{ RelativeFilePaths=$false }
        #>

        [CmdletBinding(DefaultParameterSetName = 'ScriptInputSet')]
        [OutputType([System.Management.Automation.CommandCompletion])]
        Param(
            [Parameter(ParameterSetName = 'ScriptInputSet', Mandatory = $true, Position = 0)]
            [AllowEmptyString()]
            [string] $inputScript,

            [Parameter(ParameterSetName = 'ScriptInputSet', Position = 1)]
            [int] $cursorColumn = $inputScript.Length,

            [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 0)]
            [System.Management.Automation.Language.Ast] $ast,

            [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 1)]
            [System.Management.Automation.Language.Token[]] $tokens,

            [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 2)]
            [System.Management.Automation.Language.IScriptPosition] $positionOfCursor,

            [Parameter(ParameterSetName = 'ScriptInputSet', Position = 2)]
            [Parameter(ParameterSetName = 'AstInputSet', Position = 3)]
            [Hashtable] $options = $null
        )

        End
        {
            $TempRes = if ($psCmdlet.ParameterSetName -eq 'ScriptInputSet')
            {
                [System.Management.Automation.CommandCompletion]::CompleteInput(
                    <#inputScript#>  $inputScript,
                    <#cursorColumn#> $cursorColumn,
                    <#options#>      $options)
            }
            else
            {
                [System.Management.Automation.CommandCompletion]::CompleteInput(
                    <#ast#>              $ast,
                    <#tokens#>           $tokens,
                    <#positionOfCursor#> $positionOfCursor,
                    <#options#>          $options)
            }

            [system.management.automation.completionresult[]]$newcompletionlist = foreach ($item in $tempres.completionmatches)
            {
                if ($Item.CompletionText -like "*~*")
                {
                    "item: $Item" > ~/tmp.log
                    [System.Management.Automation.CompletionResult]::new(
                        $Item.CompletionText.Replace('~', $HOME),
                        $Item.ListItemText,
                        $Item.ResultType,
                        $Item.ToolTip
                    )
                }
                else
                {
                    $Item
                }
            }

            if ($newcompletionlist) {
                $TempRes.CompletionMatches = $newcompletionlist
            }
            $TempRes
        }
    }
}

& $profileScript
