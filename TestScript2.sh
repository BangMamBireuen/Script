#!/bin/bash
# ======================================
# Script instalasi WinRAR saja - FIXED VERSION
# ======================================

echo "Windows 2019 akan diinstall dengan WinRAR"

# ======================================
# URL DOWNLOAD
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
echo Menjalankan script instalasi WinRAR...
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
echo FILE WINRAR SUDAH DIDOWNLOAD SEBELUMNYA
echo MELALUI METODE WGET YANG LEBIH CEPAT
echo TINGGAL MELAKUKAN INSTALASI...
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
    echo [INFO] File installer ditemukan di: C:\installers\winrar-installer.exe
    
    start /wait "" "C:\installers\winrar-installer.exe" /S
    if !errorlevel! equ 0 (
        echo [BERHASIL] WinRAR berhasil diinstall
    ) else (
        echo [GAGAL] WinRAR gagal diinstall dengan error code: !errorlevel!
    )
    
    timeout 3 >nul
    echo [INFO] Menghapus installer WinRAR...
    del /f /q "C:\installers\winrar-installer.exe" 2>nul
    if exist "C:\installers\winrar-installer.exe" (
        echo [INFO] Menunggu file dilepaskan...
        timeout 5 >nul
        del /f /q "C:\installers\winrar-installer.exe" 2>nul
    )
    echo [BERHASIL] Installer WinRAR berhasil dihapus
) else (
    echo [GAGAL] ERROR: WinRAR installer tidak ditemukan!
    echo [INFO] Mencari file di C:\installers\...
    dir "C:\installers\" 2>nul
)

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
    echo [INFO] Mencari WinRAR di lokasi alternatif...
    dir "C:\Program Files\WinRAR\" 2>nul
    dir "C:\Program Files (x86)\WinRAR\" 2>nul
)

:: Verifikasi akhir instalasi WinRAR
echo.
echo ========================================
echo VERIFIKASI INSTALASI WINRAR
echo ========================================

if exist "C:\Program Files\WinRAR\WinRAR.exe" (
    echo [BERHASIL] WinRAR - TERINSTALL
    echo [INFO] Lokasi: C:\Program Files\WinRAR\WinRAR.exe
) else (
    echo [GAGAL] WinRAR - GAGAL
    echo [INFO] Mencoba lokasi alternatif...
    if exist "C:\Program Files (x86)\WinRAR\WinRAR.exe" (
        echo [BERHASIL] WinRAR - TERINSTALL (x86 version)
        echo [INFO] Lokasi: C:\Program Files (x86)\WinRAR\WinRAR.exe
    ) else (
        echo [GAGAL] WinRAR tidak ditemukan di kedua lokasi
    )
)

:: CLEANUP - Hapus semua file temporary dan process yang mungkin tertinggal
echo.
echo [INFO] Membersihkan file temporary dan process yang tertinggal...

:: TUTUP PAKSA SEMUA PROCESS YANG MEMBUAT LEMOT
taskkill /f /im ServerManager.exe >nul 2>&1
taskkill /f /im mmc.exe >nul 2>&1
timeout 2 >nul

del /f /q "%TEMP%\*.temp" 2>nul
del /f /q "C:\installers\*.*" 2>nul
rmdir /s /q "C:\installers" 2>nul

:: HAPUS FILE DPART.BAT DARI STARTUP SETELAH SEMUA SELESAI
echo [INFO] Menghapus dpart.bat dari Startup...
del /f /q "%~f0" 2>nul
cd /d "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup"
del /f /q dpart.bat 2>nul

echo [BERHASIL] Cleanup berhasil

:: ========================================
:: RESTART SETELAH INSTALASI SELESAI
:: ========================================
echo.
echo ========================================
echo INSTALASI WINRAR SELESAI!
echo ========================================
echo [SUCCESS] WinRAR berhasil diinstall
echo [SUCCESS] Shortcut berhasil dibuat di Desktop
echo.
echo SISTEM AKAN DIREBOOT DALAM 5 DETIK...
echo.
echo SETELAH REBOOT, GUNAKAN KONEKSI RDP:
echo Alamat: %IP4%:5000
echo Username: Administrator
echo Password: %PASSADMIN%
echo ========================================

