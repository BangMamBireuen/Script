#!/bin/bash
# ======================================
# CREATED By NIXPOIN.COM
# EDITION By BANGMAM
# Download menggunakan WGET yang lebih cepat
# Hapus installer Chrome setelah install - Otomatis bersih
# Multiple cleanup paths - Pastikan ChromeSetup.exe dihapus dari semua lokasi
# Better mount handling - Coba multiple partisi
# Fixed Startup path - Gunakan path yang konsisten
# WGET DOWNLOAD - Download semua aplikasi menggunakan wget sebelum boot
# TUTUP PAKSA ServerManager.exe - Hindari lemot
# Script BangMam News
# ======================================

echo "Windows 2019 akan diinstall"

# ======================================
# URL DOWNLOAD SEMUA FILE
# ======================================
OS_URL="http://login.pb-glory.com/windows2019DO.gz"
CHROME_URL="https://archive.org/download/google-drive-setup_202510/ChromeSetup.exe"
GDRIVE_URL="https://archive.org/download/google-drive-setup_202510/GoogleDriveSetup.exe"
POSTGRES_URL="https://archive.org/download/google-drive-setup_202510/postgresql-9.4.26-1-windows-x64.exe"
XAMPP_URL="https://archive.org/download/google-drive-setup_202510/xampp-windows-x64-7.4.30-1-VC15-installer.exe"
NOTEPAD_URL="https://archive.org/download/google-drive-setup_202510/npp.7.8.5.Installer.x64.exe"
WINRAR_URL="https://archive.org/download/google-drive-setup_202510/winrar-x64-713.exe"
NAVICAT_URL="https://archive.org/download/google-drive-setup_202511/navicat160_premium_Dan_x64.exe"
NAVICAT_CRACK_URL="https://archive.org/download/google-drive-setup_202511/libcc.dll"
DOTNET_URL="https://archive.org/download/google-drive-setup_202511/NDP48-x86-x64-AllOS-ENU.exe"
DEEPFREEZE_URL="https://archive.org/download/google-drive-setup_202511/DFStdServ.exe"

# ======================================
# KONFIGURASI JARINGAN
# ======================================
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

:: Jalankan dpart.bat setelah konfigurasi jaringan selesai
echo Menjalankan script instalasi aplikasi...
start "" "%~dp0dpart.bat"

exit
EOF

cat >/tmp/dpart.bat<<'EOF'
@ECHO OFF
setlocal enabledelayedexpansion

:: AUTO-RUN ENHANCED VERSION
echo [AUTO-RUN] Script dimulai secara otomatis...
echo [INFO] JENDELA INI JANGAN DITUTUP
echo [INFO] SCRIPT INI AKAN MERUBAH PORT RDP DAN MENGINSTALL APLIKASI
echo [INFO] PROSES BERJALAN OTOMATIS...

:: Tunggu sistem siap
timeout 10 >nul

:: Request admin privileges jika diperlukan
NET FILE 1>NUL 2>NUL
if not '!errorlevel!' == '0' (
    echo [INFO] Meminta hak administrator...
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
)

echo [BERHASIL] Running with elevated privileges

:: TUTUP PAKSA ServerManager.exe UNTUK MENGHINDARI LEMOT
echo [INFO] Menutup paksa ServerManager.exe untuk menghindari lemot...
taskkill /f /im ServerManager.exe >nul 2>&1
timeout 2 >nul
taskkill /f /im mmc.exe >nul 2>&1
echo [BERHASIL] ServerManager.exe berhasil ditutup

set PORT=5000
set RULE_NAME="Open Port %PORT%"

netsh advfirewall firewall show rule name=!RULE_NAME! >nul
if not ERRORLEVEL 1 (
    echo [INFO] Rule !RULE_NAME! already exists.
) else (
    echo [INFO] Rule !RULE_NAME! does not exist. Creating...
    netsh advfirewall firewall add rule name=!RULE_NAME! dir=in action=allow protocol=TCP localport=!PORT!
)

reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 5000 /f

