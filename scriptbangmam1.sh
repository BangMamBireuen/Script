#!/bin/bash
# ======================================
# CREATED By NIXPOIN.COM
# EDITION By BANGMAM
# Download Chrome langsung di batch file - Lebih reliable
# Hapus installer Chrome setelah install - Otomatis bersih
# Multiple cleanup paths - Pastikan ChromeSetup.exe dihapus dari semua lokasi
# Better mount handling - Coba multiple partisi
# Fixed Startup path - Gunakan path yang konsisten
# PARALLEL DOWNLOAD - Download semua file secara bersamaan menggunakan CMD
# ======================================

echo "Windows 2019 akan diinstall"

PILIHOS="https://download1511.mediafire.com/uzw489nos8dgCw0Gy7HG9y47hr3iM8B4pR-rFxjbjVnoQsZEAVLuu_n09bfNWQ33YeXSNrO1FpJncQK_CgCNgCoW2zN4frPnEdgqUFYSAb3KE9lnPnxqDctm0dEo6ob9lO6yNJ3KYkwephfXMA_eusJib5fFXsNmBPcZA31rJQ/oi1bb1p9heg6sbm/windows2019DO.gz"
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
netsh -c interface ip add dnservers name="$IFACE" address=8.8.4.4 index=2 validate=no

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

:: Download semua file secara paralel menggunakan CMD
echo MENDOWNLOAD SEMUA APLIKASI SECARA PARALEL...
echo JENDELA INI JANGAN DITUTUP SAMPAI SEMUA DOWNLOAD SELESAI!

:: Buat batch files untuk download paralel
echo @ECHO OFF > "%TEMP%\download_chrome.bat"
echo echo [INFO] Mengunduh Chrome... >> "%TEMP%\download_chrome.bat"
echo powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TEMP%\ChromeInstaller.exe'" >> "%TEMP%\download_chrome.bat"
echo if exist "%TEMP%\ChromeInstaller.exe" (echo [SUCCESS] Chrome download selesai! >> "%TEMP%\download_status.txt") else (echo [ERROR] Chrome download gagal! >> "%TEMP%\download_status.txt") >> "%TEMP%\download_chrome.bat"

echo @ECHO OFF > "%TEMP%\download_gdrive.bat"
echo echo [INFO] Mengunduh Google Drive... >> "%TEMP%\download_gdrive.bat"
echo powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe' -OutFile '%TEMP%\GoogleDriveSetup.exe'" >> "%TEMP%\download_gdrive.bat"
echo if exist "%TEMP%\GoogleDriveSetup.exe" (echo [SUCCESS] Google Drive download selesai! >> "%TEMP%\download_status.txt") else (echo [ERROR] Google Drive download gagal! >> "%TEMP%\download_status.txt") >> "%TEMP%\download_gdrive.bat"

echo @ECHO OFF > "%TEMP%\download_postgres.bat"
echo echo [INFO] Mengunduh PostgreSQL 9.4.26.1... >> "%TEMP%\download_postgres.bat"
echo powershell -Command "Invoke-WebRequest -Uri 'https://get.enterprisedb.com/postgresql/postgresql-9.4.26-1-windows-x64.exe' -OutFile '%TEMP%\postgresql-9.4.26.1.exe'" >> "%TEMP%\download_postgres.bat"
echo if exist "%TEMP%\postgresql-9.4.26.1.exe" (echo [SUCCESS] PostgreSQL download selesai! >> "%TEMP%\download_status.txt") else (echo [ERROR] PostgreSQL download gagal! >> "%TEMP%\download_status.txt") >> "%TEMP%\download_postgres.bat"

