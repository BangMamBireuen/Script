# !/bin/bash
# ======================================
# CREATED By NIXPOIN.COM
# EDITION By BANGMAM
# Download Chrome langsung di batch file - Lebih reliable
# Hapus installer Chrome setelah install - Otomatis bersih
# Multiple cleanup paths - Pastikan ChromeSetup.exe dihapus dari semua lokasi
# Better mount handling - Coba multiple partisi
# Fixed Startup path - Gunakan path yang konsisten
# PARALLEL DOWNLOAD - Download dengan file temporary selama proses
# ======================================

echo "Windows 2019 akan diinstall"

PILIHOS="https://download1511.mediafire.com/xdbaox9d1vbg27a9bRjzdOpwHZmSSqrfBQ1VsMqybHY1c10uFbejOMUUiWdd6rG2rMM6FGJ_dlyZ1B3696EcMgtXFyvIT80GUMzhtIskQ2I88bFy48FKeup8LyDmQ1hHObQ8Pzt_Ldj_d5LpyV-n1UCR03XMktAlGosVsuLBPQ/oi1bb1p9heg6sbm/windows2019DO.gz"
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
setlocal enabledelayedexpansion

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

:: Download semua file secara paralel dengan ekstensi .temp
echo ========================================
echo MENGUNDUH SEMUA FILE SECARA PARALEL...
echo FILE AKAN DISIMPAN SEBAGAI .temp SELAMA DOWNLOAD
echo ========================================

echo [1/6] Memulai download Chrome...
start "Download Chrome" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TEMP%\ChromeInstaller.temp'; if ($?) { Rename-Item '%TEMP%\ChromeInstaller.temp' 'ChromeInstaller.exe'; Write-Host '=== Chrome download completed ===' }"
set CHROME_PID=!errorlevel!

echo [2/6] Memulai download Google Drive...
start "Download Google Drive" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe' -OutFile '%TEMP%\GoogleDriveSetup.temp'; if ($?) { Rename-Item '%TEMP%\GoogleDriveSetup.temp' 'GoogleDriveSetup.exe'; Write-Host '=== Google Drive download completed ===' }"
set GDRIVE_PID=!errorlevel!

echo [3/6] Memulai download PostgreSQL...
start "Download PostgreSQL" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://get.enterprisedb.com/postgresql/postgresql-9.4.26-1-windows-x64.exe' -OutFile '%TEMP%\postgresql-9.4.26.1.temp'; if ($?) { Rename-Item '%TEMP%\postgresql-9.4.26.1.temp' 'postgresql-9.4.26.1.exe'; Write-Host '=== PostgreSQL download completed ===' }"
set POSTGRES_PID=!errorlevel!

echo [4/6] Memulai download XAMPP...
start "Download XAMPP" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://dl.filehorse.com/win/developer-tools/xampp/xampp-windows-x64-7.4.30-1-VC15-installer.exe?st=WBOMtVRWjwOyX74fXQincQ&e=1760599819&fn=xampp-windows-x64-7.4.30-1-VC15-installer.exe' -OutFile '%TEMP%\xampp-installer.temp'; if ($?) { Rename-Item '%TEMP%\xampp-installer.temp' 'xampp-installer.exe'; Write-Host '=== XAMPP download completed ===' }"
set XAMPP_PID=!errorlevel!

echo [5/6] Memulai download Notepad++...
start "Download Notepad++" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.8.5/npp.7.8.5.Installer.x64.exe' -OutFile '%TEMP%\notepadplusplus-installer.temp'; if ($?) { Rename-Item '%TEMP%\notepadplusplus-installer.temp' 'notepadplusplus-installer.exe'; Write-Host '=== Notepad++ download completed ===' }"
set NOTEPAD_PID=!errorlevel!

echo [6/6] Memulai download WinRAR...
start "Download WinRAR" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-713.exe' -OutFile '%TEMP%\winrar-installer.temp'; if ($?) { Rename-Item '%TEMP%\winrar-installer.temp' 'winrar-installer.exe'; Write-Host '=== WinRAR download completed ===' }"
set WINRAR_PID=!errorlevel!

:: Tunggu sampai semua file .exe tersedia (semua download selesai)
echo.
echo MENUNGGU SEMUA DOWNLOAD SELESAI...
echo File akan berubah dari .temp ke .exe ketika download selesai...
echo.

:CHECK_DOWNLOADS
timeout 3 >nul

:: Cek apakah semua file .exe sudah ada
set /a completed=0
set /a total=6

