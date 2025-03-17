param(
    [ValidateScript({Test-Path -type container $_})]
    [string]$fromDir = "D:\g.op.dev.dev-main\eo\rea",
    [ValidateScript({Test-Path -type container $_})]
    [string]$toDir = "D:\g.op.dev.fb.intermediate\eo\rea",
    [switch]$doIt
)

# be strict with error and fail fast
Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"
trap { throw $Error[0] }

if (-not (Test-Path -type Container $fromDir)) {
    Write-Error "Local folder at [$fromDir] to copy stuff from does not exist."
}

if (-not (Test-Path -type Container $toDir)) {
    Write-Error "Local folder at [$toDir] to copy stuff to does not exist."
}

$includeFileExtensions = @(
    '*.sln',
    '*.xml',
    '*.config',
    '*.json',

    '*.csproj',
    '*.cs',

    '*.vcxproj',
    '*.cpp',
    '*.h'
)

# exclude any file that is is in at least one of the following subfolders (after the fromDir starting point, see second example)
#   example:
#       $fromDir = D:\abc
#       file that would get excluded: D:\abc\de\obj\fgh\test.cs
#
#   example:
#       $fromDir = D:\obj
#       file that would not get excluded: D:\obj\fgh\test.cs
$excludeSubdirs = @(
    'obj',
    'Tools'
)

function filesDifferInContent {
    param (
        [string]$a,
        [string]$b
    )
    $ha = (Get-FileHash "$a" -Algorithm MD5).Hash
    $hb = (Get-FileHash "$b" -Algorithm MD5).Hash
    return $ha -ne $hb
}

function getChildsWithFilters {
    param([string]$dir, [string[]]$includeFileExtensions, [string[]]$excludeSubdirs)
    return gci -Recurse $dir -Include $includeFileExtensions | %{$_.fullname -replace [Regex]::Escape($dir), ""} | ?{-not ($_ -split '\\' | ?{$_ -in $excludeSubdirs})}
}
$fromItems = getChildsWithFilters $fromDir $includeFileExtensions $excludeSubdirs
$toItems = getChildsWithFilters $toDir $includeFileExtensions $excludeSubdirs

$toAdd = $fromItems | ?{$_ -notin $toItems}
$toRemove = $toItems | ?{$_ -notin $fromItems} | %{Join-Path $toDir $_}
$filesDiffering = $toItems | ?{$_ -in $fromItems} | ?{filesDifferInContent (Join-Path $fromDir $_) (Join-Path $toDir $_)}

if ($doIt) {
    $toAdd | %{
        $fromFile = Join-Path $fromDir $_;
        $toFile = Join-Path $toDir $_;
        cp $fromFile $toFile
    }
    tf add ($toAdd | %{Join-Path $toDir $_})

    tf delete ($toRemove | %{Join-Path $toDir $_})

    tf checkout ($filesDiffering | %{Join-Path $toDir $_})
    $filesDiffering | %{
        $fromFile = Join-Path $fromDir $_;
        $toFile = Join-Path $toDir $_;
        cp $fromFile $toFile
    }
}
else {
    Write-Host -foregroundcolor green "Adding:"
    Write-Host ($toAdd | %{Join-Path $toDir $_})
    Write-Host
    Write-Host -foregroundcolor green "removing:"
    Write-Host ($toRemove | %{Join-Path $toDir $_})
    Write-Host
    Write-Host -foregroundcolor green "changing content:"
    Write-Host ($filesDiffering | %{Join-Path $toDir $_})
    Write-Host -foregroundcolor green "nothing done, execute tf commands via -doIt"
}
