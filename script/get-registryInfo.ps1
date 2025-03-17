@(
    [PSCustomObject]@{
        path='HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall';
        description='Contains installed programs and their information';
    },
    [PSCustomObject]@{
        path='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion';
        description='Get Windows build infos';
    },
    [PSCustomObject]@{
        path='HKLM:\SOFTWARE\WOW6432Node';
        description='64-bit version of HKLM:\SOFTWARE\ where subkeys under \<company>\<product> contain program specific info';
    }
)
