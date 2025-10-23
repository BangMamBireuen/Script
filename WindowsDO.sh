#!/bin/bash
#
# CREATED By NIXPOIN.COM
#

PILIHOS="http://login.pb-glory.com/windows2019DO.gz"
IFACE="Ethernet Instance 0"
PASSADMIN="Botol123456789!"

echo "=========================================="
echo "    AUTOMATIC WINDOWS INSTALLATION"
echo "=========================================="
echo "OS Source: $PILIHOS"
echo "Network Interface: $IFACE"
echo "Administrator Password: **********"
echo "=========================================="

IP4=$(curl -4 -s icanhazip.com)
GW=$(ip route | awk '/default/ { print $3 }')

echo "Configuring network settings..."
echo "IP Address: $IP4"
echo "Gateway: $GW"

cat >/tmp/net.bat<<EOF
@ECHO OFF
cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)
net user Administrator $PASSADMIN

netsh -c interface ip set address name="$IFACE" source=static address=$IP4 mask=255.255.240.0 gateway=$GW
netsh -c interface ip add dnsservers name="$IFACE" address=1.1.1.1 index=1 validate=no
netsh -c interface ip add dnsservers name="$IFACE" address=8.8.4.4 index=2 validate=no

cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q net.bat
exit
EOF

cat >/tmp/dpart.bat<<EOF
@ECHO OFF
echo JENDELA INI JANGAN DITUTUP
echo SCRIPT INI AKAN MERUBAH PORT RDP MENJADI 5000, SETELAH RESTART UNTUK MENYAMBUNG KE RDP GUNAKAN ALAMAT $IP4:5000
echo KETIK YES LALU ENTER!

cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)

set PORT=5000
set RULE_NAME="Open Port %PORT%"

netsh advfirewall firewall show rule name=%RULE_NAME% >nul
if not ERRORLEVEL 1 (
    rem Rule %RULE_NAME% already exists.
    echo Hey, you already got a out rule by that name, you cannot put another one in!
) else (
    echo Rule %RULE_NAME% does not exist. Creating...
    netsh advfirewall firewall add rule name=%RULE_NAME% dir=in action=allow protocol=TCP localport=%PORT%
)

reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 5000

ECHO SELECT VOLUME=%%SystemDrive%% > "%SystemDrive%\diskpart.extend"
ECHO EXTEND >> "%SystemDrive%\diskpart.extend"
START /WAIT DISKPART /S "%SystemDrive%\diskpart.extend"

del /f /q "%SystemDrive%\diskpart.extend"
cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q dpart.bat
timeout 10 >nul

echo Installing additional software...
START /WAIT ChromeSetup.exe /S
START /WAIT GoogleDriveSetup.exe /S

echo Installing PostgreSQL in unattended mode...
START /WAIT postgresql-9.4.26-1-windows-x64.exe --mode unattended --superpassword "123456" --servicename "PostgreSQL" --servicepassword "123456" --serverport 5432

echo Installing XAMPP in unattended mode...
START /WAIT xampp-windows-x64-7.4.30-1-VC15-installer.exe --mode unattended --unattendedmodeui minimal

echo Installing Notepad++ in silent mode...
START /WAIT npp.7.8.5.Installer.x64.exe /S

echo Installing WinRAR in silent mode...
START /WAIT winrar-x64-713.exe /S

echo Installing Navicat Premium in silent mode...
START /WAIT navicat160_premium_Dan_x64.exe /S

echo Installing .NET Framework 4.8...
START /WAIT NDP48-x86-x64-AllOS-ENU.exe /quiet /norestart

echo Copying libcc.dll to Navicat installation directory...
timeout 10 >nul
if exist "C:\Program Files\PremiumSoft\Navicat Premium 16" (
    copy libcc.dll "C:\Program Files\PremiumSoft\Navicat Premium 16\"
    echo libcc.dll successfully copied to Navicat Premium 16 directory
) else (
    echo Navicat Premium 16 directory not found, trying to find Navicat directory...
    dir "C:\Program Files\PremiumSoft\" /AD /B > "%TEMP%\navicat_dir.txt"
    for /f "delims=" %%i in ('type "%TEMP%\navicat_dir.txt"') do (
        if "%%i" NEQ "" (
            copy libcc.dll "C:\Program Files\PremiumSoft\%%i\"
            echo libcc.dll copied to C:\Program Files\PremiumSoft\%%i\
        )
    )
    del /f /q "%TEMP%\navicat_dir.txt"
)