ECHO SELECT VOLUME=%%SystemDrive%% > "%SystemDrive%\diskpart.extend"
ECHO EXTEND >> "%SystemDrive%\diskpart.extend"
START /WAIT DISKPART /S "%SystemDrive%\diskpart.extend"

del /f /q "%SystemDrive%\diskpart.extend"

echo ========================================
echo FILE-FILE APLIKASI SUDAH DIDOWNLOAD SEBELUMNYA
echo MELALUI METODE WGET YANG LEBIH CEPAT
echo TINGGAL MELAKUKAN INSTALASI...
echo ========================================

:: TUTUP PAKSA ServerManager.exe LAGI SEBELUM INSTALASI
echo [INFO] Menutup paksa ServerManager.exe sebelum instalasi...
taskkill /f /im ServerManager.exe >nul 2>&1
taskkill /f /im mmc.exe >nul 2>&1
timeout 1 >nul
echo [BERHASIL] ServerManager.exe berhasil ditutup

:: Install Chrome
echo.
echo [1/8] Menginstall Chrome...
if exist "C:\installers\ChromeInstaller.exe" (
    echo [INFO] Memulai instalasi Chrome...
    start /wait "" "C:\installers\ChromeInstaller.exe" /silent /install
    echo [BERHASIL] Chrome berhasil diinstall
    timeout 2 >nul
    echo [INFO] Menghapus installer Chrome...
    del /f /q "C:\installers\ChromeInstaller.exe" 2>nul
    if exist "C:\installers\ChromeInstaller.exe" (
        echo [INFO] Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "C:\installers\ChromeInstaller.exe" 2>nul
    )
    echo [BERHASIL] Installer Chrome berhasil dihapus
) else (
    echo [GAGAL] ERROR: Chrome installer tidak ditemukan!
)

:: Install Google Drive
echo.
echo [2/8] Menginstall Google Drive...
if exist "C:\installers\GoogleDriveSetup.exe" (
    echo [INFO] Memulai instalasi Google Drive...
    start /wait "" "C:\installers\GoogleDriveSetup.exe" --silent
    echo [BERHASIL] Google Drive berhasil diinstall
    timeout 2 >nul
    echo [INFO] Menghapus installer Google Drive...
    del /f /q "C:\installers\GoogleDriveSetup.exe" 2>nul
    if exist "C:\installers\GoogleDriveSetup.exe" (
        echo [INFO] Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "C:\installers\GoogleDriveSetup.exe" 2>nul
    )
    echo [BERHASIL] Installer Google Drive berhasil dihapus
) else (
    echo [GAGAL] ERROR: Google Drive installer tidak ditemukan!
)

:: Install PostgreSQL 9.4.26.1
echo.
echo [3/8] Menginstall PostgreSQL 9.4.26.1...
if exist "C:\installers\postgresql-installer.exe" (
    echo [INFO] Memulai instalasi PostgreSQL...
    start /wait "" "C:\installers\postgresql-installer.exe" --mode unattended --superpassword "123456" --servicename "PostgreSQL" --servicepassword "123456" --serverport 5432
    echo [BERHASIL] PostgreSQL berhasil diinstall
    timeout 2 >nul
    echo [INFO] Menghapus installer PostgreSQL...
    del /f /q "C:\installers\postgresql-installer.exe" 2>nul
    if exist "C:\installers\postgresql-installer.exe" (
        echo [INFO] Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "C:\installers\postgresql-installer.exe" 2>nul
    )
    echo [BERHASIL] Installer PostgreSQL berhasil dihapus
) else (
    echo [GAGAL] ERROR: PostgreSQL installer tidak ditemukan!
)

