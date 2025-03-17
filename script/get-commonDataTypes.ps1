<#
.SYNOPSIS
Outputs common used native powershell data types.

.NOTES
Cases are irrelevant.

#>

$CommonDataTypes = @(
    [PSCustomObject]@{
        name = "Array"
        description = `
@"
Array
"@
    },
    [PSCustomObject]@{
        name = "Bool"
        description = `
@"
TRUE or FALSE
"@
    },
    [PSCustomObject]@{
        name = "DateTime"
        description = `
@"
Date and time
"@
    },
    [PSCustomObject]@{
        name = "Guid"
        description = `
@"
Globally unique 32-byte identifier
"@
    },
    [PSCustomObject]@{
        name = "HashTable"
        description = `
@"
Hash table, collection of key-value pairs
"@
    },
    [PSCustomObject]@{
        name = "Int32/Int"
        description = `
@"
32-bit integers
"@
    },
    [PSCustomObject]@{
        name = "PsObject"
        description = `
@"
PowerShell object
"@
    },
    [PSCustomObject]@{
        name = "Regex"
        description = `
@"
Regular expression
"@
    },
    [PSCustomObject]@{
        name = "ScriptBlock"
        description = `
@"
PowerShell script block
"@
    },
    [PSCustomObject]@{
        name = "Single/Float"
        description = `
@"
Floating point number
"@
    },
    [PSCustomObject]@{
        name = "String"
        description = `
@"
String
"@
    },
    [PSCustomObject]@{
        name = "Switch"
        description = `
@"
PowerShell switch parameter
"@
    },
    [PSCustomObject]@{
        name = "TimeSpan"
        description = `
@"
Time interval
"@
    },
    [PSCustomObject]@{
        name = "XmlDocument"
        description = `
@"
"@
    }
)

return $CommonDataTypes
