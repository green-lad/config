param(
    [string]$name, [string]$root, [switch]$Force
)

Set-StrictMode -Version Latest
trap { throw $Error[0] }
$ErrorActionPreference = "Stop"

$networkDrives = @(
    @{
        name="G";
        root="\\somenetworkdrive"
    };
)

if(($name -and !$root) -or (!$name -and $root)) {
    throw "if given, name and root have to be present"
    exit 1
}

if($name) {
    $networkDrives = @(@{name=$name;$root=root})
}

$changed = $false

$existingDrives = Get-PsDrive
foreach($drive in $networkDrives) {
    Write-Host "Check setting drive [$(($drive).name)]";
    $inUse = $existingDrives | ?{$_.name -eq $drive.name}
    $set = [ScriptBlock]::Create("New-PSDrive -name $($drive.name) -PSProvider FileSystem -Root $($drive.root) -Persist -Scope Global")
    $remove = [ScriptBlock]::Create("Remove-PSDrive -name $($drive.name)")

    if($inUse -and ($inUse.displayroot -ne $drive.root)){
        if($Force) {
            Write-Host "Removing drive for $($inUse.displayroot) via: $remove"
            Invoke-Command $remove
            $changed = $true
            $inUse = 0
        }
    }
    if(-not ($inUse)){
        Write-Host "Setting drive [$set]."
        Invoke-Command $set
    }
    Write-Host ([Environment]::NewLine)
}

return $changed
