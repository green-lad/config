# source: https://stackoverflow.com/questions/68726964/html-table-to-csv
# adapted from: https://www.leeholmes.com/blog/2015/01/05/extracting-tables-from-powershells-invoke-webrequest/
[CmdletBinding(DefaultParameterSetName = 'ByIndex')]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [Microsoft.PowerShell.Commands.HtmlWebResponseObject]$WebRequest,

    [Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'ByIndex')]
    [int]$TableIndex = 0,

    [Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'ById')]
    [string]$TableId,

    [Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'ByName')]
    [string]$TableName,

    [Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'ByClass')]
    [string]$TableClassName
)

# Extract the table out of the web request
switch ($PSCmdlet.ParameterSetName) {
    'ById'    { $table = $WebRequest.ParsedHtml.getElementByID($TableId) }
    'ByIndex' { $table = @($WebRequest.ParsedHtml.getElementsByTagName('table'))[$TableIndex]}
    'ByName'  { $table = @($WebRequest.ParsedHtml.getElementsByName($TableName))[0] }
    'ByClass' { $table = @($WebRequest.ParsedHtml.getElementsByClassName($TableClassName))[0] }
}
if (!$table) {
    Write-Warning "Could not find the given table."
    return $null
}

# load the System.Web assembly to be able to decode HTML entities
Add-Type -AssemblyName System.Web

$headers = @()
# Go through all of the rows in the table
foreach ($row in $table.Rows) {
    $cells = @($row.Cells)
    # If there is a table header, remember its titles
    if($cells[0].tagName -eq "TH") {
        $i = 0
        $headers = @($cells | ForEach-Object {
            $i++
            # decode HTML entities and double-up quotes that the value may contain
            $th = ([System.Web.HttpUtility]::HtmlDecode($_.InnerText) -replace '"', '""').Trim()
            # if the table header is empty, create it
            if ([string]::IsNullOrEmpty($th)) { "H$i" } else { $th }
        })
        # proceed with the next row
        continue
    }
    # if we haven't found any table headers, make up names "H1", "H2", etc.
    if(-not $headers) {
        $headers = @(1..($cells.Count + 2) | ForEach-Object { "H$_" })
    }

    # Now go through the cells in the the row. For each, try to find the
    # title that represents that column and create a hashtable mapping those
    # titles to content
    $hash = [Ordered]@{}
    for ($i = 0; $i -lt $cells.Count; $i++) {
        # decode HTML entities and double-up quotes that the value may contain
        $value = ([System.Web.HttpUtility]::HtmlDecode($cells[$i].InnerText) -replace '"', '""').Trim()
        $th = $headers[$i]
        $hash[$th] = $value.Trim()
    }
    # And finally cast that hashtable to a PSCustomObject
    [PSCustomObject]$hash
}
