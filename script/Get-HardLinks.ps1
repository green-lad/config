<#
.SYNOPSIS
    Starting with powershell 7.0.0 getting Targets of of file via one of them
    got removed because of interoperability of powershell on UNIX and NFTS.
    This script implements a way of getting alternative hardlink paths of a given
    hardlink file on NTFS.
.SOURCE
    https://github.com/PowerShell/PowerShell/issues/15139
#>

using namespace Winutil.NTFS

param([string] $file)

$etsProp = @{
    name = "NTFS";
    namespace = "WinUtil";
    usingnamespace = @("System.Text", "System.Collections.Generic", "System.IO");
    memberDefinition = @'
#region WinAPI P/Invoke declarations
[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
static extern IntPtr FindFirstFileNameW(string lpFileName, uint dwFlags, ref uint StringLength, StringBuilder LinkName);

[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
static extern bool FindNextFileNameW(IntPtr hFindStream, ref uint StringLength, StringBuilder LinkName);

[DllImport("kernel32.dll", SetLastError = true)]
static extern bool FindClose(IntPtr hFindFile);

[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
static extern bool GetVolumePathName(string lpszFileName, [Out] StringBuilder lpszVolumePathName, uint cchBufferLength);

public static readonly IntPtr INVALID_HANDLE_VALUE = (IntPtr)(-1); // 0xffffffff;
public const int MAX_PATH = 65535; // Max. NTFS path length.
#endregion

/// <summary>
//// Returns the enumeration of hardlinks for the given *file* as full file paths, if any,
//// excluding the input file itself.
/// </summary>
/// <remarks>
/// If the file has only one hardlink (itself) or the target volume doesn't support enumerating hardlinks,
/// an emtpty sting array is returned.
/// An exception occurs if you specify a non-existent path or a path to a
/// directory (directories don't support hardlinks)
/// </remarks>
public static string[] GetHardLinks(string filePath)
{
string fullFilePath = Path.GetFullPath(filePath);
if (Directory.Exists(fullFilePath))
{
    throw new ArgumentException("Only files support hardlinks, \"" + filePath + "\" is a directory.");
}
StringBuilder sbPath = new StringBuilder(MAX_PATH);
uint charCount = (uint)sbPath.Capacity; // in/out character-count variable for the WinAPI calls.
// Get the volume (drive) part of the target file's full path (e.g., @"C:\")
GetVolumePathName(fullFilePath, sbPath, (uint)sbPath.Capacity);
string volume = sbPath.ToString();
// Trim the trailing "\" from the volume path, to enable simple concatenation
// with the volume-relative paths returned by the FindFirstFileNameW() and FindFirstFileNameW() functions,
// which have a leading "\"
volume = volume.Substring(0, volume.Length > 0 ? volume.Length - 1 : 0);
// Loop over and collect all hard links as their full paths.
IntPtr findHandle;
if (INVALID_HANDLE_VALUE == (findHandle = FindFirstFileNameW(fullFilePath, 0, ref charCount, sbPath)))
{
    if (! File.Exists(fullFilePath))
    {
    throw new FileNotFoundException("File not found: " + filePath);
    }
    // Otherwise: the target volume doesn't support enumerating hardlinks.
    return Array.Empty<string>();
}
List<string> links = new List<string>();
do
{
    string fullHardlinkPath = volume + sbPath.ToString();
    if (! fullHardlinkPath.Equals(fullFilePath, StringComparison.OrdinalIgnoreCase)) 
    {
    links.Add(fullHardlinkPath); // Add the full path to the result list.
    }
    charCount = (uint)sbPath.Capacity; // Prepare for the next FindNextFileNameW() call.
} while (FindNextFileNameW(findHandle, ref charCount, sbPath));
FindClose(findHandle);
return links.ToArray();
}
'@
}

if(-not (([System.Management.Automation.PSTypeName]('{0}.{1}' -f `
    $etsProp.namespace, $etsProp.name)).Type)) {
    Add-Type @etsProp
}

return [WinUtil.NTFS]::GetHardLinks($file)
