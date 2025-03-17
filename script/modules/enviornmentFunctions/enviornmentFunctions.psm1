Set-StrictMode -Version Latest
trap { throw $Error[0] }
$ErrorActionPreference = "Stop"

function toStringArray {
    param(
        [Parameter(Mandatory=$true)]
            [ValidateScript({$_.GetType() -in [string],[array],[scriptblock]})]
            [object] $Value
    )

    if($Value -is [string]) {
        $values = @($Value);
    }
    elseif($Value -is [array]) {
        $values = [string[]]$Value;
    }
    else {
        $values = [String[]]$(Invoke-Command $Value)
    }

    return ,$values
}

<#
.SYNOPSIS
    Overrides or Appends to (-Append) environment variable setting it 
    permanently or temporarily (-Tmp).
#>
function Set-EnvironmentVariable {
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true)]
            [string] $Variable,
        [Parameter(Mandatory=$true)]
            [ValidateScript({$_.GetType() -in [string],[array],[scriptblock]})]
            [object] $Value,
        [Parameter(Mandatory=$false)]
            [switch] $Append,
        [Parameter(Mandatory=$false)]
            [string] $Delimiter = ";",
        [Parameter(Mandatory=$false)]
            [ValidateSet("user","machine")]
            [string] $Environment="user",
        [Parameter(Mandatory=$false)]
            [switch] $Tmp
    )

    $valuesToSet = toStringArray $Value
    $original = @()

    if ($Tmp) {
        $original = (Invoke-Expression "`$env:$Variable") -split "$Delimiter"
    }
    else {
        $original = [String[]]$([System.Environment]::GetEnvironmentVariable(
            "$Variable", "$Environment") -split "$Delimiter")
    }

    $toAdd = $valuesToSet | ?{$_ -notin $original}
    $toRemove = $()
    if(!$Append) { $toRemove = $original | ?{$_ -notin $valuesToSet} }

    if($toAdd -or $toRemove) {
        if($Append) {
            $valuesToSet += $original
        }
        $valuesToSet = $valuesToSet.Where({$_ -ne "" }) | Sort-Object -Unique
        $valuesString = [string]::join($Delimiter, $valuesToSet)

        $setterTmp = [ScriptBlock]::Create(
            "`${env:$Variable}=`"$valuesString`"")
        $setterPerm = [ScriptBlock]::Create(
            "[System.Environment]::SetEnvironmentVariable(`"$Variable`"," +
            "`"$valuesString`",`"$Environment`")")

        if($tmp) {
            $setter = $setterTmp
        }
        else {
            $setter = $setterPerm
        }

        Write-Verbose "Setting variable [$Variable] via: $setter"
        if($toAdd) {
            Write-Host "Adding to [$Variable]: $toAdd"
        }
        if($toRemove) {
            Write-Host "Removing from [$Variable]: $toRemove"
        }

        Invoke-Command $setter
        
        # To make permanent changes have direct effect they have to be set tmp
        if (!$tmp) {
            $toSet = [String[]]$([System.Environment]::GetEnvironmentVariable(
                "$Variable", "machine") -split "$Delimiter")
            $toSet += [String[]]$([System.Environment]::GetEnvironmentVariable(
                "$Variable", "user") -split "$Delimiter")
            $toSetString = [string]::join($Delimiter, $toSet)
            Invoke-Expression "`${env:$Variable}=`"$toSetString`""
        }

        return $true
    }

    return $false
}
Register-ArgumentCompleter -CommandName Set-EnvironmentVariable -ParameterName Variable -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (gci env:).Name | ?{$_ -match "^$wordToComplete"}
}
New-Alias -Name sev -Value Set-EnvironmentVariable

<#
    .SYNOPSIS
        Removes either the whole variable from envionment ($value is empty),
        or elements of it which match (with -match via regex).
#>
function Remove-EnvironmentVariable {
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true)]
            [string] $Variable,
        [Parameter(Mandatory=$false)]
            [ValidateScript({$_.GetType() -in [string],[array],[scriptblock]})]
            [object] $Value,
        [Parameter(Mandatory=$false)]
            [ValidateSet("user","machine")]
            [string] $Environment="user",
        [Parameter(Mandatory=$false)]
            [string] $Delimiter=";",
        [Parameter(Mandatory=$false)]
            [switch] $Keep,
        [Parameter(Mandatory=$false)]
            [switch] $Match,
        [Parameter(Mandatory=$false)]
            [switch] $Tmp
    )

    if(!$Value) {
        $variableValue = Invoke-Expression "`${env:$Variable}"
        if(!$variableValue) {
            $variableValue = [Environment]::GetEnvironmentVariable(
                "$Variable","$Environment")
        }
        if($variableValue) {
            if (-Not $Tmp) {
                [Environment]::SetEnvironmentVariable($Variable, '', $Environment)
            }
            $setterTmp = [ScriptBlock]::Create(
                "`${env:$Variable}=`"`"")
            Invoke-Command $setterTmp
            return $true
        }
        else {
            return $false
        }
    }
    else {
        $original = @()

        if ($Tmp) {
            $original = (Invoke-Expression "`$env:$Variable") -split "$Delimiter"
        }
        else {
            $original = [String[]]$([System.Environment]::GetEnvironmentVariable(
                "$Variable", "$Environment") -split "$Delimiter")
        }

        $delta = toStringArray $Value
        $toSet = @()
        foreach($e in $original) {
            $contains = ""
            if($Match) {
                for($i=0; ($i -lt $delta.Length) -and (!$contains); $i++) {
                    $contains = $e -Match $delta[$i]
                }
            }
            else {
                $contains = $delta -contains $e
            }
            if($keep -and $contains -or !$keep -and !$contains) { $toSet += $e }
        }
        if($toSet.Length -ne $original.Length) {
            if (-Not $Tmp) {
                Set-EnvironmentVariable -variable $Variable -Value $toSet `
                    -environment $Environment -delimiter $Delimiter | Out-Null
            }
            $toSetString = $toSet -join "$Delimiter"
            $setterTmp = [ScriptBlock]::Create(
                "`${env:$Variable}=`"$toSetString`"")
            Invoke-Command $setterTmp
            return $true
        }
        else { return $false }
    }
}
New-Alias -Name rev -Value Remove-EnvironmentVariable

Export-ModuleMember -alias * -function *-*
