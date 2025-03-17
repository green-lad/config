# TODO: autocomplete only for dlls
# see: https://foxdeploy.com/2017/01/13/adding-tab-completion-to-your-powershell-functions/

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string] $TestRegex, 
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateScript({(Test-Path -PathType Leaf $_) -and ($_ -match "\.dll")})]
    [string] $Dll
)

function GetInstalledVsTestConsoles {
    #$basePathGuess= 'C:\Program Files (x86)\Microsoft Visual Studio'
    $basePathGuess= '.'
    $nameExe="vstest.console.exe"
    Write-Host "Searching for $nameExe in $basePathGuess ..."
    return [string[]](gci -Recurse $basePathGuess | %{if($_.fullname -imatch "(.*\\)?$nameExe$") {$_.fullname}})
}

[string[]]$possiblePaths = GetInstalledVsTestConsoles
if($possiblePaths.Count -le 0) {
    Write-Host "No VsTestConsoles found" -ForegroundColor red
    exit 1
}

if($possiblePaths.Count -eq 1) {
    $choice = 0
}

else {
    $i = 0
    foreach($pos in $possiblePaths) {
        Write-Host "${i}:" $pos
        $i++
    }

    $choice = $i

    $tmp=$ErrorActionPreference
    $ErrorActionPreference="SilentlyContinue"
    while(($choice.GetType() -ne [int]) -or ($choice -ge $i)) {
        $choice = Read-Host "Choose exe by number"
        $choice = $choice / 1
    }
    $ErrorActionPreference=$tmp
}

Write-Host "Copied execution to system clipboard." -foregroundcolor yellow
$pathVsTestConsoleExe=$possiblePaths[$choice]
Set-Clipboard "& `'$pathVsTestConsoleExe`' `'$Dll`' /Tests:`"$testregex`""
