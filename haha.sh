#!/bin/bash
# ======================================
# CREATED By NIXPOIN.COM
# EDITION By BANGMAM
# Download Chrome langsung di batch file - Lebih reliable
# Hapus installer Chrome setelah install - Otomatis bersih
# Multiple cleanup paths - Pastikan ChromeSetup.exe dihapus dari semua lokasi
# Better mount handling - Coba multiple partisi
# Fixed Startup path - Gunakan path yang konsisten
# PARALLEL DOWNLOAD - Download dengan file temporary selama proses
# GOOGLE DRIVE SUPPORT - Support download dari Google Drive
# ======================================

echo "Windows 2019 akan diinstall"

# Google Drive Link untuk Windows 2019
DRIVE_ID="10U2HSTOVQUY-DxIvnl2SLAXCHaIknJyW"
PILIHOS="https://drive.usercontent.google.com/download?id=${DRIVE_ID}&export=download&authuser=0&confirm=t"

IFACE="Ethernet Instance 0"
PASSADMIN="Botol123456789!"

IP4=$(curl -4 -s icanhazip.com)
GW=$(ip route | awk '/default/ { print $3 }')

# Function untuk download dari Google Drive
download_from_gdrive() {
    local file_id="$1"
    local output_file="$2"
    
    echo "Mengunduh dari Google Drive ID: $file_id"
    
    # Method 1: Menggunakan wget dengan cookie confirmation
    echo "Method 1: Menggunakan wget dengan cookie..."
    if wget --no-check-certificate \
            --header="Cookie: download_warning_${file_id}=t" \
            -O "$output_file" \
            "https://drive.usercontent.google.com/download?id=${file_id}&export=download&authuser=0&confirm=t"; then
        # Cek jika file adalah HTML (berarti perlu confirmation)
        if file "$output_file" | grep -q "HTML"; then
            echo "Membutuhkan confirmation, mencoba method alternatif..."
            rm -f "$output_file"
        else
            echo "✓ Download berhasil dengan wget"
            return 0
        fi
    fi
    
    # Method 2: Menggunakan curl dengan cookie
    echo "Method 2: Menggunakan curl..."
    if curl -L -k \
         -c cookies.txt \
         "https://drive.usercontent.google.com/uc?id=${file_id}&export=download&confirm=t" \
         -o "$output_file"; then
        echo "✓ Download berhasil dengan curl"
        rm -f cookies.txt
        return 0
    fi
    rm -f cookies.txt
    
    # Method 3: Menggunakan gdown (Google Drive downloader)
    echo "Method 3: Mencoba menggunakan gdown..."
    if command -v gdown &> /dev/null; then
        if gdown --id "$file_id" -O "$output_file"; then
            echo "✓ Download berhasil dengan gdown"
            return 0
        fi
    else
        echo "Menginstall gdown..."
        if pip install gdown --quiet; then
            if gdown --id "$file_id" -O "$output_file"; then
                echo "✓ Download berhasil dengan gdown"
                return 0
            fi
        fi
    fi
    
    # Method 4: Menggunakan PHP script alternatif
    echo "Method 4: Menggunakan PHP Google Drive downloader..."
    cat > /tmp/gdrive_downloader.php << 'EOF'
<?php
$fileId = $_SERVER['argv'][1] ?? '';
$outputFile = $_SERVER['argv'][2] ?? 'download.gz';

if (empty($fileId)) {
    die("File ID required\n");
}

$url = "https://drive.google.com/uc?export=download&id=$fileId&confirm=t";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');
curl_setopt($ch, CURLOPT_HEADERFUNCTION, function($curl, $header) use (&$cookies) {
    if (preg_match('/^Set-Cookie:\s*([^;]+)/i', $header, $matches)) {
        parse_str($matches[1], $tmp);
        $cookies += $tmp;
    }
    return strlen($header);
});

$data = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpCode === 200 && !empty($data)) {
    file_put_contents($outputFile, $data);
    echo "SUCCESS";
    exit(0);
} else {
    echo "FAILED";
    exit(1);
}
?>
EOF

    if command -v php &> /dev/null; then
        if php /tmp/gdrive_downloader.php "$file_id" "$output_file" 2>/dev/null | grep -q "SUCCESS"; then
            echo "✓ Download berhasil dengan PHP"
            rm -f /tmp/gdrive_downloader.php
            return 0
        fi
        rm -f /tmp/gdrive_downloader.php
    fi
    
    # Method 5: Direct download dengan confirm parameter
    echo "Method 5: Direct download dengan confirm..."
    if wget --no-check-certificate \
            "https://drive.usercontent.google.com/uc?id=${file_id}&export=download&confirm=t&uuid=12345678-1234-1234-1234-123456789012" \
            -O "$output_file"; then
        echo "✓ Download berhasil dengan direct link"
        return 0
    fi
    
    echo "✗ Semua metode download Google Drive gagal"
    return 1
}

