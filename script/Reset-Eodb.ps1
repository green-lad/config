[CmdletBinding()]
param([string] $backupFolder)

Set-StrictMode -Version Latest
trap { throw $Error[0] }

function isAdmin {
    return [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).
        groups -match "S-1-5-32-544")
}

if(!$(isAdmin)) {
    $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    return
}

$database = @{
    "sqlserver" = 'VAA4DAB0264\DATEV_DBENGINE'
    "folder" = "C:\ProgramData\DATEV\daten\EODB\DATA\STANDARD"
    "name" = "EODB"
    "datafile" = "EODB.mdf"
    "logfile" = "EODB.ldf"
    "timeout" = 3600
    "backup_datafile" = ""
    "backup_logfile" = ""
}

function Attach-Db {
    param(
        [string] $sqlserver,
        [string] $folder,
        [string] $name,
        [string] $datafile,
        [string] $logfile,
        [string] $timeout
    )
    $cmd = @"
USE [master]
GO
    CREATE DATABASE [{0}\{1}] ON (FILENAME = '{0}\{2}'),(FILENAME = '{0}\{3}') for ATTACH
GO
"@ -f $folder, $name, $datafile, $logfile
    Invoke-Sqlcmd $cmd -QueryTimeout $timeout -ServerInstance $sqlserver
}

function Detach-Db {
    param(
        [string] $sqlserver,
        [string] $folder,
        [string] $name,
        [string] $timeout
    )
    $cmd = @"
USE [master]
GO
    sp_detach_db '{0}\{1}'
GO
"@ -f $folder, $name
    Invoke-Sqlcmd $cmd -QueryTimeout $timeout -ServerInstance $sqlserver
}

Detach-Db @database
rm ("{0}\{1}" -f $database.folder, $database.datafile)
rm ("{0}\{1}" -f $database.folder, $database.logfile)
mv ("{0}\{1}" -f $backupFolder, $database.datafile)
mv ("{0}\{1}" -f $backupFolder, $database.logfile)
Attach-Db @database
