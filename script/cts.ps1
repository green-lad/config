[cmdletbinding()]
param (
    [Parameter(Mandatory=$false)]
    [string] $Branch = "$env:Branch",
    [Parameter(Mandatory=$false)]
    [string] $Domain = "$env:Domain",
    [Parameter(Mandatory=$false)]
    [string] $Subsystem = "$env:Subsystem",
    [Parameter(Mandatory=$false)]
    [int] $Latest = -1,
    [Parameter(Mandatory=$false)]
    [int] $Login = -1,
    [Parameter(Mandatory=$false)]
    [switch] $Admin,
    [Parameter(Mandatory=$false)]
    [switch] $Cd,
    [Parameter(Mandatory=$false)]
    [switch] $Cleanup
)

function Get-LoginTemplate {
    return [PsCustomObject]@{
        user = "user_1";
        user_pass = "";
        admin = "Administrator";
        admin_pass = "";
        ip = "";
        date = "";
        subsystem = "";
        path = "";
        parent = "";
        content = "";
    }
}

function getDropLocation {
    $branchWithDots = $Branch -replace '/', '.'
    return "$env:DropLocationStump.$branchWithDots.$Domain.$Subsystem"
}

function getFirstMatchInFile {
    param([string]$path, [string]$pattern)
    $matchesUserPass = Select-String -Path $path -pattern $pattern
    if($matchesUserPass) {
        return $matchesUserPass[0].matches.groups[1].value
    }
    return ""
}

function getAccessLogs {
    $accessLogs = @()
    $searchPath = "$(getDropLocation)*/*"
    $appendixes = @("logs/Machines/*/*AccessData.txt", "CTS/*AccessData.txt")
    foreach($a in $appendixes) {
        $serachCur = "$searchPath/$a"
        Write-Verbose "Searching in [$searchCur]"
        $accessLogs += gci $serachCur
    }
    return $accessLogs
}

function Get-MachinesFitting {
    $accessLogs = getAccessLogs
    $logins = @()
    if($Latest -ge 0) {
        $accessLogs = $accessLogs | Select-Object -First ($Latest+1) | Select-Object -Last 1
    }
    foreach($accessLog in $accessLogs) {
        $tmp = Get-LoginTemplate
        $tmp.subsystem = $Subsystem
        $tmp.date = $accessLog.LastWriteTime
        $tmp.path = $accessLog.FullName
        $tmp.parent = $accessLog.Directory.FullName
        $tmp.content = gc $accessLog.FullName
        $tmp.user_pass = getFirstMatchInFile -path $tmp.path -pattern `
            "User: $($tmp.user) Password: (.\S*)"
        $tmp.admin_pass = getFirstMatchInFile -path $tmp.path -pattern `
            "User: $($tmp.admin) Password: (.\S*)"
        $tmp.ip = getFirstMatchInFile -path $tmp.path -pattern `
            "IP: (.\S*)"
        $logins += $tmp
    }

    return $logins
}

function Login-RemoteSessionViaTemplate {
    param([PsCustomObject] $template)
    if($Admin) {
        cmdkey.exe /generic:"$($template.ip)" /user:"$($template.admin)" /pass:"$($template.admin_pass)"
    }
    else {
        cmdkey.exe /generic:"$($template.ip)" /user:"$($template.user)" /pass:"$($template.user_pass)"
    }
    mstsc.exe /v:"$($template.ip)"
}

function Cleanup-Cmdkey {
    foreach($line in (cmdkey.exe /list)) {
        if($line -match "Target: (LegacyGeneric:target=[\d\.]+)") {
            cmdkey.exe /delete:"$($Matches[1])"
        }
    }
}

if($Cleanup) {
    Cleanup-Cmdkey
}
else {
    $logins = Get-MachinesFitting
    if(($logins.Count -gt 0) -and ($Login -gt -1)) {
        if($Cd) {
            cd $logins[$Login].parent
        }
        else {
            Login-RemoteSessionViaTemplate -template $logins[$Login]
        }
    }
    else {
        $logins
    }
}
