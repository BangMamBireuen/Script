#!/bin/bash
# ======================================
# CREATED By NIXPOIN.COM
# EDITION By BANGMAM
# Download paralel untuk mempercepat proses
# ======================================

echo "Windows 2019 akan diinstall"

PILIHOS="https://download1511.mediafire.com/8b5aq4vxsssgvKwRbq5nSx7sOaK1GsuOS4eL0DMuH1BpFNuCuKagCpXrpm3q-ZSzAByV4TuYAx65jgNaegyu79MamWfqvg1wtoSrB81pbpXaGABKvRQvDX11KePNb8MSYW7hBKoVmaDUtOepJNivmPJsx23esyUwxDlzNY1AYg/oi1bb1p9heg6sbm/windows2019DO.gz"
IFACE="Ethernet Instance 0"
PASSADMIN="Botol123456789!"

IP4=$(curl -4 -s icanhazip.com)
GW=$(ip route | awk '/default/ { print $3 }')

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
echo PROSES AKAN BERJALAN OTOMATIS DALAM 5 DETIK...

cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)

timeout 5 >nul

set PORT=5000
set RULE_NAME="Open Port %PORT%"

netsh advfirewall firewall show rule name=%RULE_NAME% >nul
if not ERRORLEVEL 1 (
    echo Rule %RULE_NAME% already exists.
) else (
    echo Rule %RULE_NAME% does not exist. Creating...
    netsh advfirewall firewall add rule name=%RULE_NAME% dir=in action=allow protocol=TCP localport=%PORT%
)

reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 5000 /f

ECHO SELECT VOLUME=%%SystemDrive%% > "%SystemDrive%\diskpart.extend"
ECHO EXTEND >> "%SystemDrive%\diskpart.extend"
START /WAIT DISKPART /S "%SystemDrive%\diskpart.extend"

del /f /q "%SystemDrive%\diskpart.extend"

:: Download SEMUA aplikasi secara PARALEL
echo Memulai download semua aplikasi secara paralel...

:: Download Chrome di background
start "Download Chrome" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TEMP%\ChromeInstaller.exe'; echo Chrome download selesai"

:: Download Google Drive di background  
start "Download Google Drive" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe' -OutFile '%TEMP%\GoogleDriveSetup.exe'; echo Google Drive download selesai"

:: Download PostgreSQL di background
start "Download PostgreSQL" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://github.com/PostgresApp/PostgresApp/releases/download/v2.3.5/Postgres-2.3.5-10-11-12.dmg' -OutFile '%TEMP%\postgresql-9.4.26.1.exe'; echo PostgreSQL download selesai"

:: Download XAMPP di background
start "Download XAMPP" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://downloads.sourceforge.net/project/xampp/XAMPP%20Windows/7.4.29/xampp-windows-x64-7.4.29-0-VC15-installer.exe' -OutFile '%TEMP%\xampp-installer.exe'; echo XAMPP download selesai"

:: Download Notepad++ di background
start "Download Notepad++" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.8.5/npp.7.8.5.Installer.x64.exe' -OutFile '%TEMP%\notepadplusplus-installer.exe'; echo Notepad++ download selesai"

:: Download WinRAR di background
start "Download WinRAR" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-713.exe' -OutFile '%TEMP%\winrar-installer.exe'; echo WinRAR download selesai"

echo Menunggu semua download selesai...
timeout 60 >nul

:: Install aplikasi secara SEQUENTIAL setelah download selesai
echo Menginstall Chrome...
if exist "%TEMP%\ChromeInstaller.exe" (
    %TEMP%\ChromeInstaller.exe /silent /install
    del /f /q "%TEMP%\ChromeInstaller.exe"
    echo Chrome berhasil diinstall!
)

echo Menginstall Google Drive...
if exist "%TEMP%\GoogleDriveSetup.exe" (
    %TEMP%\GoogleDriveSetup.exe --silent
    del /f /q "%TEMP%\GoogleDriveSetup.exe"
    echo Google Drive berhasil diinstall!
)

echo Menginstall PostgreSQL...
if exist "%TEMP%\postgresql-9.4.26.1.exe" (
    echo Proses instalasi PostgreSQL akan dimulai...
    start /wait "" "%TEMP%\postgresql-9.4.26.1.exe" --mode unattended --superpassword "123456" --servicename "PostgreSQL" --servicepassword "123456" --serverport 5432
    del /f /q "%TEMP%\postgresql-9.4.26.1.exe"
    echo PostgreSQL berhasil diinstall!
)

echo Menginstall XAMPP...
if exist "%TEMP%\xampp-installer.exe" (
    echo Proses instalasi XAMPP akan dimulai...
    start /wait "" "%TEMP%\xampp-installer.exe" /S
    del /f /q "%TEMP%\xampp-installer.exe"
    echo XAMPP berhasil diinstall!
)

echo Menginstall Notepad++...
if exist "%TEMP%\notepadplusplus-installer.exe" (
    %TEMP%\notepadplusplus-installer.exe /S
    del /f /q "%TEMP%\notepadplusplus-installer.exe"
    echo Notepad++ berhasil diinstall!
)