# Function untuk extract dan install OS
install_os() {
    local os_file="$1"
    echo "Mengekstrak dan menginstall OS..."
    
    # Cek apakah file exists dan tidak kosong
    if [[ ! -f "$os_file" || ! -s "$os_file" ]]; then
        echo "✗ File OS tidak ditemukan atau kosong"
        return 1
    fi
    
    # Cek tipe file
    file_type=$(file "$os_file")
    echo "File type: $file_type"
    
    # Gunakan gunzip dan dd untuk install
    if echo "$file_type" | grep -q "gzip"; then
        echo "File adalah gzip compressed, mengekstrak..."
        if gunzip -c "$os_file" | dd of=/dev/vda bs=3M status=progress; then
            echo "✓ OS berhasil diinstall"
            return 0
        fi
    else
        echo "File mungkin sudah uncompressed, menyalin langsung..."
        if dd if="$os_file" of=/dev/vda bs=3M status=progress; then
            echo "✓ OS berhasil diinstall"
            return 0
        fi
    fi
    
    echo "✗ Gagal menginstall OS"
    return 1
}

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
start "Download Chrome" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TEMP%\ChromeInstaller.temp'; if (\$?) { Rename-Item '%TEMP%\ChromeInstaller.temp' 'ChromeInstaller.exe'; Write-Host '=== Chrome download completed ===' }"
set CHROME_PID=!errorlevel!

echo [2/6] Memulai download Google Drive...
start "Download Google Drive" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe' -OutFile '%TEMP%\GoogleDriveSetup.temp'; if (\$?) { Rename-Item '%TEMP%\GoogleDriveSetup.temp' 'GoogleDriveSetup.exe'; Write-Host '=== Google Drive download completed ===' }"
set GDRIVE_PID=!errorlevel!

echo [3/6] Memulai download PostgreSQL...
start "Download PostgreSQL" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://pixeldrain.com/api/file/QiCFzv6G?download' -OutFile '%TEMP%\postgresql-9.4.26.1.temp'; if (\$?) { Rename-Item '%TEMP%\postgresql-9.4.26.1.temp' 'postgresql-9.4.26.1.exe'; Write-Host '=== PostgreSQL download completed ===' }"
set POSTGRES_PID=!errorlevel!

echo [4/6] Memulai download XAMPP...
start "Download XAMPP" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://pixeldrain.com/api/file/fWRDnzk4?download' -OutFile '%TEMP%\xampp-installer.temp'; if (\$?) { Rename-Item '%TEMP%\xampp-installer.temp' 'xampp-installer.exe'; Write-Host '=== XAMPP download completed ===' }"
set XAMPP_PID=!errorlevel!

echo [5/6] Memulai download Notepad++...
start "Download Notepad++" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.8.5/npp.7.8.5.Installer.x64.exe' -OutFile '%TEMP%\notepadplusplus-installer.temp'; if (\$?) { Rename-Item '%TEMP%\notepadplusplus-installer.temp' 'notepadplusplus-installer.exe'; Write-Host '=== Notepad++ download completed ===' }"
set NOTEPAD_PID=!errorlevel!

echo [6/6] Memulai download WinRAR...
start "Download WinRAR" /MIN powershell -Command "Invoke-WebRequest -Uri 'https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-713.exe' -OutFile '%TEMP%\winrar-installer.temp'; if (\$?) { Rename-Item '%TEMP%\winrar-installer.temp' 'winrar-installer.exe'; Write-Host '=== WinRAR download completed ===' }"
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

:: Install XAMPP 7.3.28
echo.
echo [4/6] Menginstall XAMPP 7.3.28...
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
    powershell -Command "Invoke-WebRequest -Uri 'https://pixeldrain.com/api/file/fWRDnzk4?download' -OutFile '%TEMP%\xampp-installer.temp'; if (\$?) { Rename-Item '%TEMP%\xampp-installer.temp' 'xampp-installer.exe' }"
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
echo ✓ XAMPP 7.3.28 - Web server stack
echo ✓ Notepad++ 7.8.5 - Text editor
echo ✓ WinRAR 7.13 - File archiver
echo ========================================
echo ✓ Shortcut sudah tersedia di Desktop!
echo ========================================
echo Jendela ini akan tertutup otomatis dalam 15 detik...
timeout 15 >nul
exit
EOF

