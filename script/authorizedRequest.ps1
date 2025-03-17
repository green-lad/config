param(
    [Parameter(Mandatory=$true)]
    [string]$url,
    [Parameter(Mandatory=$false)]
    [ValidateScript({ @("default","delete","get","head","merge","options","patch","post","put","trace").Contains($_.ToLower()) })]
    [string]$Method="default",
    [Parameter(Mandatory=$false)]
    [string]$user = "$env:USERNAME",
    [Parameter(Mandatory=$false)]
    [string]$pass = "",
    [Parameter(Mandatory=$false)]
    [string]$apiKeyArtifactory = ""
)

function get-passwdheader {
    $pair = "$($user):$($pass)"

    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

    $basicAuthValue = "Basic $encodedCreds"
    return @{ Authorization = $basicAuthValue }
}

function get-apikeyheaderartifactory {
    return @{'Accept' = 'application/json'; 'X-JFrog-Art-Api' = $apiKeyArtifactory}
}

if($pass) { $headers = get-passwdheader }
elseif($apiKeyArtifactory) { $headers = get-apikeyheaderartifactory }

Invoke-WebRequest -Uri "$url" -Headers $headers -Method $Method