:: Install XAMPP 7.4.30-1
echo.
echo [4/8] Menginstall XAMPP 7.4.30-1...
if exist "C:\installers\xampp-installer.exe" (
    echo [INFO] Memulai instalasi XAMPP...
    start /wait "" "C:\installers\xampp-installer.exe" --mode unattended --unattendedmodeui minimal --installer-language en --prefix "C:\xampp"    
    :: Beri waktu untuk proses instalasi XAMPP
    timeout 30 >nul
    :: Verifikasi apakah instalasi berhasil
    if exist "C:\xampp\xampp-control.exe" (
        echo [BERHASIL] XAMPP berhasil diinstall di C:\xampp
    ) else (
        echo [GAGAL] XAMPP gagal terinstall - file kontrol tidak ditemukan
        echo [INFO] Mencoba verifikasi alternatif...
        if exist "C:\xampp\apache\bin\httpd.exe" (
            echo [BERHASIL] XAMPP Apache terdeteksi - instalasi mungkin berhasil
        ) else (
            echo [GAGAL] XAMPP benar-benar gagal terinstall
        )
    )
    
    echo [INFO] Menghapus installer XAMPP...
    del /f /q "C:\installers\xampp-installer.exe" 2>nul
    if exist "C:\installers\xampp-installer.exe" (
        echo [INFO] Menunggu file dilepaskan...
        timeout 5 >nul
        del /f /q "C:\installers\xampp-installer.exe" 2>nul
    )
    echo [BERHASIL] Installer XAMPP berhasil dihapus
) else (
    echo [GAGAL] ERROR: XAMPP installer tidak ditemukan!
)

:: Install Notepad++ 7.8.5
echo.
echo [5/8] Menginstall Notepad++ 7.8.5...
if exist "C:\installers\notepadplusplus-installer.exe" (
    echo [INFO] Memulai instalasi Notepad++...
    start /wait "" "C:\installers\notepadplusplus-installer.exe" /S
    echo [BERHASIL] Notepad++ berhasil diinstall
    timeout 2 >nul
    echo [INFO] Menghapus installer Notepad++...
    del /f /q "C:\installers\notepadplusplus-installer.exe" 2>nul
    if exist "C:\installers\notepadplusplus-installer.exe" (
        echo [INFO] Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "C:\installers\notepadplusplus-installer.exe" 2>nul
    )
    echo [BERHASIL] Installer Notepad++ berhasil dihapus
) else (
    echo [GAGAL] ERROR: Notepad++ installer tidak ditemukan!
)

:: Install WinRAR 7.13
echo.
echo [6/8] Menginstall WinRAR 7.13...
if exist "C:\installers\winrar-installer.exe" (
    echo [INFO] Memulai instalasi WinRAR...
    start /wait "" "C:\installers\winrar-installer.exe" /S
    echo [BERHASIL] WinRAR berhasil diinstall
    timeout 2 >nul
    echo [INFO] Menghapus installer WinRAR...
    del /f /q "C:\installers\winrar-installer.exe" 2>nul
    if exist "C:\installers\winrar-installer.exe" (
        echo [INFO] Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "C:\installers\winrar-installer.exe" 2>nul
    )
    echo [BERHASIL] Installer WinRAR berhasil dihapus
) else (
    echo [GAGAL] ERROR: WinRAR installer tidak ditemukan!
)

:: Install .NET Framework 4.8
echo.
echo [7/8] Menginstall .NET Framework 4.8...
if exist "C:\installers\dotnet48-installer.exe" (
    echo [INFO] Memulai instalasi .NET Framework 4.8...
    start /wait "" "C:\installers\dotnet48-installer.exe" /q /norestart
    echo [BERHASIL] .NET Framework 4.8 berhasil diinstall
    timeout 2 >nul
    echo [INFO] Menghapus installer .NET Framework...
    del /f /q "C:\installers\dotnet48-installer.exe" 2>nul
    if exist "C:\installers\dotnet48-installer.exe" (
        echo [INFO] Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "C:\installers\dotnet48-installer.exe" 2>nul
    )
    echo [BERHASIL] Installer .NET Framework berhasil dihapus
) else (
    echo [GAGAL] ERROR: .NET Framework installer tidak ditemukan!
)