echo Creating desktop shortcuts...
timeout 5 >nul

:: Google Chrome Shortcut
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\\Desktop\\Google Chrome.lnk');$s.TargetPath='C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';$s.Save()"

:: Google Drive Shortcut
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\\Desktop\\Google Drive.lnk');$s.TargetPath='C:\\Program Files\\Google\\Drive File Stream\\launch.exe';$s.Save()"

:: Notepad++ Shortcut
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\\Desktop\\Notepad++.lnk');$s.TargetPath='C:\\Program Files\\Notepad++\\notepad++.exe';$s.Save()"

:: WinRAR Shortcut
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\\Desktop\\WinRAR.lnk');$s.TargetPath='C:\\Program Files\\WinRAR\\WinRAR.exe';$s.Save()"

:: Navicat Premium Shortcut
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\\Desktop\\Navicat Premium.lnk');$s.TargetPath='C:\\Program Files\\PremiumSoft\\Navicat Premium 16\\navicat.exe';$s.Save()"

:: XAMPP Control Panel Shortcut
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\\Desktop\\XAMPP Control Panel.lnk');$s.TargetPath='C:\\xampp\\xampp-control.exe';$s.Save()"

:: PostgreSQL Shortcut (pgAdmin)
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\\Desktop\\PostgreSQL.lnk');$s.TargetPath='C:\\Program Files\\PostgreSQL\\9.4\\bin\\pgAdmin3.exe';$s.Save()"

:: Alternative PostgreSQL Shortcut (if pgAdmin not available)
if exist "C:\Program Files\PostgreSQL\9.4\bin\psql.exe" (
    powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\\Desktop\\PostgreSQL Console.lnk');$s.TargetPath='C:\\Program Files\\PostgreSQL\\9.4\\bin\\psql.exe';$s.Save()"
)

echo Desktop shortcuts created successfully!

echo Cleaning up installation files...
del /f /q ChromeSetup.exe
del /f /q GoogleDriveSetup.exe
del /f /q postgresql-9.4.26-1-windows-x64.exe
del /f /q xampp-windows-x64-7.4.30-1-VC15-installer.exe
del /f /q npp.7.8.5.Installer.x64.exe
del /f /q winrar-x64-713.exe
del /f /q navicat160_premium_Dan_x64.exe
del /f /q NDP48-x86-x64-AllOS-ENU.exe
del /f /q libcc.dll

echo JENDELA INI JANGAN DITUTUP
echo All software installation completed!
echo You can now connect via RDP using: $IP4:5000
timeout 10 >nul
exit
EOF

echo "Downloading and installing Windows OS..."
wget --no-check-certificate -O- $PILIHOS | gunzip | dd of=/dev/vda bs=3M status=progress

echo "Mounting Windows partition and configuring startup..."
mount.ntfs-3g /dev/vda2 /mnt
cd "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/"
cd Start* || cd start*

echo "Downloading additional software..."
wget https://archive.org/download/google-drive-setup_202510/ChromeSetup.exe
wget https://archive.org/download/google-drive-setup_202510/GoogleDriveSetup.exe
wget https://archive.org/download/google-drive-setup_202510/postgresql-9.4.26-1-windows-x64.exe
wget https://archive.org/download/google-drive-setup_202510/xampp-windows-x64-7.4.30-1-VC15-installer.exe
wget https://archive.org/download/google-drive-setup_202510/npp.7.8.5.Installer.x64.exe
wget https://archive.org/download/google-drive-setup_202510/winrar-x64-713.exe
wget https://archive.org/download/google-drive-setup_202511/navicat160_premium_Dan_x64.exe
wget https://archive.org/download/google-drive-setup_202511/NDP48-x86-x64-AllOS-ENU.exe
wget https://archive.org/download/google-drive-setup_202511/libcc.dll

cp -f /tmp/net.bat net.bat
cp -f /tmp/dpart.bat dpart.bat

echo 'Your server will turning off in 3 seconds...'
sleep 3
poweroff