if exist "%TEMP%\ChromeInstaller.exe" set /a completed+=1
if exist "%TEMP%\GoogleDriveSetup.exe" set /a completed+=1
if exist "%TEMP%\postgresql-9.4.26.1.exe" set /a completed+=1
if exist "%TEMP%\xampp-installer.exe" set /a completed+=1
if exist "%TEMP%\notepadplusplus-installer.exe" set /a completed+=1
if exist "%TEMP%\winrar-installer.exe" set /a completed+=1

:: Tampilkan status detail
echo Progress Download: !completed!/6 files completed
if exist "%TEMP%\ChromeInstaller.exe" (echo ✓ Chrome) else (echo ✗ Chrome - downloading...)
if exist "%TEMP%\GoogleDriveSetup.exe" (echo ✓ Google Drive) else (echo ✗ Google Drive - downloading...)
if exist "%TEMP%\postgresql-9.4.26.1.exe" (echo ✓ PostgreSQL) else (echo ✗ PostgreSQL - downloading...)
if exist "%TEMP%\xampp-installer.exe" (echo ✓ XAMPP) else (echo ✗ XAMPP - downloading...)
if exist "%TEMP%\notepadplusplus-installer.exe" (echo ✓ Notepad++) else (echo ✗ Notepad++ - downloading...)
if exist "%TEMP%\winrar-installer.exe" (echo ✓ WinRAR) else (echo ✗ WinRAR - downloading...)
echo.

if !completed! equ !total! (
    echo ========================================
    echo SEMUA DOWNLOAD TELAH SELESAI!
    echo FILE SUDAH SIAP UNTUK DIINSTALL...
    echo ========================================
    timeout 2 >nul
    goto INSTALL_APPS
) else (
    echo Sedang menunggu download selesai...
    echo Jangan tutup jendela ini!
    echo.
    goto CHECK_DOWNLOADS
)

:INSTALL_APPS
echo ========================================
echo MEMULAI INSTALASI SEMUA APLIKASI...
echo ========================================

:: Install Chrome
echo.
echo [1/6] Menginstall Chrome...
if exist "%TEMP%\ChromeInstaller.exe" (
    echo Memulai instalasi Chrome...
    start /wait "" "%TEMP%\ChromeInstaller.exe" /silent /install
    echo ✓ Chrome berhasil diinstall
    timeout 1 >nul
    echo Menghapus installer Chrome...
    del /f /q "%TEMP%\ChromeInstaller.exe" 2>nul
    if exist "%TEMP%\ChromeInstaller.exe" (
        echo Menunggu file dilepaskan...
        timeout 2 >nul
        del /f /q "%TEMP%\ChromeInstaller.exe" 2>nul
    )
    echo ✓ Installer Chrome berhasil dihapus
) else (
    echo ✗ ERROR: Chrome installer tidak ditemukan!
)

:: Install Google Drive
echo.
echo [2/6] Menginstall Google Drive...
if exist "%TEMP%\GoogleDriveSetup.exe" (
    echo Memulai instalasi Google Drive...
    start /wait "" "%TEMP%\GoogleDriveSetup.exe" --silent
    echo ✓ Google Drive berhasil diinstall
    timeout 1 >nul
    echo Menghapus installer Google Drive...
    del /f /q "%TEMP%\GoogleDriveSetup.exe" 2>nul
    if exist "%TEMP%\GoogleDriveSetup.exe" (
        echo Menunggu file dilepaskan...
        timeout 2 >nul
        del /f /q "%TEMP%\GoogleDriveSetup.exe" 2>nul
    )
    echo ✓ Installer Google Drive berhasil dihapus
) else (
    echo ✗ ERROR: Google Drive installer tidak ditemukan!
)

:: Install PostgreSQL 9.4.26.1
echo.
echo [3/6] Menginstall PostgreSQL 9.4.26.1...
if exist "%TEMP%\postgresql-9.4.26.1.exe" (
    echo Memulai instalasi PostgreSQL...
    start /wait "" "%TEMP%\postgresql-9.4.26.1.exe" --mode unattended --superpassword "123456" --servicename "PostgreSQL" --servicepassword "123456" --serverport 5432
    echo ✓ PostgreSQL berhasil diinstall
    timeout 1 >nul
    echo Menghapus installer PostgreSQL...
    del /f /q "%TEMP%\postgresql-9.4.26.1.exe" 2>nul
    if exist "%TEMP%\postgresql-9.4.26.1.exe" (
        echo Menunggu file dilepaskan...
        timeout 2 >nul
        del /f /q "%TEMP%\postgresql-9.4.26.1.exe" 2>nul
    )
    echo ✓ Installer PostgreSQL berhasil dihapus
) else (
    echo ✗ ERROR: PostgreSQL installer tidak ditemukan!
)

