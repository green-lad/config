param([Parameter(Mandatory=$true)][string]$url)
$pathChrome=(get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(default)'
& $pathChrome $url