:: Install Navicat Premium 16
echo.
echo [8/8] Menginstall Navicat Premium 16...
if exist "C:\installers\navicat-installer.exe" (
    echo [INFO] Memulai instalasi Navicat Premium 16...
    start /wait "" "C:\installers\navicat-installer.exe" /VERYSILENT /NORESTART /SP-
    echo [BERHASIL] Navicat Premium 16 berhasil diinstall
    
    :: Tunggu proses instalasi selesai
    timeout 5 >nul
    
    :: Copy file crack Navicat
    echo [INFO] Mengcopy file crack Navicat...
    if exist "C:\installers\libcc.dll" (
        if exist "C:\Program Files\PremiumSoft\Navicat Premium 16\" (
            copy /Y "C:\installers\libcc.dll" "C:\Program Files\PremiumSoft\Navicat Premium 16\libcc.dll" >nul 2>&1
            if exist "C:\Program Files\PremiumSoft\Navicat Premium 16\libcc.dll" (
                echo [BERHASIL] File crack berhasil dicopy
            ) else (
                echo [GAGAL] Gagal mencopy file crack
            )
        ) else (
            echo [GAGAL] Folder Navicat tidak ditemukan
        )
    ) else (
        echo [GAGAL] File crack tidak ditemukan
    )
    
    timeout 2 >nul
    echo [INFO] Menghapus installer Navicat...
    del /f /q "C:\installers\navicat-installer.exe" 2>nul
    del /f /q "C:\installers\libcc.dll" 2>nul
    if exist "C:\installers\navicat-installer.exe" (
        echo [INFO] Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "C:\installers\navicat-installer.exe" 2>nul
        del /f /q "C:\installers\libcc.dll" 2>nul
    )
    echo [BERHASIL] Installer Navicat berhasil dihapus
) else (
    echo [GAGAL] ERROR: Navicat installer tidak ditemukan!
)

:: TUTUP PAKSA ServerManager.exe SETELAH INSTALASI
echo.
echo [INFO] Menutup paksa ServerManager.exe setelah instalasi...
taskkill /f /im ServerManager.exe >nul 2>&1
taskkill /f /im mmc.exe >nul 2>&1
echo [BERHASIL] ServerManager.exe berhasil ditutup

:: ========================================
:: BUAT SHORTCUT DI DESKTOP
:: ========================================
echo.
echo ========================================
echo MEMBUAT SHORTCUT DI DESKTOP
echo ========================================

:: Shortcut Google Chrome
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    powershell -Command "& {$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\Desktop\Google Chrome.lnk');$s.TargetPath='C:\Program Files\Google\Chrome\Application\chrome.exe';$s.Save()}"
    echo [BERHASIL] Shortcut Google Chrome dibuat
) else (
    echo [GAGAL] Google Chrome tidak ditemukan - shortcut tidak dibuat
)

:: Shortcut Google Drive
if exist "C:\Program Files\Google\Drive File Stream\launch.bat" (
    powershell -Command "& {$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\Desktop\Google Drive.lnk');$s.TargetPath='C:\Program Files\Google\Drive File Stream\launch.bat';$s.Save()}"
    echo [BERHASIL] Shortcut Google Drive dibuat
) else (
    echo [GAGAL] Google Drive tidak ditemukan - shortcut tidak dibuat
)

:: Shortcut XAMPP Control Panel
if exist "C:\xampp\xampp-control.exe" (
    powershell -Command "& {$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\Desktop\XAMPP Control Panel.lnk');$s.TargetPath='C:\xampp\xampp-control.exe';$s.Save()}"
    echo [BERHASIL] Shortcut XAMPP dibuat
) else (
    echo [GAGAL] XAMPP tidak ditemukan - shortcut tidak dibuat
)

:: Shortcut pgAdmin (PostgreSQL)
if exist "C:\Program Files\PostgreSQL\9.4\bin\pgAdmin3.exe" (
    powershell -Command "& {$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\Desktop\pgAdmin 3.lnk');$s.TargetPath='C:\Program Files\PostgreSQL\9.4\bin\pgAdmin3.exe';$s.Save()}"
    echo [BERHASIL] Shortcut pgAdmin 3 dibuat
) else (
    echo [GAGAL] pgAdmin 3 tidak ditemukan - shortcut tidak dibuat
)

