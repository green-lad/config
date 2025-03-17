<#
    .SYNOPSIS
        Reads in a solution file and returns [node] as datastructure representing
        the project tree structure where:
            node ::= { "typeId" = ""; "name" = ""; "path" = ""; "id" = ""; "childs" = [node]; "text" = "" }

    .TODO
        This is only tested on one specific solution and is very likely not working
        generally. More tests are needed.

    .PARAMETER SolutionFile
        - before every subscript ask wether to run it
        - sets $VerbosePreference to "Continue"
#>

[CmdletBinding(DefaultParameterSetName = 'ReadSolution')]
param(
    [Parameter(Mandatory, ParameterSetName = 'CreateOverivew')]
    [Parameter(Mandatory, ParameterSetName = 'CreateSolution')]
    [string] $SolutionFile,

    [Parameter(Mandatory, ParameterSetName = 'CreateSolution')]
    [string] $OverviewFile,
    [Parameter(ParameterSetName = 'CreateSolution')]
    [switch] $WriteSolution
)

Set-StrictMode -Version Latest
trap { throw $Error[0] }

$n = "`r`n"

function Get-ProjectInfo {
    <#
        .SYNOPSIS
            Maps a solutions line to its project name.

        .EXAMPLE
            Get-ProjectInfo ('Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "WkAS", "..\Win32\Source\WkAs\WkAS.vcxproj", "{5B757423-9E3A-4E47-8D17-BA22211844BA}"'+[Environment]::NewLine+'EndProject'

            returns [pscustomobject]@{
                "typeId" = "8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942";
                "name" = "WkAS";
                "path" = "..\Win32\Source\WkAs\WkAS.vcxproj";
                "id" = "5B757423-9E3A-4E47-8D17-BA22211844BA";
                "childs" = [],
                "text" = 'Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "WkAS", "..\Win32\Source\WkAs\WkAS.vcxproj", "{5B757423-9E3A-4E47-8D17-BA22211844BA}"'+[Environment]::NewLine+'EndProject' }
    #>

    param(
        [parameter(mandatory=$true)]
        [string] $line
    )

    $node = @{}
    $namedGroupsRegex = 'Project\("{(?<typeId>.*?)}"\) = "(?<name>.*?)", "(?<path>.*?)", "{(?<id>.*?)}"'
    (Select-String $namedGroupsRegex -input $line).Matches.Groups |
        ?{"groups" -notin $_.PSobject.Properties.Name} |
        %{$node.add($_.name, $_.value)}
    $node.add('childs', @())
    $node.add('text', $line)
    return  [pscustomobject]$node
}

function Get-TreeRepresentation {
    <#
        .SYNOPSIS
            Creates a string from a tree datastructure following this example:
                +--blaasdfasdf
                |  +--blulb
                |  |  +--dsfafd
                |  |  +--dsfafd
                |  |  +--dsfafd
                |  +--blulb
                |  |  +--dsfafd
                |  +--blulb
                |     +--dsfafd
                +--blu
                +--blulb
                |  +--dsfafd
                +--blulb
                   +--blulb
                      +--dsfafd
    #>

    param([pscustomobject[]] $tree)

    $treeLines = New-Object System.Collections.ArrayList
    $separator = "+--"
    $childSeparator = "|  "
    $i = 0
    foreach($node in ($tree | Sort-Object -Property name)) {
        $i += 1
        $treeLines += $separator + $node.name
        if($i -eq $tree.Length) {
            $childSeparator = "   "
        }
        foreach($line in $(Get-TreeRepresentation $node.childs)) {
            $treeLines += $childSeparator + $line
        }
    }
    return $treeLines
}

function Get-Projects {
    param(
        [parameter(mandatory=$true)]
        [String] $content
    )
    $nodes = @{}

    (Select-String -InputObject $content -AllMatches '(?sm)^Project.*?^EndProject').Matches.Value |
        %{$node = Get-ProjectInfo $_; $nodes.add($node.id, $node)}

    return $nodes
}

function Insert-Childs {
    param(
        [parameter(mandatory=$true)]
        [String] $content,
        [parameter(mandatory=$true)]
        [Hashtable] $nodes
    )
    $rNested = '(?smi)GlobalSection\(NestedProjects\) = preSolution.*?EndGlobalSection'
    (Select-String -InputObject $content -Pattern $rNested).Matches.Value -split "`n" |
        Select-String '^\s*{(.*?)}\s*=\s*{(.*?)}' |
        %{$nodes[$_.Matches.Groups[2].value].childs += $nodes[$_.Matches.Groups[1].value]}

    return $nodes
}

$solutionContent = Get-Content $SolutionFile -Raw
$nodes = Get-Projects $solutionContent

if ($OverviewFile) {
    $overview = Get-Content $OverviewFile
    $branchTypeId = "2150E333-8FDC-42A3-9474-1A3956D46DE8"

    # Get Projects
    function Create-Branch {
        param([string] $name, [pscustomobject[]] $childs)
        $guid = (New-Guid).toString().toUpper()
        $text = @"
Project("{{{0}}}") = "{1}", "{1}", "{{{2}}}"
EndProject
"@ -f $branchTypeId, $name, $guid
        return [pscustomobject]@{ "name" = $name; "typeId" = $branchTypeId; "path" = $name; "id" = $guid; "childs" = $childs; "text" = $text }
    }

    $overview_reverse = $overview.clone()
    [array]::Reverse($overview_reverse)
    $i = -1
    $new_nodes = @{}
    $childs = New-Object System.Collections.Stack
    foreach ($line in $overview_reverse) {
        $j = (Select-String -InputObject $line -Pattern '\+--').Matches.Index
        $v = $line -replace '.*\+--', ''
        $isLeaf = $j -ge $i
        $p = $nodes.GetEnumerator() | ?{$_.value.name -eq $v} | Select -first 1
        $node = @{}
        if ($isLeaf) {
            if (-not $p -or ($p.value.typeId -eq $branchTypeId)) {
                throw "Unknown project [$v] in overview file. It is needed as information source for its typeId, path and id."
            }
            $node = $p.value
            if ($j -gt $i) {
                $childs.Push(@{"indent" = $j; "value" = @($node)})
            }
            else {
                $neighbours = $childs.Pop()
                $neighbours.value += $node
                $childs.Push($neighbours)
            }
        }
        else {
            $node_childs = $childs.Pop().value
            [array]::Reverse($node_childs)
            if ($p -and ($p.value.typeId -eq $branchTypeId)) {
                $node = $p.value
                $node.childs = $node_childs
            }
            else {
                $node = Create-Branch $v $node_childs
            }
            if (($childs.Count -eq 0) -or ($childs.Peek().indent -ne $j)) {
                $childs.Push(@{"indent" = $j; "value" = @($node)})
            }
            else {
                $neighbours = $childs.Pop()
                $neighbours.value += $node
                $childs.Push($neighbours)
            }
        }
        $new_nodes[$v] = $node
        $i = $j
    }
    $root_childs = $childs.Pop().value
    [array]::Reverse($root_childs)

    # Replace Projects
    $solutionContent = $solutionContent -replace "(?ms)^Project.*^EndProject$n", ((($overview -replace '.*\+--', '' | %{$new_nodes[$_].text}) -join $n) + $n)

    # Replace NestedProjects references
    function Get-ReferencesTraversingPrefix {
        param([pscustomobject[]] $childs, [pscustomobject] $parent)
        [array]::Reverse($nodes)
        $references = New-Object System.Collections.ArrayList
        foreach ($node in $childs) {
            if($parent) {
                $references.Add(("`t`t{{{0}}} = {{{1}}}" -f $node.id, $parent.id)) | out-null
            }
            Get-ReferencesTraversingPrefix $node.childs $node | %{$references.Add($_)} | out-null
        }
        return $references
    }
    $solutionContent = $solutionContent -replace "(?m)(?<=^\sGlobalSection\(NestedProjects\).*$n)(^\s\s.*$n)*(?=^\sEndGlobalSection$n)", (((Get-ReferencesTraversingPrefix $root_childs) -join $n) + $n)
    if (-not $WriteSolution) {
        return $solutionContent
    }
    if ((Get-Content -raw $SolutionFile) -ne $solutionContent) {
        Out-File -InputObject $solutionContent -Path $SolutionFile -NoNewLine
    }
}
else {
    $nodes = Insert-Childs $solutionContent $nodes
    $tree = $nodes.Values | ?{$_ -notin $nodes.Values.Childs}
    return (Get-TreeRepresentation $tree)
}