# Download dan install OS dari Google Drive
echo "Mengunduh Windows 2019 dari Google Drive..."
OS_FILE="/tmp/windows2019.gz"

# Install dependencies untuk Google Drive download
echo "Mempersiapkan environment..."
if ! command -v python3 &> /dev/null; then
    echo "Menginstall Python3..."
    apt-get update > /dev/null 2>&1 && apt-get install -y python3 python3-pip > /dev/null 2>&1
fi

if ! command -v php &> /dev/null; then
    echo "Menginstall PHP..."
    apt-get update > /dev/null 2>&1 && apt-get install -y php > /dev/null 2>&1
fi

# Download OS dari Google Drive
if download_from_gdrive "$DRIVE_ID" "$OS_FILE"; then
    echo "✓ Download OS dari Google Drive berhasil"
    
    # Verifikasi file
    if [[ -f "$OS_FILE" && -s "$OS_FILE" ]]; then
        file_size=$(du -h "$OS_FILE" | cut -f1)
        echo "File size: $file_size"
        
        # Install OS
        if install_os "$OS_FILE"; then
            echo "✓ Install OS berhasil"
        else
            echo "✗ Install OS gagal"
            exit 1
        fi
    else
        echo "✗ File OS tidak valid"
        exit 1
    fi
else
    echo "✗ Download dari Google Drive gagal"
    echo "Mencoba metode fallback..."
    
    # Fallback method - direct streaming
    echo "Mencoba metode streaming langsung..."
    if wget --no-check-certificate -O- \
            "https://drive.usercontent.google.com/uc?id=${DRIVE_ID}&export=download&confirm=t" \
            | dd of=/dev/vda bs=3M status=progress; then
        echo "✓ Metode streaming berhasil"
    else
        echo "✗ Semua metode download gagal"
        echo "Silakan cek:"
        echo "1. Koneksi internet"
        echo "2. File ID Google Drive: $DRIVE_ID"
        echo "3. Permission file di Google Drive"
        exit 1
    fi
fi

# Mount partisi
echo "Mounting partisi Windows..."
mkdir -p /mnt/windows

# Tunggu sebentar untuk memastikan partisi ready
sleep 5

if mount.ntfs-3g /dev/vda2 /mnt/windows 2>/dev/null; then
    echo "Berhasil mount /dev/vda2"
elif mount.ntfs-3g /dev/vda1 /mnt/windows 2>/dev/null; then
    echo "Berhasil mount /dev/vda1"
else
    echo "Mencoba mount partisi dengan ntfsfix..."
    ntfsfix /dev/vda2 2>/dev/null || ntfsfix /dev/vda1 2>/dev/null
    sleep 3
    if mount.ntfs-3g /dev/vda2 /mnt/windows 2>/dev/null; then
        echo "Berhasil mount /dev/vda2 setelah fix"
    elif mount.ntfs-3g /dev/vda1 /mnt/windows 2>/dev/null; then
        echo "Berhasil mount /dev/vda1 setelah fix"
    else
        echo "Gagal mount partisi Windows"
        echo "Mencoba partisi lain..."
        for device in /dev/vda*; do
            echo "Mencoba mount $device"
            if mount.ntfs-3g "$device" /mnt/windows 2>/dev/null; then
                echo "Berhasil mount $device"
                break
            fi
        done
    fi
fi

# Copy file ke Startup
echo "Menyiapkan script startup..."
STARTUP_PATH="/mnt/windows/ProgramData/Microsoft/Windows/Start Menu/Programs/StartUp"
mkdir -p "$STARTUP_PATH"

# Copy batch files ke Startup
cp -f /tmp/net.bat "$STARTUP_PATH/"
cp -f /tmp/dpart.bat "$STARTUP_PATH/"

# Set permissions
chmod +x "$STARTUP_PATH/net.bat"
chmod +x "$STARTUP_PATH/dpart.bat"

echo "✓ Script startup berhasil disiapkan"

# Bersihkan
cd /
umount /mnt/windows 2>/dev/null
rmdir /mnt/windows 2>/dev/null
rm -f /tmp/windows2019.gz
rm -f /tmp/gdrive_downloader.php 2>/dev/null

echo "========================================"
echo "INSTALASI SELESAI!"
echo "========================================"
echo "Server akan restart dalam 5 detik..."
echo "Setelah restart, koneksi RDP menggunakan:"
echo "Alamat: $IP4:5000"
echo "Username: Administrator"
echo "Password: $PASSADMIN"
echo "========================================"

sleep 5
poweroff