:: Install XAMPP 7.4.30
echo.
echo [4/6] Menginstall XAMPP 7.4.30...
if exist "%TEMP%\xampp-installer.exe" (
    echo Memulai instalasi XAMPP...
    start /wait "" "%TEMP%\xampp-installer.exe" /S
    echo ✓ XAMPP berhasil diinstall
    timeout 1 >nul
    echo Menghapus installer XAMPP...
    del /f /q "%TEMP%\xampp-installer.exe" 2>nul
    if exist "%TEMP%\xampp-installer.exe" (
        echo Menunggu file dilepaskan...
        timeout 2 >nul
        del /f /q "%TEMP%\xampp-installer.exe" 2>nul
    )
    echo ✓ Installer XAMPP berhasil dihapus
) else (
    echo ✗ ERROR: XAMPP installer tidak ditemukan!
    echo Mencoba download ulang XAMPP...
    powershell -Command "Invoke-WebRequest -Uri 'https://dl.filehorse.com/win/developer-tools/xampp/xampp-windows-x64-7.4.30-1-VC15-installer.exe' -OutFile '%TEMP%\xampp-installer.temp'; if ($?) { Rename-Item '%TEMP%\xampp-installer.temp' 'xampp-installer.exe' }"
    if exist "%TEMP%\xampp-installer.exe" (
        start /wait "" "%TEMP%\xampp-installer.exe" /S
        del /f /q "%TEMP%\xampp-installer.exe" 2>nul
    )
)

:: Install Notepad++ 7.8.5
echo.
echo [5/6] Menginstall Notepad++ 7.8.5...
if exist "%TEMP%\notepadplusplus-installer.exe" (
    echo Memulai instalasi Notepad++...
    start /wait "" "%TEMP%\notepadplusplus-installer.exe" /S
    echo ✓ Notepad++ berhasil diinstall
    timeout 1 >nul
    echo Menghapus installer Notepad++...
    del /f /q "%TEMP%\notepadplusplus-installer.exe" 2>nul
    if exist "%TEMP%\notepadplusplus-installer.exe" (
        echo Menunggu file dilepaskan...
        timeout 2 >nul
        del /f /q "%TEMP%\notepadplusplus-installer.exe" 2>nul
    )
    echo ✓ Installer Notepad++ berhasil dihapus
) else (
    echo ✗ ERROR: Notepad++ installer tidak ditemukan!
)

:: Install WinRAR 7.13
echo.
echo [6/6] Menginstall WinRAR 7.13...
if exist "%TEMP%\winrar-installer.exe" (
    echo Memulai instalasi WinRAR...
    start /wait "" "%TEMP%\winrar-installer.exe" /S
    echo ✓ WinRAR berhasil diinstall
    timeout 1 >nul
    echo Menghapus installer WinRAR...
    del /f /q "%TEMP%\winrar-installer.exe" 2>nul
    if exist "%TEMP%\winrar-installer.exe" (
        echo Menunggu file dilepaskan...
        timeout 2 >nul
        del /f /q "%TEMP%\winrar-installer.exe" 2>nul
    )
    echo ✓ Installer WinRAR berhasil dihapus
) else (
    echo ✗ ERROR: WinRAR installer tidak ditemukan!
)

:: Buat shortcut di Desktop untuk semua aplikasi menggunakan CMD/BAT
echo.
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

echo ✓ Semua shortcut berhasil dibuat di Desktop!

:: Hapus batch file startup
cd /d "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup"
del /f /q dpart.bat

echo.
echo ========================================
echo SEMUA APLIKASI TELAH BERHASIL DIINSTALL!
echo ========================================
echo ✓ Google Chrome - Browser
echo ✓ Google Drive - Cloud storage
echo ✓ PostgreSQL 9.4.26 - Database server
echo ✓ XAMPP 7.4.30 - Web server stack
echo ✓ Notepad++ 7.8.5 - Text editor
echo ✓ WinRAR 7.13 - File archiver
echo ========================================
echo ✓ Shortcut sudah tersedia di Desktop!
echo ========================================
echo Jendela ini akan tertutup otomatis dalam 15 detik...
timeout 15 >nul
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
