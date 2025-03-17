<#
.SYNOPSIS
    Creates a 'Scancode Map' which is used by windows to remap keyinputs.

.LINK
    http://www.winfaq.de/faq_html/Content/tip1500/onlinefaq.php?h=tip1575.htm
#>

param (
    [Parameter(Mandatory = $true)]
    [System.Collections.IDictionary] $Map = @{'capslock' = 'esc'}
)

Set-StrictMode -Version Latest
trap { throw $Error[0] }
$ErrorActionPreference = "Stop"

$keycodes = [ordered]@{
    'deactivate'= @(0x00,0x00);
    'esc'= @(0x01,0x00);
    '1/!'= @(0x02,0x00);
    '2/@'= @(0x03,0x00);
    '3/#'= @(0x04,0x00);
    '4/$'= @(0x05,0x00);
    '5/%'= @(0x06,0x00);
    '6/^'= @(0x07,0x00);
    '7/&'= @(0x08,0x00);
    '8/*'= @(0x09,0x00);
    '9/('= @(0x0a,0x00);
    '0/)'= @(0x0b,0x00);
    '-/_'= @(0x0c,0x00);
    '=/+'= @(0x0d,0x00);
    'backspace'= @(0x0e,0x00);
    'tabulator'= @(0x0f,0x00);
    'q'= @(0x10,0x00);
    'w'= @(0x11,0x00);
    'e'= @(0x12,0x00);
    'r'= @(0x13,0x00);
    't'= @(0x14,0x00);
    'y'= @(0x15,0x00);
    'u'= @(0x16,0x00);
    'i'= @(0x17,0x00);
    'o'= @(0x18,0x00);
    'p'= @(0x19,0x00);
    '[/{'= @(0x1a,0x00);
    ']/} '= @(0x1b,0x00);
    'enter'= @(0x1c,0x00);
    '(num)enter'= @(0x1c,0xe0);
    'lctrl'= @(0x1d,0x00);
    'rctrl'= @(0x1d,0xe0);
    'a'= @(0x1e,0x00);
    's'= @(0x1f,0x00);
    'd'= @(0x20,0x00);
    'mute'= @(0x20,0xe0);
    'f'= @(0x21,0x00);
    'g'= @(0x22,0x00);
    'play and pause'= @(0x22,0xe0);
    'h'= @(0x23,0x00);
    'j'= @(0x24,0x00);
    'stop'= @(0x24,0xe0);
    'k'= @(0x25,0x00);
    'l'= @(0x26,0x00);
    ';/:'= @(0x27,0x00);
    "'/`""= @(0x28,0x00);
    '`/~'= @(0x29,0x00);
    'lshift'= @(0x2a,0x00);
    '\/|'= @(0x2b,0x00);
    'z'= @(0x2c,0x00);
    'x'= @(0x2d,0x00);
    'c'= @(0x2e,0x00);
    'tune down'= @(0x2e,0xe0);
    'v'= @(0x2f,0x00);
    'b'= @(0x30,0x00);
    'tune up'= @(0x30,0xe0);
    'n'= @(0x31,0x00);
    'm'= @(0x32,0x00);
    'www-key'= @(0x32,0xe0);
    ',/<'= @(0x33,0x00);
    './>'= @(0x34,0x00);
    '//?'= @(0x35,0x00);
    '(num)/'= @(0x35,0xe0);
    'rshift'= @(0x36,0x00);
    '(num)*'= @(0x37,0x00);
    'prtscr'= @(0x37,0xe0);
    'lalt'= @(0x38,0x00);
    'ralt '= @(0x38,0xe0);
    'space'= @(0x39,0x00);
    'capslock'= @(0x3a,0x00);
    'f1'= @(0x3b,0x00);
    'f2'= @(0x3c,0x00);
    'f3'= @(0x3d,0x00);
    'f4'= @(0x3e,0x00);
    'f5'= @(0x3f,0x00);
    'f6'= @(0x40,0x00);
    'f7'= @(0x41,0x00);
    'f8'= @(0x42,0x00);
    'f9'= @(0x43,0x00);
    'f10'= @(0x44,0x00);
    'numlock'= @(0x45,0x00);
    'scrolllock'= @(0x46,0x00);
    'crtl+break'= @(0x46,0xe0);
    '(num)7/home'= @(0x47,0x00);
    'pos1'= @(0x47,0xe0);
    '(num)8/up'= @(0x48,0x00);
    'up'= @(0x48,0xe0);
    'pgup'= @(0x49,0xe0);
    '(num)-'= @(0x4a,0x00);
    '(num)4/left'= @(0x4b,0x00);
    'left'= @(0x4b,0xe0);
    '(num)5'= @(0x4c,0x00);
    '(num)6/right'= @(0x4d,0x00);
    'right'= @(0x4d,0xe0);
    '(num)+'= @(0x4e,0x00);
    '(num)1/end'= @(0x4f,0x00);
    'end'= @(0x4f,0xe0);
    '(num)2/down'= @(0x50,0x00);
    'down'= @(0x50,0xe0);
    '(num)3/pgdn'= @(0x51,0x00);
    'pgdn'= @(0x51,0xe0);
    '(num)0/ins'= @(0x52,0x00);
    'insert'= @(0x52,0xe0);
    '(num),/del'= @(0x53,0x00);
    'delete'= @(0x53,0xe0);
    'alt + sysrq'= @(0x54,0x00);
    'f11'= @(0x57,0x00);
    'f12'= @(0x58,0x00);
    'lwindows'= @(0x5b,0xe0);
    'rwindows'= @(0x5c,0xe0);
    'windows menu'= @(0x5d,0xe0);
    'power'= @(0x5e,0xe0);
    'sleep'= @(0x5f,0xe0);
    'wake'= @(0x63,0xe0);
}

<#
.SYNOPSIS
    Creates hex byte array with info from the following table.
    New mappings get inserted after the old ones.

| Offset byte | Size in Bytes |          Value | Description                |
|------------:+--------------:+---------------:+----------------------------|
|           0 |             4 |       00000000 | Header: Version info       |
|           4 |             4 |       00000000 | Header: Flags              |
|           8 |             4 |       01000000 | Header: Number of mappings |
|             |               |                |     including end marker   |
|          12 |             4 | (see keycodes) | Mappings (to, from)        |
|          12 |             4 |       00000000 | End marker                 |
#>
function Create-RemapRegistryValue {
    param (
        [Parameter(Mandatory=$true)]
            [ValidateScript({
	        ($_.Keys + $_.Values).Where({$_ -iin $keycodes.Keys}).count -eq $_.Keys.Count * 2
	    })]
	    [System.Collections.IDictionary] $Map
    )

    $scancodeMap = @(
        @(0x00,0x00,0x00,0x00),
        @(0x00,0x00,0x00,0x00),
        @(0x01,0x00,0x00,0x00),
        @(),
        @(0x00,0x00,0x00,0x00)
    )

    foreach($key in $Map.Keys) {
        $scancodeMap[2][0] = $scancodeMap[2][0] + 1
        $scancodeMap[3] += $keycodes[$Map[$key].toLower()]
        $scancodeMap[3] += $keycodes[$key.toLower()]
    }

    return ($scancodeMap | %{$_})
}

return (Create-RemapRegistryValue -Map $Map)