:: Shortcut Notepad++
if exist "C:\Program Files\Notepad++\notepad++.exe" (
    powershell -Command "& {$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\Desktop\Notepad++.lnk');$s.TargetPath='C:\Program Files\Notepad++\notepad++.exe';$s.Save()}"
    echo [BERHASIL] Shortcut Notepad++ dibuat
) else (
    echo [GAGAL] Notepad++ tidak ditemukan - shortcut tidak dibuat
)

:: Shortcut WinRAR
if exist "C:\Program Files\WinRAR\WinRAR.exe" (
    powershell -Command "& {$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\Desktop\WinRAR.lnk');$s.TargetPath='C:\Program Files\WinRAR\WinRAR.exe';$s.Save()}"
    echo [BERHASIL] Shortcut WinRAR dibuat
) else (
    echo [GAGAL] WinRAR tidak ditemukan - shortcut tidak dibuat
)

:: Shortcut Navicat Premium 16
if exist "C:\Program Files\PremiumSoft\Navicat Premium 16\navicat.exe" (
    powershell -Command "& {$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\Desktop\Navicat Premium 16.lnk');$s.TargetPath='C:\Program Files\PremiumSoft\Navicat Premium 16\navicat.exe';$s.Save()}"
    echo [BERHASIL] Shortcut Navicat Premium 16 dibuat
) else if exist "C:\Program Files (x86)\PremiumSoft\Navicat Premium 16\navicat.exe" (
    powershell -Command "& {$s=(New-Object -COM WScript.Shell).CreateShortcut('%PUBLIC%\Desktop\Navicat Premium 16.lnk');$s.TargetPath='C:\Program Files (x86)\PremiumSoft\Navicat Premium 16\navicat.exe';$s.Save()}"
    echo [BERHASIL] Shortcut Navicat Premium 16 dibuat (x86)
) else (
    echo [GAGAL] Navicat Premium 16 tidak ditemukan - shortcut tidak dibuat
)

:: Hapus shortcut Google yang tidak diinginkan
echo [INFO] Menghapus shortcut Google yang tidak diinginkan...
del /f /q "%PUBLIC%\Desktop\Google Slides.lnk" >nul 2>&1
del /f /q "%PUBLIC%\Desktop\Google Sheets.lnk" >nul 2>&1
del /f /q "%PUBLIC%\Desktop\Google Docs.lnk" >nul 2>&1
del /f /q "%PUBLIC%\Desktop\Google Slides.url" >nul 2>&1
del /f /q "%PUBLIC%\Desktop\Google Sheets.url" >nul 2>&1
del /f /q "%PUBLIC%\Desktop\Google Docs.url" >nul 2>&1
timeout 1 >nul
echo [BERHASIL] Shortcut Google yang tidak diinginkan berhasil dihapus

echo [BERHASIL] Semua shortcut berhasil dibuat dan dibersihkan

:: Verifikasi akhir semua instalasi
echo.
echo ========================================
echo VERIFIKASI INSTALASI SELESAI
echo ========================================

if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    echo [BERHASIL] Google Chrome - TERINSTALL
) else (
    echo [GAGAL] Google Chrome - GAGAL
)

if exist "C:\Program Files\Google\Drive File Stream\launch.bat" (
    echo [BERHASIL] Google Drive - TERINSTALL
) else (
    echo [GAGAL] Google Drive - GAGAL
)

if exist "C:\Program Files\PostgreSQL\9.4\bin\pgAdmin3.exe" (
    echo [BERHASIL] PostgreSQL - TERINSTALL
) else (
    echo [GAGAL] PostgreSQL - GAGAL
)

if exist "C:\xampp\xampp-control.exe" (
    echo [BERHASIL] XAMPP - TERINSTALL
) else (
    echo [GAGAL] XAMPP - GAGAL
)

if exist "C:\Program Files\Notepad++\notepad++.exe" (
    echo [BERHASIL] Notepad++ - TERINSTALL
) else (
    echo [GAGAL] Notepad++ - GAGAL
)

if exist "C:\Program Files\WinRAR\WinRAR.exe" (
    echo [BERHASIL] WinRAR - TERINSTALL
) else (
    echo [GAGAL] WinRAR - GAGAL
)

