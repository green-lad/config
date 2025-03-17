param([Parameter(Mandatory=$true)][string]$url)
if(Test-Path $url) {
    Write-Warning "No supported way found to open local file directly over cmd line."
    exit 1
}

start microsoft-edge:$url
