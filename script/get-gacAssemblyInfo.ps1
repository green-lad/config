$assembly = [Reflection.Assembly]::ReflectionOnlyLoad("$assemblyName,Version=4.0.0.0,Culture=neutral,PublicKeyToken=cbc631f1c682336b");
$versionInfo = [Diagnostics.FileVersionInfo]::GetVersionInfo($assembly.Location)
Write-Host "$($assemblyName):`t$($versionInfo.ProductVersion)"
