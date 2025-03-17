param(
    [string]$tfsUrl="j",
    [string]$tfsFile="",
    [string]$outFilePath="",
    [int]$adminNeeded=1,
    [int]$debug=0
)

function Get-TfsApiUriForDownloading {
    param (
        [Parameter(Mandatory=$true)]
        [string] $tfsUrl,
        [Parameter(Mandatory=$true)]
        [string] $tfsFilePath
	)
	return "$tfsUrl/_apis/tfvc/items?path=$tfsFilePath"
}

function getFullPathWithoutCheckingIfExists {
	param(
        [Parameter(Mandatory=$true)]
        [string] $path
	)
	$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

function isAdmin {
    return [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).
        groups -match "S-1-5-32-544")
}

$outFilePath = getFullPathWithoutCheckingIfExists $outFilePath

if($adminNeeded -and !$(isAdmin)) {
    $CommandName = $MyInvocation.InvocationName;
    $ParameterList = (Get-Command -Name $CommandName).Parameters;
	$vars = Get-Variable -Name $ParameterList.Values.Name -ErrorAction SilentlyContinue;
	$boundArguments = ""
	$commandLine = ""
	if($debug) {
		$commandLine += "-noexit "
	}
	foreach($var in $vars) {
		if($var -and $var.value) {
			$boundArguments += "-$($var.name) `"$($var.value)`" "
		}
    }
    $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $boundArguments + $MyInvocation.UnboundArguments
    if($debug) {
        Write-Host $CommandLine
    }
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    if($debug) {
        Read-Host
    }
}
else {
	$uri = Get-TfsApiUriForDownloading $tfsUrl $tfsFile
	Write-Host "Downloading from [$uri] to [$outFilePath]"
	invoke-webrequest -uri $uri -Method get -UseDefaultCredentials -OutFile $outFilePath
	Read-Host "Download successful, you can close the window"
}

