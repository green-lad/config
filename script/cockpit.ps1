<#
.SYNOPSIS
    Opens cockpit of the specified subsystem on the specified branch.
#>

param
(
    [Parameter(Mandatory=$false, Position=0)]
    [string] $Branch = "$env:Branch",
    [Parameter(Mandatory=$false, Position=1)]
    [string] $Domain = "$env:Domain",
    [Parameter(Mandatory=$false, Position=1)]
    [string] $Subsystem = "$env:Subsystem"
)

Import-Module enviornmentFunctions -Verbose:`
    $([Management.Automation.ActionPreference]"SilentlyContinue")

function CommentInLineContaining {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $File,
        [Parameter(Mandatory=$true, Position=0)]
        [string] $Line,
        [Parameter(Mandatory=$false, Position=0)]
        [string] $commentSigns = ":: "
    )

    # INFO: only could get it to work by using a tmp file ...
    # [regex]::Escape cant be used because characters to escape are different
    $regex = "^(?!\s*$commentSigns).*" + [regex]::Escape($Line)
    $tmpfile = (New-TemporaryFile).FullName
    (get-content $File | %{
            if($_ -Match $regex) {
                $_ -replace $regex, "$commentSigns $($Matches[0])"
            }
            else {
                $_
            }
        }) |
        out-file -filepath $tmpfile -encoding utf8
    cp $tmpfile $File
    rm $tmpfile
}

function adoptCockpitBehaviour {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $CockpitPath
    )

    Set-ItemProperty -path $CockpitPath -name isreadonly -value $false

    $toCommentIn = @(
        'mode con: cols=144 lines=60',
        'powershell -command "&{$H=get-host;$W=$H.ui.rawui;$B=$W.buffersize;' +
            '$B.width=144;$B.height=5000;$W.buffersize=$B;}"'
    )

    foreach($element in $toCommentIn){
        CommentInLineContaining -line $element -file $CockpitPath
    }
}

if(! $subsystem) {
    $subsystem = Read-Host "Please set susbystem"
    Set-EnvironmentVariable -Variable Subsytem -Value $subsystem
}

if(! $domain) {
    $domain = Read-Host "Please set domain"
    Set-EnvironmentVariable -Variable Domain -Value $domain
}

if(! $Branch) {
    $branch = Read-Host ("No branch set, choose from " +
        "$((ls $env:DevelopmentRoot).name)")
    if(Test-Path -type container "$env:DevelopmentRoot\$branch") {
        Set-EnvironmentVariable -Variable Branch -Value $branch
    }
}

$basepath = "$env:DevelopmentRoot\$branch\$domain\$subsystem"
$cockpitpath = "$basepath\cockpit.bat"
if(!(Test-Path -type leaf $cockpitpath)) {
    Write-Error "Path does not exist: $cockpitpath"
    exit 1
}

Write-Verbose "Starting cockpit with path: $cockpitpath"
# adoptCockpitBehaviour -cockpitpath $cockpitpath

return (Start-Process powershell -argumentlist "$cockpitpath -noprofile" -WorkingDirectory "$basepath" `
    -Passthru -WindowStyle Maximized)
