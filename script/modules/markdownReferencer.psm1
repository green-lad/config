$script:color = [Environment]::GetEnvironmentVariables("User").MyColor
$script:fileMarkdown = "$HOME\reference\filePaths.md"
$script:dirMarkdown = "$HOME\reference\dirPaths.md"
$script:exeMarkdown = "$HOME\reference\executables.md"
$vimexe = [Environment]::GetEnvironmentVariables("User").VIMEXE

function findMatchInMarkdown
{
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript({ Test-Path $_ })]
        [string] $regexMarkdownFile,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $regex
    )

    $toMatch = getColumnMarkdownTable -path $regexMarkdownFile -column 1
    $regexs = getColumnMarkdownTable -path $regexMarkdownFile -column 2
    $matched = handleInput -pathMarkdownFile $regexMarkdownFile -in $regex -toMatch $toMatch
    if([int]$matched -ge 0){
        return $matchedPath = $regexs[$matched] -replace "\s+([CD]+.+\w)\s+",'$1'
    }
    return [int]$matched
}

#assumption: deault return bool is false
function markdownExecute
{
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateScript({(Get-Command $_.Split(" ")[0] -ErrorAction SilentlyContinue)})]
        # default: system defined execution
        [string] $command = "explorer",
        [Parameter(Mandatory=$false, Position=2)]
        [ValidateScript({ Test-Path $_ })]
        [string] $path = ".",
        [Parameter(Mandatory=$false, Position=3)]
        [ValidateScript({ (Get-Command $_.Split(" ")[0] -ErrorAction SilentlyContinue)})]
        # default: system defined execution
        [string] $checkPathExist = "Test-Path",
        [Parameter(Mandatory=$true, Position=4)]
        [ValidateScript({ Test-Path $_ })]
        [string] $markdownFile,
        [Parameter(Mandatory=$true, Position=6)]
        [string] $regex,
        # not only go through markdown
        [Parameter(Mandatory=$false, Position=7)]
        [bool] $checkDir= $true,
        [Parameter(Mandatory=$false, Position=8)]
        [bool] $checkDirFirst = $true,
        # option used for example if more then one markdown file should be parsed and this execution is not the last
        [Parameter(Mandatory=$false, Position=9)]
        [bool] $printError = $true
    )

    $markdownMatchedPath = $(findMatchInMarkdown $markdownFile $regex )
    $fromMarkdownIndependentPath = "$path\$regex"

    # Write-Host $( Invoke-Expression("$checkPathExist $path") )
    if($checkDir -and $checkDirFirst -and $(Invoke-Expression("$checkPathExist $fromMarkdownIndependentPath")))
    {
        & $command $fromMarkdownIndependentPath
        return $?
    }
    elseif (!(($markdownMatchedPath).GetType().fullname -eq (1).GetType().fullname)){
        $control = "$checkPathExist `"$markdownMatchedPath`""
        if(Invoke-Expression("$control")){
            & $command $markdownMatchedPath
            return $?
        }
        else{
            if($printError){
                returnFalsePrintError "Error: `'$markdownMatchedPath`' in `'$markdownFile`' does not fit `'$checkPathExist`'`n"
            }
        }
    }
    elseif(! ([int]$markdownMatchedPath -eq -2)){
        if($checkDir -and $checkDirFirst -and (Invoke-Expression("$checkPathExist $fromMarkdownIndependentPath"))){
            if($executeFoundAndNotTheCommand){
                Invoke-Expression("$command $fromMarkdownIndependentPath")
                return $?
            }
        }
        elseif($printError){
            returnFalsePrintError "Error: `'$regex`' does not fit `'$checkPathExist`' in `'$path`' and not as regex in `'$markdownFile`'`n"
        }
    }
    #deliberately return false if $matchedPath is -2 or nothing is found with regex
}

function executeMarkdownExe
{
    param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateScript({ (Get-Command $_.Split(" ")[0] -ErrorAction SilentlyContinue)})]
        # default: system defined execution
        [string] $command = "explorer",
        [Parameter(Mandatory=$false, Position=1)]
        [ValidateScript({ Test-Path $_ })]
        [string] $path = ".",
        [Parameter(Mandatory=$true, Position=2)]
        [string] $regex,
        [Parameter(Mandatory=$false, Position=3)]
        [bool] $checkDir = $true,
        [Parameter(Mandatory=$false, Position=3)]
        [bool] $checkDirFirst = $true,
        # option used for example if more then one markdown file should be parsed and this execution is not the last
        [Parameter(Mandatory=$false, Position=4)]
        [bool] $printError = $true
    )
    
    markdownExecute -command "$command" -path "$path" -checkPathExist "Get-Command $command.Split(" ")[0] -ErrorAction SilentlyContinue" -markdownFile "$exeMarkdown" -regex "$regex" -checkDir $checkDir -checkDirFirst $checkDirFirst -printError $printError
}