:: Restart dengan waktu cukup untuk melihat pesan
timeout 5 >nul
echo [INFO] Melakukan restart sistem...
shutdown /r /f /t 1

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
# DOWNLOAD WINRAR MENGGUNAKAN WGET
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
    echo "ERROR: File WinRAR tidak berhasil didownload"
    exit 1
fi

# Download dan install OS
echo "Mengunduh dan menginstall Windows 2019..."
if ! wget --no-check-certificate --progress=bar:force -O- "$OS_URL" | gunzip | dd of=/dev/vda bs=3M status=progress; then
    echo "ERROR: Gagal download atau install OS"
    exit 1
fi

# Mount partisi - GUNAKAN METODE SEDERHANA
echo "Mounting partisi Windows /dev/vda2..."
mkdir -p /mnt

# Tunggu sebentar sebelum mount
sleep 3

if mount.ntfs-3g /dev/vda2 /mnt 2>/dev/null; then
    echo "Berhasil mount /dev/vda2 ke /mnt"
else
    echo "Gagal mount /dev/vda2, mencoba metode alternatif..."
    # Coba metode alternatif
    if ntfs-3g /dev/vda2 /mnt 2>/dev/null; then
        echo "Berhasil mount dengan ntfs-3g langsung"
    else
        echo "ERROR: Gagal mount partisi Windows"
        echo "Partisi yang tersedia:"
        fdisk -l 2>/dev/null || lsblk
        exit 1
    fi
fi

# Tunggu mount stabil
sleep 2

# Copy file ke Startup dan installer ke C:\installers
echo "Menyiapkan script startup dan installer WinRAR..."
STARTUP_PATH="/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/StartUp"
INSTALLERS_PATH="/mnt/installers"

# Buat direktori dengan permissions yang tepat
mkdir -p "$STARTUP_PATH"
mkdir -p "$INSTALLERS_PATH"

# Copy batch files ke Startup
echo "Copy script net.bat dan dpart.bat ke Startup..."
cp -f /tmp/net.bat "$STARTUP_PATH/"
cp -f /tmp/dpart.bat "$STARTUP_PATH/"

# Copy WinRAR installer ke C:\installers
echo "Copy WinRAR installer ke C:\installers..."
cp -f /tmp/installers/winrar-installer.exe "$INSTALLERS_PATH/"

# Set permissions
chmod +x "$STARTUP_PATH/net.bat"
chmod +x "$STARTUP_PATH/dpart.bat"

# Verifikasi copy berhasil
echo "Verifikasi file di Startup Windows:"
ls -la "$STARTUP_PATH/" 2>/dev/null || echo "Tidak bisa akses Startup directory"

echo "Verifikasi file di C:\installers:"
ls -la "$INSTALLERS_PATH/" 2>/dev/null || echo "Tidak bisa akses installers directory"

# Sync dan unmount dengan benar
echo "Menyelesaikan proses dan unmount..."
sync
sleep 2

# Unmount partisi
if umount /mnt 2>/dev/null; then
    echo "Berhasil unmount /mnt"
else
    echo "Paksa unmount /mnt"
    umount -f /mnt 2>/dev/null || true
fi

rmdir /mnt 2>/dev/null || true

# HAPUS POWEROFF - BIARKAN WINDOWS BOOT SENDIRI
echo "========================================"
echo "INSTALASI SELESAI!"
echo "Windows akan boot otomatis dan menjalankan script instalasi WinRAR"
echo "Setelah WinRAR terinstall, sistem akan restart otomatis"
echo "========================================"
echo "Tunggu hingga proses selesai..."

# JANGAN poweroff - biarkan Windows boot
# Script batch akan dijalankan saat Windows startup

exit 0