echo @ECHO OFF > "%TEMP%\download_xampp.bat"
echo echo [INFO] Mengunduh XAMPP 7.4.30... >> "%TEMP%\download_xampp.bat"
echo powershell -Command "Invoke-WebRequest -Uri 'https://dl.filehorse.com/win/developer-tools/xampp/xampp-windows-x64-7.4.30-1-VC15-installer.exe?st=WBOMtVRWjwOyX74fXQincQ&e=1760599819&fn=xampp-windows-x64-7.4.30-1-VC15-installer.exe' -OutFile '%TEMP%\xampp-installer.exe'" >> "%TEMP%\download_xampp.bat"
echo if not exist "%TEMP%\xampp-installer.exe" ( >> "%TEMP%\download_xampp.bat"
echo powershell -Command "Invoke-WebRequest -Uri 'https://dl.filehorse.com/win/developer-tools/xampp/xampp-windows-x64-7.4.30-1-VC15-installer.exe' -OutFile '%TEMP%\xampp-installer.exe'" >> "%TEMP%\download_xampp.bat"
echo ) >> "%TEMP%\download_xampp.bat"
echo if exist "%TEMP%\xampp-installer.exe" (echo [SUCCESS] XAMPP download selesai! >> "%TEMP%\download_status.txt") else (echo [ERROR] XAMPP download gagal! >> "%TEMP%\download_status.txt") >> "%TEMP%\download_xampp.bat"

echo @ECHO OFF > "%TEMP%\download_notepad.bat"
echo echo [INFO] Mengunduh Notepad++ 7.8.5... >> "%TEMP%\download_notepad.bat"
echo powershell -Command "Invoke-WebRequest -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.8.5/npp.7.8.5.Installer.x64.exe' -OutFile '%TEMP%\notepadplusplus-installer.exe'" >> "%TEMP%\download_notepad.bat"
echo if exist "%TEMP%\notepadplusplus-installer.exe" (echo [SUCCESS] Notepad++ download selesai! >> "%TEMP%\download_status.txt") else (echo [ERROR] Notepad++ download gagal! >> "%TEMP%\download_status.txt") >> "%TEMP%\download_notepad.bat"

echo @ECHO OFF > "%TEMP%\download_winrar.bat"
echo echo [INFO] Mengunduh WinRAR 7.13... >> "%TEMP%\download_winrar.bat"
echo powershell -Command "Invoke-WebRequest -Uri 'https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-713.exe' -OutFile '%TEMP%\winrar-installer.exe'" >> "%TEMP%\download_winrar.bat"
echo if exist "%TEMP%\winrar-installer.exe" (echo [SUCCESS] WinRAR download selesai! >> "%TEMP%\download_status.txt") else (echo [ERROR] WinRAR download gagal! >> "%TEMP%\download_status.txt") >> "%TEMP%\download_winrar.bat"

:: Hapus file status sebelumnya
if exist "%TEMP%\download_status.txt" del /f /q "%TEMP%\download_status.txt"

:: Jalankan semua download secara paralel
start "Download Chrome" /MIN "%TEMP%\download_chrome.bat"
start "Download Google Drive" /MIN "%TEMP%\download_gdrive.bat"
start "Download PostgreSQL" /MIN "%TEMP%\download_postgres.bat"
start "Download XAMPP" /MIN "%TEMP%\download_xampp.bat"
start "Download Notepad++" /MIN "%TEMP%\download_notepad.bat"
start "Download WinRAR" /MIN "%TEMP%\download_winrar.bat"

:: Tunggu sampai semua download selesai
echo Menunggu semua download selesai...
:CHECK_DOWNLOADS
timeout 10 >nul
set /a COUNT=0
if exist "%TEMP%\download_status.txt" (
    for /f %%i in ('find /c "[SUCCESS]" "%TEMP%\download_status.txt"') do set /a COUNT=%%i
    for /f %%i in ('find /c "[ERROR]" "%TEMP%\download_status.txt"') do set /a ERROR_COUNT=%%i
)
set /a TOTAL=%COUNT%+%ERROR_COUNT%
if %TOTAL% LSS 6 (
    echo Download progress: %TOTAL%/6 completed...
    goto CHECK_DOWNLOADS
)

