# general functions

if((get-alias cd 2>$null) -ne $null){
    del alias:cd -Force
}

function IIf($If, $IfTrue, $IfFalse) {
    If ($If) {If ($IfTrue -is "ScriptBlock") {&$IfTrue} Else {$IfTrue}}
    Else {If ($IfFalse -is "ScriptBlock") {&$IfFalse} Else {$IfFalse}}
}

function returnTrue
{
    return $TRUE
}

function returnFalsePrintError
{
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory=$false, Position=7)]
        [string] $errorMessage = $true
    )

    Write-Host -ForegroundColor Red "$errorMessage"
    return $false
}

function displayPicture
{
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript({ Test-Path $_ })]
        [string] $path
    )
# used from: https://gist.github.com/zippy1981/969855
    [void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")

    $file = (get-item "$path")

    $img = [System.Drawing.Image]::Fromfile($file);

# This tip from http://stackoverflow.com/questions/3358372/windows-forms-look-different-in-powershell-and-powershell-ise-why/3359274#3359274
    [System.Windows.Forms.Application]::EnableVisualStyles();
    $form = new-object Windows.Forms.Form
    $form.Text = "Image Viewer"
    $form.Width = $img.Size.Width;
    $form.Height =  $img.Size.Height;
    $pictureBox = new-object Windows.Forms.PictureBox
    $pictureBox.Width =  $img.Size.Width;
    $pictureBox.Height =  $img.Size.Height;

    $pictureBox.Image = $img;
    $form.controls.add($pictureBox)
    $form.Add_Shown( { $form.Activate() } )
    $form.ShowDialog()
#$form.Show();
}

function ascii
{
    # $tablength=8
    # $columns=1
    # if ($args[0])
    #     $columns=$args[0]
    for ($i = 0; $i -le 255; $i++)
    {
        Write-Host Zeichen $($i): $([char]$i)
    }
}

function makeAdmin
{
# Get the ID and security principal of the current user account
 $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
 $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
  
 # Get the security principal for the Administrator role
 $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
  
 # Check to see if we are currently running "as Administrator"
 if ($myWindowsPrincipal.IsInRole($adminRole))
    {
    # We are running "as Administrator" - so change the title and background color to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    clear-host
    }
 else
    {
    # We are not running "as Administrator" - so relaunch as administrator
    
    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    
    # Specify the current script path and name as a parameter
    # $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    
    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";
    
    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);
    
    # Exit from the current, unelevated, process
    exit
    }
  
 # Run your code that needs to be elevated here
 Write-Host -NoNewLine "Press any key to continue..."
 $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function adminShell
{
    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "Cmder";
    
    # Specify the current script path and name as a parameter
    # $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    # $Arguments = $myInvocation.MyCommand.Definition;
    # $Arguments
    
    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";
    
    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);
}

function checkAdmin
{
    # Get the ID and security principal of the current user account
    $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
    
    # Get the security principal for the Administrator role
    $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
    return $myWindowsPrincipal.IsInRole($adminRole)
}

function sudo { 
    if ($args){
        Start-Process powershell -Verb runAs $args 
    }
    else{
        Start-Process powershell -Verb runAs
    }
}

function regexMatch([string[]]$toMatch, [string]$in)
{
    $i=0
    while($toMatch){
        $current, $toMatch = $toMatch
        if($current -like $in){
            return $i
        }
        $i+=1
    }
    return -1
}

function testUrl
{
    [CmdletBinding()]
 
    param (
        [Parameter(Mandatory=$true)]
        [String] $url
    )
 
    Process {
        return [system.uri]::IsWellFormedUriString($url,[System.UriKind]::Absolute)
    }
}

function openBrowser
{
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript({ testUrl $_ })]
        [string] $url
    )

    # open in new tab
            Start-Process $url

    # capable of opening it the first time in new browser and then in new tab
            # $IE= new-object -ComObject "InternetExplorer.Application"
            # $IE.Navigate("http://www.google.com/", 2048)
            
    # open in new browser
            # $IE= new-object -ComObject "InternetExplorer.Application"
            # $IE.navigate2("$chosen")
}

function listDir
{
    param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [string] $path = "."
    )

    # NOTE
    # to get types available for object use: Write-Host ($childItems | Format-list | Out-String)

    foreach($line in $(gci $path)){
        Write-Host -NoNewline -ForegroundColor $global:color $line.mode "`t"
        Write-Host -NoNewline $line.lastwritetime "`t"
        Write-Host -NoNewline $line.length "`t"
        Write-Host $line.name
    }
    Write-Host 
}

function RemoveDotsInPath {
  [cmdletbinding()]
  Param
  (
    [Parameter(Position=0,  Mandatory=$true)]
    [string] $PathString = ''
  )

  $newPath = $PathString -creplace '(?<grp>[^\n\\]+\\)+(?<-grp>\.\.\\)+(?(grp)(?!))', ''
  return $newPath
}

function Format-Xml {
<#
.SYNOPSIS
Format the incoming object as the text of an XML document.
#>
    param(
        ## Text of an XML document.
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$Text
    )

    begin {
        $data = New-Object System.Collections.ArrayList
    }
    process {
        [void] $data.Add($Text -join "`n")
    }
    end {
        $doc=New-Object System.Xml.XmlDataDocument
        $doc.LoadXml($data -join "`n")
        $sw=New-Object System.Io.Stringwriter
        $writer=New-Object System.Xml.XmlTextWriter($sw)
        $writer.Formatting = [System.Xml.Formatting]::Indented
        $doc.WriteContentTo($writer)
        $sw.ToString()
    }
}

function makeExternLink
{
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript({ testUrl $_ })]
        [string] $url
    )

    $x = $url.LastIndexOf("://") + 3
    return [string] -join($($url.Substring(0,$x)),"i/",$($url.Substring($x)))
}

# starting powershell with runas in different modes
function startup {
    # startup.bat: powershell.exe -windowstyle minimized ~\dotfiles\powershell\startup\startup.ps1 %1 %2 %3

    param (
        [Parameter(Mandatory=$false, Position=0)]
        [switch] $cmd,
        [Parameter(Mandatory=$false, Position=0)]
        [switch] $sudo,
        [Parameter(Mandatory=$false, Position=0)]
        [switch] $dev
    )

    $developerCommand = & "$PSScriptRoot\..\script\Get-DeveloperCommandCmd.ps1"
    $powershellArgs = "-noexit -command ~\profile.ps1"

    if($cmd) {
        $argumentList = "powershell.exe $powershellArgs"
        if($dev){
            $argumentList = "`"`"$developerCommand`" & $argumentList`""
        }
        Write-Host $argumentList
        if($sudo) {
            start-process cmd.exe -verb runas -ArgumentList "/c $argumentList" -WindowStyle maximized
        }
        else {
            start-process cmd.exe -ArgumentList "/c $argumentList" -WindowStyle maximized
        }
    }
    else {
        if($sudo) {
            start-process powershell.exe -verb runas -ArgumentList "$powershellArgs"
        }
        else {
            start-process powershell.exe -ArgumentList "$powershellArgs"
        }
    }
}