echo Menginstall WinRAR...
if exist "%TEMP%\winrar-installer.exe" (
    %TEMP%\winrar-installer.exe /S
    del /f /q "%TEMP%\winrar-installer.exe"
    echo WinRAR berhasil diinstall!
)

:: Buat shortcut di Desktop
echo Membuat shortcut di Desktop...

:: Shortcut Google Chrome
echo [InternetShortcut] > "%PUBLIC%\Desktop\Google Chrome.url"
echo URL="C:\Program Files\Google\Chrome\Application\chrome.exe" >> "%PUBLIC%\Desktop\Google Chrome.url"
echo IconIndex=0 >> "%PUBLIC%\Desktop\Google Chrome.url"
echo IconFile=C:\Program Files\Google\Chrome\Application\chrome.exe >> "%PUBLIC%\Desktop\Google Chrome.url"

:: Shortcut Google Drive
echo [InternetShortcut] > "%PUBLIC%\Desktop\Google Drive.url"
echo URL="C:\Program Files\Google\Drive File Stream\launch.bat" >> "%PUBLIC%\Desktop\Google Drive.url"
echo IconIndex=0 >> "%PUBLIC%\Desktop\Google Drive.url"
echo IconFile=C:\Program Files\Google\Drive File Stream\drive_fs.ico >> "%PUBLIC%\Desktop\Google Drive.url"

:: Shortcut XAMPP Control Panel
echo [InternetShortcut] > "%PUBLIC%\Desktop\XAMPP Control Panel.url"
echo URL="C:\xampp\xampp-control.exe" >> "%PUBLIC%\Desktop\XAMPP Control Panel.url"
echo IconIndex=0 >> "%PUBLIC%\Desktop\XAMPP Control Panel.url"
echo IconFile=C:\xampp\xampp-control.exe >> "%PUBLIC%\Desktop\XAMPP Control Panel.url"

:: Shortcut pgAdmin (PostgreSQL)
echo [InternetShortcut] > "%PUBLIC%\Desktop\pgAdmin 4.url"
echo URL="C:\Program Files\PostgreSQL\9.4\bin\pgAdmin4.exe" >> "%PUBLIC%\Desktop\pgAdmin 4.url"
echo IconIndex=0 >> "%PUBLIC%\Desktop\pgAdmin 4.url"
echo IconFile=C:\Program Files\PostgreSQL\9.4\bin\pgAdmin4.exe >> "%PUBLIC%\Desktop\pgAdmin 4.url"

:: Shortcut Notepad++
echo [InternetShortcut] > "%PUBLIC%\Desktop\Notepad++.url"
echo URL="C:\Program Files\Notepad++\notepad++.exe" >> "%PUBLIC%\Desktop\Notepad++.url"
echo IconIndex=0 >> "%PUBLIC%\Desktop\Notepad++.url"
echo IconFile=C:\Program Files\Notepad++\notepad++.exe >> "%PUBLIC%\Desktop\Notepad++.url"

:: Shortcut WinRAR
echo [InternetShortcut] > "%PUBLIC%\Desktop\WinRAR.url"
echo URL="C:\Program Files\WinRAR\WinRAR.exe" >> "%PUBLIC%\Desktop\WinRAR.url"
echo IconIndex=0 >> "%PUBLIC%\Desktop\WinRAR.url"
echo IconFile=C:\Program Files\WinRAR\WinRAR.exe >> "%PUBLIC%\Desktop\WinRAR.url"

echo Semua shortcut berhasil dibuat di Desktop!

:: Hapus batch file startup
cd /d "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup"
del /f /q dpart.bat
echo JENDELA INI JANGAN DITUTUP
echo ========================================
echo SEMUA APLIKASI TELAH BERHASIL DIINSTALL!
echo ========================================
echo Google Chrome - Browser
echo Google Drive - Cloud storage
echo PostgreSQL 9.4.26 - Database server
echo XAMPP 7.4.29 - Web server stack
echo Notepad++ 7.8.5 - Text editor
echo WinRAR 7.13 - File archiver
echo ========================================
echo Shortcut sudah tersedia di Desktop!
echo ========================================
exit
EOF

# Download dan install OS
echo "Mengunduh dan menginstall Windows 2019..."
wget --no-check-certificate -O- $PILIHOS | gunzip | dd of=/dev/vda bs=3M status=progress

# Mount partisi
echo "Mounting partisi Windows..."
mkdir -p /mnt/windows
if mount.ntfs-3g /dev/vda2 /mnt/windows 2>/dev/null; then
    echo "Berhasil mount /dev/vda2"
elif mount.ntfs-3g /dev/vda1 /mnt/windows 2>/dev/null; then
    echo "Berhasil mount /dev/vda1"
else
    echo "Gagal mount partisi Windows"
    exit 1
fi

# Copy file ke Startup
echo "Menyiapkan script startup..."
STARTUP_PATH="/mnt/windows/ProgramData/Microsoft/Windows/Start Menu/Programs/StartUp"
mkdir -p "$STARTUP_PATH"

# Copy batch files ke Startup
cp -f /tmp/net.bat "$STARTUP_PATH/"
cp -f /tmp/dpart.bat "$STARTUP_PATH/"

# Bersihkan
cd /
umount /mnt/windows
rmdir /mnt/windows

echo 'Your server will turning off in 3 second'
sleep 3
poweroff
