param(
    [Parameter(Mandatory)]  
    [ValidateSet('CAPSLOCK','NUMLOCK','SCROLLOCK')]
    [string] $key
)

(New-Object -ComObject WScript.Shell).SendKeys('{{{0}}}' -f $key)
