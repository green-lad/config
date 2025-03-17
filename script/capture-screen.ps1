param
(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateScript({($_ -match "((.*)[\\\/])?([^\\\/]+\.bmp)") -and (!($Matches[2]) -or (Test-Path -PathType container $Matches[2]))})]
    [string] $FilePath,
    [Parameter(Mandatory=$false, Position=1)]
    [float] $Start = 0,
    [Parameter(Mandatory=$false, Position=2)]
    [float] $End = 1.0,
    [Parameter(Mandatory=$false, Position=3)]
    [float] $Top = 0,
    [Parameter(Mandatory=$false, Position=4)]
    [float] $Bottom = 1.0
)

function GetBitmapFilePath {
    param([string] $FilePath)
    $FilePath -match "((.*)[\\\/])?([^\\\/]+\.bmp)" | out-null
    $file = $Matches[3]
    if($Matches.Count -gt 2) {
        $folder = (gi $Matches[2]).Fullname
    }
    else {
        $folder = (gi ".").fullname
    }
    return "$folder\$file"
}

$ErrorMessage = ""
$FilePath = GetBitmapFilePath $FilePath
if ($End -le $Start) {
    $ErrorMessage += "-Start [$Start] has to be less than -End [$End]`n"
}
if ($Bottom -le $Top) {
    $ErrorMessage += "-Top [$Top] has to be less than -Bottom [$Bottom]`n"
}
if (($End -gt 1) -or ($Start -gt 1) -or ($Top -gt 1) -or ($Bottom -gt 1)) {
    $ErrorMessage += "-Start [$Start], -End [$End], -Top [$Top], -Bottom [$Bottom] have to be smaller equal 1`n"
}

if ($ErrorMessage) {
    Write-Host -foregroundcolor "Red" "$ErrorMessage"
    exit 1
}

Add-Type -AssemblyName System.Windows.Forms
Add-type -AssemblyName System.Drawing
$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
$Width = $Screen.Width * ($End - $Start)
$Height = $Screen.Height * ($Bottom - $Top)
$File = 
$TopScreen = $Screen.Height * $Top
$LeftScreen = $Screen.Width * $Start
$bitmap = Invoke-Expression "New-Object System.Drawing.Bitmap $Width, $Height"
$graphic = [System.Drawing.Graphics]::FromImage($bitmap)
$graphic.CopyFromScreen($LeftScreen, $TopScreen, 0, 0, $bitmap.Size)
$bitmap.Save($FilePath)
$FilePath
