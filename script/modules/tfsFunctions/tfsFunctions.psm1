function private:Update-PowershellTlsProtocolVersion{
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateScript({ @("tls12, tls11, tls").Contains($_) })]
        [string] $version = "tls12"
        )
    [Net.ServicePointManager]::SecurityProtocol = $version
}

function Get-FolderContentFromTfsPath {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $path,
        [Parameter(Mandatory=$false, Position=1)]
        [switch] $folder,
        [Parameter(Mandatory=$false, Position=2)]
        [switch] $skim
    )
    $tfsUrl = Get-TfsUrl
    $found = ((iwr -Uri "$tfsUrl/_apis/tfvc/items?scopepath=$path" -Method GET -UseDefaultCredentials).content | ConvertFrom-Json).value
    if($folder) {
        $found = $found | where {$_.isFolder}
    }
    $ret = $found | %{$_.path}
    if($skim) {
        $ret = $ret | %{$_ -replace ([Regex]::Escape("$path")+"[\/]"), ''}
    }
    if($found -and $found[0].isFolder) {
        $ret = $ret | select -skip 1
    }

    return $ret
}

function Test-TfsItemExists {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $item,
        [Parameter(Mandatory=$false, Position=1)]
        [switch] $isFolder
    )
    try {
        $tfsUrl = Get-TfsUrl
        $ret = (iwr -Uri "$tfsUrl/_apis/tfvc/items?path=$item" -Method GET -UseDefaultCredentials).content
        if($ret) {
            if($isFolder) {
                return ($ret | ConvertFrom-Json).isFolder
            }
            return $true
        }
    }
    catch {
        return $false
    }
}

function Get-TfsUrl {
    while(!$env:TFS) {
        $potUrl = Read-Host "Specify TFS URL:"
        $uri = $potUrl -as [System.URI]
        if($uri.AbsoluteURI -ne $null -and $uri.Scheme -match '[http|https]') {
            [System.Environment]::SetEnvironmentVariable("TFS", $uri.AbsoluteURI, "User")
        }
        else {
            Write-Host "Invalid URL, try again or abort with Ctrl-c"
        }
    }
    return $env:TFS
}

function Update-TfsFile {
    param(
        [string]$tfsFile="$/OnPremise/OnPremise/next/next-main/EO/RSCL/DotNet/MainLib/Datev.Korg.MainLib.Messages-de-DE.xml",
        [string]$outFilePath="C:\Program Files (x86)\DATEV\PROGRAMM\K0000064\Datev.Korg.MainLib.Messages-de-DE.xml"
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

    $outFilePath = getFullPathWithoutCheckingIfExists $outFilePath

    $tfsUrl = Get-TfsUrl
    $uri = Get-TfsApiUriForDownloading $tfsUrl $tfsFile
    Write-Host "Downloading from [$uri] to [$outFilePath]"
    invoke-webrequest -uri $uri -Method get -UseDefaultCredentials -OutFile $outFilePath
    Write-Host "Download successful"
}

function Find-Tfs {
    param(
        [Parameter(Mandatory=$false)]
        [string] $path = "$/OnPremise/OnPremise/dev/dev-main",
        [Parameter(Mandatory=$true)]
        [string] $term,
        [Parameter(Mandatory=$false)]
        [string] $project = 'OnPremise',
        [Parameter(Mandatory=$false)]
        [string] $repository = '$/OnPremise'
    )
    
	# $tfsUrl = (Get-TfsUrl) -replace "/\w+/?$"
	$tfsUrl = (Get-TfsUrl)

    $searchParams = @{
		'searchText' = "$term";
		'$skip' = 0;
		'$top' = 1000;
		'filters' = @{
			'Project' = @(
			 	"$project"
			);
			'Repository' = @(
			 	"$repository"
			);
			# 'Branch' = @(
			# 	"master"
			# );
			# 'CodeElement' = @(
			# 	"def",
			# 	"class"
			# );
			'Path' = @(
				"$path"
			)
		};
		'$orderBy' = @(
			@{
				'field' = "filename";
				'sortOrder' = "ASC"
			}
		);
		'includeFacets' = "true"
	}
	$reqUri = "$tfsUrl/_apis/search/codesearchresults?api-version=5.0-preview"
	Write-Host "Searching via [$reqUri]"
    $res = (iwr -Uri $reqUri -Method POST -Body ($searchParams|ConvertTo-Json) -ContentType "application/json" -UseDefaultCredentials)
    (($res.Content) | convertfrom-json).results
}
