<#
.SYNOPSIS
    Module to set set/remove registry entries, via checking their existence,
    returning $true if changes where made
#>

function Remove-RegistryEntry {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
            [string] $Path,
        [Parameter(Mandatory=$false)]
            [string] $Name,
        [Parameter(Mandatory=$false)]
            [string] $About,
        [Parameter(Mandatory=$false)]
            [string] $ActiveAfter
    )

    $ErrorActionPreference = "Stop"

    if(Test-Path $Path) {
        try {
            if($Name -and (Get-ItemProperty -LiteralPath $Path).$Name) {
		Write-Host @"
Removing registry entry [${Name}] at [${Path}]:
	${About}
	Active after: ${ActiveAfter}"
"@
                Remove-ItemProperty -Path $Path -Name $Name
                return $true
            }
            else {
		Write-Host @"
Removing registry entry [${Name}] at [${Path}] recursive:
	${About}
	Active after: ${ActiveAfter}"
"@
                Remove-Item -recurse -Path $Path
                return $true
            }
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    
    return $false
}

function Get-ItemPropertiesRecurse {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
            [string] $Path,
        [Parameter(Mandatory=$false)]
            [string[]]$ignore=
                @(
                    "(default)",
                    "PSProvider",
                    "PSPath","PSDrive",
                    "PSChildName",
                    "PSParentPath"
                )
    )
    $properties=@{}
    (gp $Path).psobject.properties | %{if(!$properties.ContainsKey($_.Name) -and !$ignore.Contains($_.Name)){$properties[$_.Name]=$_.Value}}
    foreach($child in (gci $Path)) {
        $recProps=Get-ItemPropertiesRecurse "$Path/$($child.PSChildName)"
        foreach($key in $recProps.Keys) {
            if(!$properties.ContainsKey($key)) {
                $properties[$key]=$recProps[$key]
            }
        }
    }
    return $properties
}

<#
.SYNOPSIS
    Tries to create registry entry via given parameters.
.RETURN
    $false: entry under $path/$value already existed / creating entry failed
    $true: else
#>
function Set-RegistryEntry {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
            [string] $Path,
        [Parameter(Mandatory=$true)]
            [object] $Value,
        [Parameter(Mandatory=$true)]
            [string] $Name,
        [Parameter(Mandatory=$true)]
            [string] $Type,
        [Parameter(Mandatory=$false)]
            [string] $About,
        [Parameter(Mandatory=$false)]
            [string] $ActiveAfter
    )

    $ErrorActionPreference="Stop"
    $changed = $false

    try {
        if(!(Test-Path -PathType Container -LiteralPath $Path)) {
            Write-Host "Creating registry path ${path}"
            New-Item -Path $Path -Force
            $changed = $true
        }
        $inReg = (Get-ItemProperty -LiteralPath $Path).$Name
        if(($inReg -eq $null) -or ((Compare-Object $inReg $value).Length -gt 0)) {
            Write-Host ""
		Write-Host @"
Creating new registry entry [${Name}] at [${Path}]:
	${About}
	Active after: ${ActiveAfter}"
"@
            if(New-ItemProperty -LiteralPath $Path -Name $Name -Value $Value -PropertyType $Type -Force) {
                $changed = $true
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }

    return $changed
}