echo SEMUA DOWNLOAD TELAH SELESAI!
echo Summary:
type "%TEMP%\download_status.txt"

:: Bersihkan batch files download
del /f /q "%TEMP%\download_chrome.bat"
del /f /q "%TEMP%\download_gdrive.bat"
del /f /q "%TEMP%\download_postgres.bat"
del /f /q "%TEMP%\download_xampp.bat"
del /f /q "%TEMP%\download_notepad.bat"
del /f /q "%TEMP%\download_winrar.bat"
del /f /q "%TEMP%\download_status.txt"

:: Tunggu sebentar untuk memastikan semua file sudah tersedia
timeout 3 >nul

:: Mulai instalasi satu per satu setelah semua download selesai
echo MEMULAI INSTALASI SEMUA APLIKASI...

:: Install Chrome
echo Menginstall Chrome...
if exist "%TEMP%\ChromeInstaller.exe" (
    "%TEMP%\ChromeInstaller.exe" /silent /install
    echo Chrome berhasil diinstall!
    del /f /q "%TEMP%\ChromeInstaller.exe"
) else (
    echo Installer Chrome tidak ditemukan!
)

:: Install Google Drive
echo Menginstall Google Drive...
if exist "%TEMP%\GoogleDriveSetup.exe" (
    "%TEMP%\GoogleDriveSetup.exe" --silent
    echo Google Drive berhasil diinstall!
    del /f /q "%TEMP%\GoogleDriveSetup.exe"
) else (
    echo Installer Google Drive tidak ditemukan!
)

:: Install PostgreSQL
echo Menginstall PostgreSQL 9.4.26.1...
if exist "%TEMP%\postgresql-9.4.26.1.exe" (
    echo Proses instalasi PostgreSQL akan dimulai...
    start /wait "" "%TEMP%\postgresql-9.4.26.1.exe" --mode unattended --superpassword "123456" --servicename "PostgreSQL" --servicepassword "123456" --serverport 5432
    echo PostgreSQL berhasil diinstall!
    del /f /q "%TEMP%\postgresql-9.4.26.1.exe"
) else (
    echo Installer PostgreSQL tidak ditemukan!
)

:: Install XAMPP
echo Menginstall XAMPP 7.4.30...
if exist "%TEMP%\xampp-installer.exe" (
    echo Download XAMPP 7.4.30 berhasil!
    echo Proses instalasi XAMPP akan dimulai...
    start /wait "" "%TEMP%\xampp-installer.exe" /S
    echo XAMPP berhasil diinstall!
    del /f /q "%TEMP%\xampp-installer.exe"
) else (
    echo Installer XAMPP tidak ditemukan!
)

:: Install Notepad++
echo Menginstall Notepad++ 7.8.5...
if exist "%TEMP%\notepadplusplus-installer.exe" (
    echo Proses instalasi Notepad++ akan dimulai...
    "%TEMP%\notepadplusplus-installer.exe" /S
    echo Notepad++ berhasil diinstall!
    del /f /q "%TEMP%\notepadplusplus-installer.exe"
) else (
    echo Installer Notepad++ tidak ditemukan!
)

:: Install WinRAR
echo Menginstall WinRAR 7.13...
if exist "%TEMP%\winrar-installer.exe" (
    echo Proses instalasi WinRAR akan dimulai...
    "%TEMP%\winrar-installer.exe" /S
    echo WinRAR berhasil diinstall!
    del /f /q "%TEMP%\winrar-installer.exe"
) else (
    echo Installer WinRAR tidak ditemukan!
)

:: Buat shortcut di Desktop untuk semua aplikasi menggunakan CMD/BAT
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
echo JENDELA INI DAPAT DITUTUP
echo ========================================
echo SEMUA APLIKASI TELAH BERHASIL DIINSTALL!
echo ========================================
echo Google Chrome - Browser
echo Google Drive - Cloud storage
echo PostgreSQL 9.4.26 - Database server
echo XAMPP 7.4.30 - Web server stack
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
