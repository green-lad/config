#todo: get powershell types not filled

$RegistryTypes = @(
    [PSCustomObject]@{
        name = "REG_BINARY"
        value = "Binary"
        description = `
@"
Binary data in any form.
"@
    },

    [PSCustomObject]@{
        name = "REG_DWORD"
        value = "DWord"
        description = `
@"
A 32-bit number.
"@
    }

    [PSCustomObject]@{
        name = "REG_DWORD_LITTLE_ENDIAN"
        value = ""
        description = `
@"
A 32-bit number in little-endian format.
Windows is designed to run on little-endian computer architectures. Therefore, this value is defined as REG_DWORD in the Windows header files.
"@
    }

    [PSCustomObject]@{
        name = "REG_DWORD_BIG_ENDIAN"
        value = ""
        description = `
@"
A 32-bit number in big-endian format.
Some UNIX systems support big-endian architectures.
"@
    }

    [PSCustomObject]@{
        name = "REG_EXPAND_SZ"
        value = "ExpandString"
        description = `
@"
A null-terminated string that contains unexpanded references to environment variables (for example, "%PATH%"). It will be a Unicode or ANSI string depending on whether you use the Unicode or ANSI functions. To expand the environment variable references, use the ExpandEnvironmentStrings function.
"@
    }

    [PSCustomObject]@{
        name = "REG_LINK"
        value = ""
        description = `
@"
A null-terminated Unicode string that contains the target path of a symbolic link that was created by calling the RegCreateKeyEx function with REG_OPTION_CREATE_LINK.
"@
    }

    [PSCustomObject]@{
        name = "REG_MULTI_SZ"
        value = "MultiString"
        description = `
@"
A sequence of null-terminated strings, terminated by an empty string (\0).
The following is an example:
String1\0String2\0String3\0LastString\0\0
The first \0 terminates the first string, the second to the last \0 terminates the last string, and the final \0 terminates the sequence. Note that the final terminator must be factored into the length of the string.
"@
    }

    [PSCustomObject]@{
        name = "REG_NONE"
        value = "None"
        description = `
@"
No defined value type.
"@
    }

    [PSCustomObject]@{
        name = "REG_QWORD"
        value = "QWord"
        description = `
@"
A 64-bit number.
"@
    }

    [PSCustomObject]@{
        name = "REG_QWORD_LITTLE_ENDIAN"
        value = ""
        description = `
@"
A 64-bit number in little-endian format.
Windows is designed to run on little-endian computer architectures. Therefore, this value is defined as REG_QWORD in the Windows header files.
"@
    }

    [PSCustomObject]@{
        name = "REG_SZ"
        value = "String"
        description = `
@"
A null-terminated string. This will be either a Unicode or an ANSI string, depending on whether you use the Unicode or ANSI functions.
"@
    }

)

return $RegistryTypes
