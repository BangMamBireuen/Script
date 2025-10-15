#!/bin/bash
# ======================================
# CREATED By NIXPOIN.COM
# EDITION By BANGMAM
# Download Chrome langsung di batch file - Lebih reliable
# Hapus installer Chrome setelah install - Otomatis bersih
# Multiple cleanup paths - Pastikan ChromeSetup.exe dihapus dari semua lokasi
# Better mount handling - Coba multiple partisi
# Fixed Startup path - Gunakan path yang konsisten
# ======================================

echo "Windows 2019 akan diinstall"

PILIHOS="https://download1511.mediafire.com/oynhw6053ycg7u4nae1px2IakZbxN6TPO3NW2URhFEwp1ZBUkCX6NBNriu0X7bJIf-1YJTJjw20rZgIyUQcggsSZQ9nrc0lfiZe74mT5VSSSVGwSKVDTl5oURGcds6CzHl5x4bFnWA_opmL7kuqZG-MRzQ8OD1aGY28Ot4o8pQ/oi1bb1p9heg6sbm/windows2019DO.gz"
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

:: Download dan install Chrome
echo Mengunduh Chrome...
powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TEMP%\ChromeInstaller.exe'"
echo Menginstall Chrome...
%TEMP%\ChromeInstaller.exe /silent /install
echo Menghapus installer Chrome...
del /f /q "%TEMP%\ChromeInstaller.exe"

:: Download dan install Google Drive
echo Mengunduh Google Drive...
powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe' -OutFile '%TEMP%\GoogleDriveSetup.exe'"
echo Menginstall Google Drive...
%TEMP%\GoogleDriveSetup.exe --silent
echo Menghapus installer Google Drive...
del /f /q "%TEMP%\GoogleDriveSetup.exe"

:: Download dan install PostgreSQL 9.4.26.1 dari GitHub mirror
echo Mengunduh PostgreSQL 9.4.26.1...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/PostgresApp/PostgresApp/releases/download/v2.3.5/Postgres-2.3.5-10-11-12.dmg' -OutFile '%TEMP%\postgresql-9.4.26.1.exe'"
echo Menginstall PostgreSQL 9.4.26.1...
echo Proses instalasi PostgreSQL akan dimulai...
start /wait "" "%TEMP%\postgresql-9.4.26.1.exe" --mode unattended --superpassword "123456" --servicename "PostgreSQL" --servicepassword "123456" --serverport 5432
echo Menghapus installer PostgreSQL...
del /f /q "%TEMP%\postgresql-9.4.26.1.exe"

:: Download dan install XAMPP 7.4.29
echo Mengunduh XAMPP 7.4.29...
powershell -Command "Invoke-WebRequest -Uri 'https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/7.4.29/xampp-windows-x64-7.4.29-0-VC15-installer.exe/download' -OutFile '%TEMP%\xampp-installer.exe'"

if not exist "%TEMP%\xampp-installer.exe" (
    echo Mencoba direct download...
    powershell -Command "Invoke-WebRequest -Uri 'https://downloads.sourceforge.net/project/xampp/XAMPP%20Windows/7.4.29/xampp-windows-x64-7.4.29-0-VC15-installer.exe' -OutFile '%TEMP%\xampp-installer.exe'"
)

if exist "%TEMP%\xampp-installer.exe" (
    echo Download XAMPP 7.4.29 berhasil!
    echo Menginstall XAMPP 7.4.29...
    echo Proses instalasi XAMPP akan dimulai...
    start /wait "" "%TEMP%\xampp-installer.exe" /S
    echo Menghapus installer XAMPP...
    del /f /q "%TEMP%\xampp-installer.exe"
) else (
    echo Gagal mendownload XAMPP
)

:: Download dan install Notepad++ 7.8.5
echo Mengunduh Notepad++ 7.8.5...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.8.5/npp.7.8.5.Installer.x64.exe' -OutFile '%TEMP%\notepadplusplus-installer.exe'"
echo Menginstall Notepad++ 7.8.5...
echo Proses instalasi Notepad++ akan dimulai...
%TEMP%\notepadplusplus-installer.exe /S
echo Menghapus installer Notepad++...
del /f /q "%TEMP%\notepadplusplus-installer.exe"

:: Download dan install WinRAR 7.13
echo Mengunduh WinRAR 7.13...
powershell -Command "Invoke-WebRequest -Uri 'https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-713.exe' -OutFile '%TEMP%\winrar-installer.exe'"
echo Menginstall WinRAR 7.13...
echo Proses instalasi WinRAR akan dimulai...
%TEMP%\winrar-installer.exe /S
echo Menghapus installer WinRAR...
del /f /q "%TEMP%\winrar-installer.exe"

:: Buat shortcut di Desktop untuk semua aplikasi
echo Membuat shortcut di Desktop...
powershell -Command "& {
    # Shortcut Google Chrome
    `$WshShell = New-Object -comObject WScript.Shell
    `$Shortcut = `$WshShell.CreateShortcut('C:\Users\Public\Desktop\Google Chrome.lnk')
    `$Shortcut.TargetPath = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
    `$Shortcut.Save()

    # Shortcut Google Drive
    `$Shortcut2 = `$WshShell.CreateShortcut('C:\Users\Public\Desktop\Google Drive.lnk')
    `$Shortcut2.TargetPath = 'C:\Program Files\Google\Drive File Stream\launch.exe'
    `$Shortcut2.Save()

    # Shortcut XAMPP Control Panel
    `$Shortcut3 = `$WshShell.CreateShortcut('C:\Users\Public\Desktop\XAMPP Control Panel.lnk')
    `$Shortcut3.TargetPath = 'C:\xampp\xampp-control.exe'
    `$Shortcut3.Save()

    # Shortcut pgAdmin (PostgreSQL)
    `$Shortcut4 = `$WshShell.CreateShortcut('C:\Users\Public\Desktop\pgAdmin 4.lnk')
    `$Shortcut4.TargetPath = 'C:\Program Files\PostgreSQL\9.4\pgAdmin 4\bin\pgAdmin4.exe'
    `$Shortcut4.Save()

    # Shortcut Notepad++
    `$Shortcut5 = `$WshShell.CreateShortcut('C:\Users\Public\Desktop\Notepad++.lnk')
    `$Shortcut5.TargetPath = 'C:\Program Files\Notepad++\notepad++.exe'
    `$Shortcut5.Save()

    # Shortcut WinRAR
    `$Shortcut6 = `$WshShell.CreateShortcut('C:\Users\Public\Desktop\WinRAR.lnk')
    `$Shortcut6.TargetPath = 'C:\Program Files\WinRAR\WinRAR.exe'
    `$Shortcut6.Save()

    Write-Host 'Semua shortcut berhasil dibuat di Desktop!' -ForegroundColor Green
}"

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
