[CmdletBinding()]
param([switch] $never, [string]$bla)

function isAdmin {
    return [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).
        groups -match "S-1-5-32-544")
}

if(!$(isAdmin)) {
    # does not work for switches ...
    # $boundArguments = ($PSBoundParameters.Keys | %{"-$_ " + $PSBoundParameters[$_]}) -join " "
    $boundArguments = "-never:`$$never"
    $ProcArgs = @{
        FilePath = 'powershell.exe'
        Verb = 'RunAs'
        ArgumentList = "-command `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments + " " + $boundArguments
    }
    Start-Process @ProcArgs
    return
}

if ($never) {
    $value = 'Never'
}
else {
    $value = 'Always'
}

Set-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\DATEVeG\Components\B0001613\Versions\1.0\AdditionalInfos\Exceptions' -Name autosend -Value $value