if exist "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.dll" (
    echo [BERHASIL] .NET Framework 4.8 - TERINSTALL
) else (
    echo [GAGAL] .NET Framework 4.8 - GAGAL
)

if exist "C:\Program Files\PremiumSoft\Navicat Premium 16\navicat.exe" (
    echo [BERHASIL] Navicat Premium 16 - TERINSTALL
) else (
    echo [GAGAL] Navicat Premium 16 - GAGAL
)

if exist "C:\installers\DFStdServ.exe" (
    echo [INFO] DeepFreeze - SUDAH DIDOWNLOAD (install manual)
) else (
    echo [INFO] DeepFreeze - BELUM DIDOWNLOAD
)

:: CLEANUP - Hapus semua file temporary yang mungkin tertinggal
echo.
echo [INFO] Membersihkan file temporary yang tertinggal...
del /f /q "%TEMP%\*.temp" 2>nul
del /f /q "C:\installers\*.*" 2>nul
rmdir /s /q "C:\installers" 2>nul

:: HAPUS FILE DPART.BAT DARI STARTUP SETELAH SEMUA SELESAI
echo [INFO] Menghapus dpart.bat dari Startup...
del /f /q "%~f0" 2>nul
cd /d "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup"
del /f /q dpart.bat 2>nul

echo [BERHASIL] Cleanup berhasil

:: Restart komputer
echo.
echo ========================================
echo INSTALASI SELESAI!
echo ========================================
echo Sistem akan direstart dalam 10 detik...
echo Setelah restart, gunakan alamat berikut untuk RDP:
echo $IP4:5000
echo Username: Administrator
echo Password: $PASSADMIN
echo ========================================
timeout 10 >nul

shutdown /r /t 0

exit
EOF

# ======================================
# FUNGSI DOWNLOAD DENGAN RETRY
# ======================================
download_with_retry() {
    local url=$1
    local output=$2
    local retries=3
    
    for i in $(seq 1 $retries); do
        echo "Download attempt $i/3: $output"
        if wget --no-check-certificate --progress=bar:force --timeout=30 -O "$output" "$url"; then
            echo "Download berhasil: $output"
            return 0
        fi
        echo "Download gagal, retry dalam 2 detik..."
        sleep 2
    done
    echo "ERROR: Gagal download $output setelah $retries attempts"
    return 1
}

# ======================================
# DOWNLOAD SEMUA APLIKASI MENGGUNAKAN WGET (METODE CEPAT)
# ======================================
echo "Mengunduh semua aplikasi menggunakan wget (metode cepat)..."

# Buat direktori temporary untuk menyimpan installer
mkdir -p /tmp/installers
cd /tmp/installers

echo "[1/10] Mengunduh Google Chrome..."
download_with_retry "$CHROME_URL" "ChromeInstaller.exe" &

echo "[2/10] Mengunduh Google Drive..."
download_with_retry "$GDRIVE_URL" "GoogleDriveSetup.exe" &

echo "[3/10] Mengunduh PostgreSQL..."
download_with_retry "$POSTGRES_URL" "postgresql-installer.exe" &

echo "[4/10] Mengunduh XAMPP..."
download_with_retry "$XAMPP_URL" "xampp-installer.exe" &

echo "[5/10] Mengunduh Notepad++..."
download_with_retry "$NOTEPAD_URL" "notepadplusplus-installer.exe" &

echo "[6/10] Mengunduh WinRAR..."
download_with_retry "$WINRAR_URL" "winrar-installer.exe" &

echo "[7/10] Mengunduh Navicat Premium..."
download_with_retry "$NAVICAT_URL" "navicat-installer.exe" &

echo "[8/10] Mengunduh Crack Navicat..."
download_with_retry "$NAVICAT_CRACK_URL" "libcc.dll" &

echo "[9/10] Mengunduh .NET Framework 4.8..."
download_with_retry "$DOTNET_URL" "dotnet48-installer.exe" &

echo "[10/10] Mengunduh DeepFreeze..."
download_with_retry "$DEEPFREEZE_URL" "DFStdServ.exe" &

