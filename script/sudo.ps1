param (
    [Parameter(Mandatory=$false)]
    [scriptblock] $cmd
)

function isAdmin {
    return [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).
        groups -match "S-1-5-32-544")
}

if(!$(isAdmin)) {
    # Invoke-Command can't self elevate, also a policy has to be changed
    # Start-Process does strange things with quotes scriptblock inside
        # -argumentlist
    if($cmd) {
        $cmd=[ScriptBlock]::Create("cd $((gi .).fullname);" + $cmd.ToString() + "; Read-Host")
        $args="-command $cmd"
    }
    else {
        $args="-noexit -command cd '$((gi .).fullname)'"
    }
    $currentlyUsedShellName=(Get-Process -ID $PID).ProcessName
    Start-Process $currentlyUsedShellName -Verb runAs -ArgumentList $args
}
elseif($cmd) {
    Invoke-Command $cmd
}
