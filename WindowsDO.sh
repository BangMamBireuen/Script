#!/bin/bash
#
# CREATED By NIXPOIN.COM
# EDITIO BY BANGMAM
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

cat >/tmp/install-software.bat<<EOF
@ECHO OFF
echo JENDELA INI JANGAN DITUTUP
echo SEDANG MENGINSTAL SEMUA SOFTWARE SECARA OTOMATIS...
echo PROSES INI MEMBUTUHKAN WAKTU 10-15 MENIT

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
    echo Firewall rule already exists.
) else (
    echo Creating firewall rule for RDP port 5000...
    netsh advfirewall firewall add rule name=%RULE_NAME% dir=in action=allow protocol=TCP localport=%PORT%
)

reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 5000 /f

ECHO SELECT VOLUME=%%SystemDrive%% > "%SystemDrive%\diskpart.extend"
ECHO EXTEND >> "%SystemDrive%\diskpart.extend"
START /WAIT DISKPART /S "%SystemDrive%\diskpart.extend"
del /f /q "%SystemDrive%\diskpart.extend"

echo ==========================================
echo MULAI INSTALASI SOFTWARE...
echo ==========================================

echo [1/8] Installing Google Chrome...
START /WAIT ChromeSetup.exe /silent /install
timeout 10 >nul

echo [2/8] Installing Google Drive...
START /WAIT GoogleDriveSetup.exe --silent
timeout 10 >nul

echo [3/8] Installing PostgreSQL...
START /WAIT postgresql-9.4.26-1-windows-x64.exe --mode unattended --superpassword "123456" --servicename "PostgreSQL" --servicepassword "123456" --serverport 5432
timeout 15 >nul

echo [4/8] Installing XAMPP...
START /WAIT xampp-windows-x64-7.4.30-1-VC15-installer.exe --mode unattended --unattendedmodeui minimal
timeout 20 >nul

echo [5/8] Installing Notepad++...
START /WAIT npp.7.8.5.Installer.x64.exe /S
timeout 10 >nul

echo [6/8] Installing WinRAR...
START /WAIT winrar-x64-713.exe /S
timeout 10 >nul

echo [7/8] Installing Navicat Premium...
START /WAIT navicat160_premium_Dan_x64.exe /S
timeout 15 >nul

echo [8/8] Installing .NET Framework 4.8...
START /WAIT NDP48-x86-x64-AllOS-ENU.exe /quiet /norestart
timeout 20 >nul

echo ==========================================
echo FINALIZING INSTALLATION...
echo ==========================================

echo Copying libcc.dll to Navicat directory...
timeout 5 >nul
if exist "C:\Program Files\PremiumSoft\Navicat Premium 16" (
    copy libcc.dll "C:\Program Files\PremiumSoft\Navicat Premium 16\"
    echo libcc.dll successfully copied
) else (
    echo Searching for Navicat directory...
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

powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\\Desktop\\Google Chrome.lnk');$s.TargetPath='C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';$s.Save()"

powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\\Desktop\\Notepad++.lnk');$s.TargetPath='C:\\Program Files\\Notepad++\\notepad++.exe';$s.Save()"

powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\\Desktop\\WinRAR.lnk');$s.TargetPath='C:\\Program Files\\WinRAR\\WinRAR.exe';$s.Save()"

powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\\Desktop\\Navicat Premium.lnk');$s.TargetPath='C:\\Program Files\\PremiumSoft\\Navicat Premium 16\\navicat.exe';$s.Save()"

powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\\Desktop\\XAMPP Control Panel.lnk');$s.TargetPath='C:\\xampp\\xampp-control.exe';$s.Save()"

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

echo ==========================================
echo INSTALASI SELESAI!
echo ==========================================
echo Semua software telah terinstall otomatis
echo Shortcut telah dibuat di desktop
echo RDP Port: 5000
echo IP Address: $IP4
echo ==========================================
echo System akan reboot otomatis dalam 30 detik...
echo ==========================================

cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q install-software.bat

timeout 30 >nul
echo Melakukan reboot akhir...
shutdown /r /t 5 /f
exit
EOF

echo "Downloading and installing Windows OS..."
wget --no-check-certificate -O- $PILIHOS | gunzip | dd of=/dev/vda bs=3M status=progress

echo "Mounting Windows partition and configuring startup..."
mount.ntfs-3g /dev/vda2 /mnt
cd "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/"
cd Start* || cd start*

echo "Downloading additional software..."
wget -q https://archive.org/download/google-drive-setup_202510/ChromeSetup.exe
wget -q https://archive.org/download/google-drive-setup_202510/GoogleDriveSetup.exe
wget -q https://archive.org/download/google-drive-setup_202510/postgresql-9.4.26-1-windows-x64.exe
wget -q https://archive.org/download/google-drive-setup_202510/xampp-windows-x64-7.4.30-1-VC15-installer.exe
wget -q https://archive.org/download/google-drive-setup_202510/npp.7.8.5.Installer.x64.exe
wget -q https://archive.org/download/google-drive-setup_202510/winrar-x64-713.exe
wget -q https://archive.org/download/google-drive-setup_202511/navicat160_premium_Dan_x64.exe
wget -q https://archive.org/download/google-drive-setup_202511/NDP48-x86-x64-AllOS-ENU.exe
wget -q https://archive.org/download/google-drive-setup_202511/libcc.dll

cp -f /tmp/net.bat net.bat
cp -f /tmp/install-software.bat install-software.bat

echo 'Setup completed! Server will shutdown in 3 seconds...'
sleep 3
poweroff