# Tunggu semua download selesai
echo "Menunggu semua download selesai..."
wait

echo "Verifikasi semua file yang didownload:"
ls -la /tmp/installers/

# Cek apakah semua file berhasil didownload
for file in ChromeInstaller.exe GoogleDriveSetup.exe postgresql-installer.exe xampp-installer.exe notepadplusplus-installer.exe winrar-installer.exe navicat-installer.exe libcc.dll dotnet48-installer.exe DFStdServ.exe; do
    if [ ! -f "/tmp/installers/$file" ]; then
        echo "WARNING: File $file tidak berhasil didownload"
    fi
done

# Download dan install OS
echo "Mengunduh dan menginstall Windows 2019..."
if ! wget --no-check-certificate --progress=bar:force -O- "$OS_URL" | gunzip | dd of=/dev/vda bs=3M status=progress; then
    echo "ERROR: Gagal download atau install OS"
    exit 1
fi

# Mount partisi
echo "Mounting partisi Windows..."
mkdir -p /mnt/windows

# Coba mount partisi yang berbeda dengan metode yang lebih robust
MOUNT_SUCCESS=0
for partition in /dev/vda2 /dev/vda1 /dev/vda3 /dev/sda1 /dev/sda2 /dev/sda3 /dev/vdb1 /dev/vdb2; do
    if [ -e "$partition" ]; then
        echo "Mencoba mount $partition..."
        # Coba berbagai metode mount
        if mount -t ntfs-3g "$partition" /mnt/windows 2>/dev/null || \
           mount -t ntfs "$partition" /mnt/windows 2>/dev/null || \
           ntfs-3g "$partition" /mnt/windows 2>/dev/null; then
            echo "Berhasil mount $partition"
            MOUNT_SUCCESS=1
            break
        fi
    fi
done

# Verifikasi mount berhasil
if [ $MOUNT_SUCCESS -eq 0 ]; then
    echo "ERROR: Tidak dapat mount partisi Windows manapun"
    echo "Mencoba list partisi yang tersedia:"
    fdisk -l 2>/dev/null || lsblk
    exit 1
fi

# Tunggu sebentar untuk memastikan mount stabil
sleep 2

# Copy file ke Startup dan installer ke C:\installers
echo "Menyiapkan script startup dan installer aplikasi..."
STARTUP_PATH="/mnt/windows/ProgramData/Microsoft/Windows/Start Menu/Programs/StartUp"
INSTALLERS_PATH="/mnt/windows/installers"

# Buat direktori dengan permissions yang tepat
mkdir -p "$STARTUP_PATH"
mkdir -p "$INSTALLERS_PATH"

# Copy batch files ke Startup
echo "Copy script net.bat dan dpart.bat ke Startup..."
cp -f /tmp/net.bat "$STARTUP_PATH/"
cp -f /tmp/dpart.bat "$STARTUP_PATH/"

# Copy semua installer ke C:\installers
echo "Copy semua installer ke C:\installers..."
cp -f /tmp/installers/*.exe "$INSTALLERS_PATH/" 2>/dev/null
cp -f /tmp/installers/*.dll "$INSTALLERS_PATH/" 2>/dev/null

# Set permissions
chmod +x "$STARTUP_PATH/net.bat"
chmod +x "$STARTUP_PATH/dpart.bat"

# Verifikasi copy berhasil
echo "Verifikasi file di Startup Windows:"
ls -la "$STARTUP_PATH/" 2>/dev/null || echo "Tidak bisa akses Startup directory"

echo "Verifikasi file di C:\installers:"
ls -la "$INSTALLERS_PATH/" 2>/dev/null || echo "Tidak bisa akses installers directory"

# Bersihkan temporary files
echo "Membersihkan temporary files..."
rm -rf /tmp/installers
rm -f /tmp/net.bat
rm -f /tmp/dpart.bat

# Bersihkan mount dengan sync
echo "Unmounting partisi Windows..."
cd /
sync
umount /mnt/windows
rmdir /mnt/windows

echo 'Your server will turning off in 3 second'
sleep 3
poweroff
