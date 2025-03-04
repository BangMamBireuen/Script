@ECHO OFF
set PORT=3000
set RULE_NAME="Open Port %PORT%"

netsh advfirewall firewall show rule name=%RULE_NAME% >nul
if not ERRORLEVEL 1 (
    echo Rule %RULE_NAME% already exists.
) else (
    echo Creating rule %RULE_NAME%...
    netsh advfirewall firewall add rule name=%RULE_NAME% dir=in action=allow protocol=TCP localport=%PORT%
)

reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 5000 /f

echo Firewall rule for RDP on port %PORT% has been configured.
echo RDP port changed to %PORT%.
exit