function executeMarkdownFile
{
    param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateScript({ (Get-Command $_.Split(" ")[0] -ErrorAction SilentlyContinue)})]
        # default: system defined execution
        [string] $command = "explorer",
        [Parameter(Mandatory=$false, Position=1)]
        [ValidateScript({ Test-Path $_ })]
        [string] $path = ".",
        [Parameter(Mandatory=$true, Position=2)]
        [string] $regex,
        [Parameter(Mandatory=$false, Position=3)]
        [bool] $checkDirFirst = $true,
        # option used for example if more then one markdown file should be parsed and this execution is not the last
        [Parameter(Mandatory=$false, Position=4)]
        [bool] $printError = $true
    )
    
    markdownExecute -command "$command" -path "$path" -checkPathExist "Test-Path -pathtype leaf" -markdownFile "$fileMarkdown" -regex "$regex" -checkDirFirst $checkDirFirst -printError $printError
}

function checkMarkdownFilesForDuplicates
{
    param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateScript({ (Get-Command $_.Split(" ")[0] -ErrorAction SilentlyContinue)})]
        # default: system defined execution
        [string[]] $files = "explorer",
        [Parameter(Mandatory=$false, Position=1)]
        [ValidateScript({ Test-Path $_ })]
        [string] $path = ".",
        [Parameter(Mandatory=$true, Position=2)]
        [string] $regex,
        [Parameter(Mandatory=$false, Position=3)]
        [bool] $checkDirFirst = $true,
        # option used for example if more then one markdown file should be parsed and this execution is not the last
        [Parameter(Mandatory=$false, Position=4)]
        [bool] $printError = $true
    )

}

function executeMarkdownDir
{
    param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateScript({ (Get-Command $_.Split(" ")[0] -ErrorAction SilentlyContinue)})]
        # default: system defined execution
        [string] $command = "explorer",
        [Parameter(Mandatory=$false, Position=1)]
        [ValidateScript({ Test-Path $_ })]
        [string] $path = ".",
        [Parameter(Mandatory=$true, Position=2)]
        [string] $regex,
        [Parameter(Mandatory=$false, Position=3)]
        [bool] $checkDirFirst = $true,
        # option used for example if more then one markdown file should be parsed and this execution is not the last
        [Parameter(Mandatory=$false, Position=4)]
        [bool] $printError = $true
    )
    
    markdownExecute -command "$command" -path "$path" -checkPathExist "Test-Path -pathtype container" -markdownFile "$dirMarkdown" -regex "$regex" -checkDirFirst $checkDirFirst -printError $printError
}

function printMarkdownTable([string]$path, [string]$color)
{
    $headEnd = 2
    $numberMarkdownTable = Get-Content $path | Measure-Object -Line
    $numberTableLines = $numberMarkdownTable.lines - $headEnd
    
    # Write-Host -ForegroundColor $color $path[$headEnd]
    $separationLine = (Get-Content $path)[$headEnd-1]
    $separationLine = $separationLine.Replace("|", "-")
    $lineLength=$separationLine.Length
    $separationLine = "+" + $separationLine.Substring(1,$lineLength-2) + "+"

    # $separationLine = $separationLine.remove($lineLength-2,$lineLength-1).insert($lineLength-1,"+")
    Write-Host -ForegroundColor $color $separationLine

    foreach($line in $(head -n $headEnd $path) ) {
        Write-Host -ForegroundColor $color $line
    }

    foreach($line in $(tail -n $numberTableLines $path) ) {
        $line = $line.Split("|")
        # Write-Host -ForegroundColor $color "|"
        # while($line) {$cells, $null, $line = $line}
        $null, $cells = $line
        $cells | % {}{Write-Host -NoNewline -ForegroundColor $color "|"; Write-Host -NoNewline $_}
        # Write-Host -NoNewline $cells
        Write-Host
    }

    Write-Host -ForegroundColor $color $separationLine
    Write-Host
}

function getColumnMarkdownTable
{
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript({ (Get-Item $_ | select -Expand Extension) -eq ".md" })]
        [string] $path,
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $column
    )

    $headEnd=2
    $numberMarkdownTable = Get-Content $path | Measure-Object -Line
    $numberTable = $numberMarkdownTable.lines - $headEnd
    $returnColumn = @()
    foreach($line in tail -n $numberTable $path){
        $line = $line.Split("|")
        $returnColumn += $line[$column]
    }
    return [string[]]$returnColumn
}

function handleInput
{
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript({ (Get-Item $_ | select -Expand Extension) -eq ".md" })]
        [string] $pathMarkdownFile,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $in,
        [Parameter(Mandatory=$false, Position=2)]
        [string[]]$toMatch
    )

    switch -wildcard($in){
        "q"{
            Continue
        }
        "quit"{
            return "-2"
        }
        "xe*"{
            & $vimexe $PSCommandPath
            return "-2"
        }
        "xa*"{
            & $vimexe $pathMarkdownFile
            return "-2"
        }
        "help"{
            Write-Host -ForegroundColor $global:color $pathMarkdownFile
            printMarkdownTable -path $pathMarkdownFile -color $global:color
            return "-2"
        }
        default{
            $in = " " + $in + "*"
            $matched = regexMatch -toMatch $toMatch -in $in
            return $matched 
        }
    }
}
