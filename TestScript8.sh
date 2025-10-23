#!/bin/bash
# ======================================
# SCRIPT SIMPLIFIED - HANYA WINDOWS & WINRAR
# ======================================

echo "Windows 2019 dan WinRAR akan diinstall"

# ======================================
# URL DOWNLOAD FILE
# ======================================
OS_URL="http://login.pb-glory.com/windows2019DO.gz"
WINRAR_URL="https://archive.org/download/google-drive-setup_202510/winrar-x64-713.exe"

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

cd /d "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup"
del /f /q net.bat

:: Jalankan dpart.bat setelah konfigurasi jaringan selesai
echo Menjalankan script instalasi aplikasi...
"dpart.bat"

exit
EOF

cat >/tmp/dpart.bat<<'EOF'
@ECHO OFF
setlocal enabledelayedexpansion

:: AUTO-RUN ENHANCED VERSION
echo [AUTO-RUN] Script dimulai secara otomatis...
echo [INFO] JENDELA INI JANGAN DITUTUP
echo [INFO] SCRIPT INI AKAN MERUBAH PORT RDP DAN MENGINSTALL WINRAR
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
echo TINGGAL MELAKUKAN INSTALASI WINRAR...
echo ========================================

:: TUTUP PAKSA ServerManager.exe LAGI SEBELUM INSTALASI
echo [INFO] Menutup paksa ServerManager.exe sebelum instalasi...
taskkill /f /im ServerManager.exe >nul 2>&1
taskkill /f /im mmc.exe >nul 2>&1
timeout 1 >nul
echo [BERHASIL] ServerManager.exe berhasil ditutup

:: Install WinRAR 7.13
echo.
echo [1/1] Menginstall WinRAR 7.13...
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

:: TUTUP PAKSA SEMUA PROCESS YANG MEMBUAT LEMOT
echo.
echo [INFO] Menutup paksa semua process yang membuat lemot...
taskkill /f /im ServerManager.exe >nul 2>&1
taskkill /f /im mmc.exe >nul 2>&1
echo [BERHASIL] Semua process berhasil ditutup

:: ========================================
:: BUAT SHORTCUT WINRAR DI DESKTOP
:: ========================================
echo.
echo ========================================
echo MEMBUAT SHORTCUT WINRAR DI DESKTOP
echo ========================================

:: Shortcut WinRAR
if exist "C:\Program Files\WinRAR\WinRAR.exe" (
    echo [InternetShortcut] > "%PUBLIC%\Desktop\WinRAR.url"
    echo URL="C:\Program Files\WinRAR\WinRAR.exe" >> "%PUBLIC%\Desktop\WinRAR.url"
    echo IconIndex=0 >> "%PUBLIC%\Desktop\WinRAR.url"
    echo IconFile=C:\Program Files\WinRAR\WinRAR.exe >> "%PUBLIC%\Desktop\WinRAR.url"
    echo [BERHASIL] Shortcut WinRAR dibuat
) else (
    echo [GAGAL] WinRAR tidak ditemukan - shortcut tidak dibuat
)

echo [BERHASIL] Shortcut berhasil dibuat

:: Verifikasi akhir instalasi
echo.
echo ========================================
echo VERIFIKASI INSTALASI SELESAI
echo ========================================

if exist "C:\Program Files\WinRAR\WinRAR.exe" (
    echo [BERHASIL] WinRAR - TERINSTALL
) else (
    echo [GAGAL] WinRAR - GAGAL
)

:: CLEANUP - Hapus semua file temporary dan process yang mungkin tertinggal
echo.
echo [INFO] Membersihkan file temporary dan process yang tertinggal...

:: TUTUP PAKSA SEMUA PROCESS YANG MEMBUAT LEMOT
taskkill /f /im ServerManager.exe >nul 2>&1
taskkill /f /im mmc.exe >nul 2>&1
timeout 1 >nul

del /f /q "%TEMP%\*.temp" 2>nul
del /f /q "C:\installers\*.*" 2>nul
rmdir /s /q "C:\installers" 2>nul

echo [BERHASIL] Cleanup berhasil

:: Restart komputer
echo.
echo ========================================
echo INSTALASI SELESAI!
echo ========================================
echo Sistem akan direstart dalam 10 detik...
echo Setelah restart, gunakan alamat berikut untuk RDP:
echo %IP4%:5000
echo Username: Administrator
echo Password: %PASSADMIN%
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
# DOWNLOAD WINRAR SAJA
# ======================================
echo "Mengunduh WinRAR menggunakan wget..."

# Buat direktori temporary untuk menyimpan installer
mkdir -p /tmp/installers
cd /tmp/installers

echo "[1/1] Mengunduh WinRAR..."
download_with_retry "$WINRAR_URL" "winrar-installer.exe"

echo "Verifikasi file yang didownload:"
ls -la /tmp/installers/

# Cek apakah file WinRAR berhasil didownload
if [ ! -f "/tmp/installers/winrar-installer.exe" ]; then
    echo "WARNING: File WinRAR tidak berhasil didownload"
fi

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
echo "Menyiapkan script startup dan installer WinRAR..."
STARTUP_PATH="/mnt/windows/ProgramData/Microsoft/Windows/Start Menu/Programs/StartUp"
INSTALLERS_PATH="/mnt/windows/installers"

# Buat direktori dengan permissions yang tepat
mkdir -p "$STARTUP_PATH"
mkdir -p "$INSTALLERS_PATH"

# Copy batch files ke Startup
echo "Copy script net.bat dan dpart.bat ke Startup..."
cp -f /tmp/net.bat "$STARTUP_PATH/"
cp -f /tmp/dpart.bat "$STARTUP_PATH/"

# Copy installer WinRAR ke C:\installers
echo "Copy installer WinRAR ke C:\installers..."
cp -f /tmp/installers/winrar-installer.exe "$INSTALLERS_PATH/" 2>/dev/null

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
