param(
    [Parameter(Mandatory=$true)]
        [string]$in,
    [int]$indent=2
)

if(Test-Path -Type Leaf $in) {
    $in = gc $in
}

try {
    [xml]$xml = $in
    $StringWriter = New-Object System.IO.StringWriter
    $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter
    $xmlWriter.Formatting = “indented”
    $xmlWriter.Indentation = $Indent
    $xml.WriteContentTo($XmlWriter)
    $XmlWriter.Flush()
    $StringWriter.Flush()
    Write-Output $StringWriter.ToString()
}
catch {
    Write-Warning "Converting to xml failed"
    Write-Host $in
}
