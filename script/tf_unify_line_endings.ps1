param(
    [ValidateScript({Test-Path -type container $_})]
    [string]$dir = "D:\g.op.dev.fb.intermediate\eo\rea"
)

# be strict with error and fail fast
Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"
trap { throw $Error[0] }

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
    'obj'
)

$itemsToUnify = gci -Recurse $dir -Include $includeFileExtensions | ?{-not ((($_.fullname -replace [Regex]::Escape($dir), "") -split '\\') | ?{$_ -in $excludeSubdirs})}

# data for testing
# $itemsToUnify = @(
#     "D:\g.op.dev.dev-main\eo\rea\src\client\presentation\TestERechnungEMailConfigurationDialogPresenter.cs",
#     "D:\g.op.dev.dev-main\eo\rea\src\client\presentation\SaveFileDialogWrapper.cs"
# )

$regexMissingCarriage = '(?<!\r)\n'

foreach ($item in $itemsToUnify) {
    $content = get-content $item -raw
    if ([regex]::IsMatch($content, $regexMissingCarriage)) {
        tf checkout $item
        set-content $item ([regex]::Replace($content, $regexMissingCarriage, "`r`n"))
    }
}
