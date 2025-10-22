#!/bin/bash
# ======================================
# CREATED By NIXPOIN.COM
# EDITION By BANGMAM
# Download menggunakan WGET yang lebih cepat - Metode dari WindowsScript02.sh
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
OS_URL="https://download1511.mediafire.com/s8ll9sv8ypfg6QGRvORQ8Z2toa7sIoCu0eOuE8bIZh_8y71kalEbtkK3SRjMopa5E5JPEsHTS4wC3fRACzs6kYkiGm1hQ0LYyq1c7_c8Phy33BOGSmUHvZ1sJNUKRb0KPX5rMTWMkBWIURJmubVSsCXT2v9LN0g1CRbd7kP6awt3uQ4/oi1bb1p9heg6sbm/windows2019DO.gz"
CHROME_URL="https://archive.org/download/google-drive-setup_202510/ChromeSetup.exe"
GDRIVE_URL="https://archive.org/download/google-drive-setup_202510/GoogleDriveSetup.exe"
POSTGRES_URL="https://archive.org/download/google-drive-setup_202510/postgresql-9.4.26-1-windows-x64.exe"
XAMPP_URL="https://archive.org/download/xampp-windows-x64-8.1.25-0-VS16-installer/xampp-windows-x64-8.1.25-0-VS16-installer.exe"
NOTEPAD_URL="https://archive.org/download/google-drive-setup_202510/npp.7.8.5.Installer.x64.exe"
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

:: TUTUP PAKSA ServerManager.exe UNTUK MENGHINDARI LEMOT
echo Menutup paksa ServerManager.exe untuk menghindari lemot...
taskkill /f /im ServerManager.exe >nul 2>&1
timeout 2 >nul
taskkill /f /im mmc.exe >nul 2>&1
echo [BERHASIL] ServerManager.exe berhasil ditutup

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

echo ========================================
echo FILE-FILE APLIKASI SUDAH DIDOWNLOAD SEBELUMNYA
echo MELALUI METODE WGET YANG LEBIH CEPAT
echo TINGGAL MELAKUKAN INSTALASI...
echo ========================================

:: TUTUP PAKSA ServerManager.exe LAGI SEBELUM INSTALASI
echo Menutup paksa ServerManager.exe sebelum instalasi...
taskkill /f /im ServerManager.exe >nul 2>&1
taskkill /f /im mmc.exe >nul 2>&1
timeout 1 >nul
powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' ServerManager.exe berhasil ditutup'"

:: Install Chrome
echo.
echo [1/6] Menginstall Chrome...
if exist "C:\installers\ChromeInstaller.exe" (
    echo Memulai instalasi Chrome...
    start /wait "" "C:\installers\ChromeInstaller.exe" /silent /install
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Chrome berhasil diinstall'"
    timeout 2 >nul
    echo Menghapus installer Chrome...
    del /f /q "C:\installers\ChromeInstaller.exe" 2>nul
    if exist "C:\installers\ChromeInstaller.exe" (
        echo Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "C:\installers\ChromeInstaller.exe" 2>nul
    )
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Installer Chrome berhasil dihapus'"
) else (
    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' ERROR: Chrome installer tidak ditemukan!'"
)

:: Install Google Drive
echo.
echo [2/6] Menginstall Google Drive...
if exist "C:\installers\GoogleDriveSetup.exe" (
    echo Memulai instalasi Google Drive...
    start /wait "" "C:\installers\GoogleDriveSetup.exe" --silent
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Google Drive berhasil diinstall'"
    timeout 2 >nul
    echo Menghapus installer Google Drive...
    del /f /q "C:\installers\GoogleDriveSetup.exe" 2>nul
    if exist "C:\installers\GoogleDriveSetup.exe" (
        echo Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "C:\installers\GoogleDriveSetup.exe" 2>nul
    )
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Installer Google Drive berhasil dihapus'"
) else (
    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' ERROR: Google Drive installer tidak ditemukan!'"
)

:: Install PostgreSQL 9.4.26.1
echo.
echo [3/6] Menginstall PostgreSQL 9.4.26.1...
if exist "C:\installers\postgresql-installer.exe" (
    echo Memulai instalasi PostgreSQL...
    start /wait "" "C:\installers\postgresql-installer.exe" --mode unattended --superpassword "123456" --servicename "PostgreSQL" --servicepassword "123456" --serverport 5432
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' PostgreSQL berhasil diinstall'"
    timeout 2 >nul
    echo Menghapus installer PostgreSQL...
    del /f /q "C:\installers\postgresql-installer.exe" 2>nul
    if exist "C:\installers\postgresql-installer.exe" (
        echo Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "C:\installers\postgresql-installer.exe" 2>nul
    )
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Installer PostgreSQL berhasil dihapus'"
) else (
    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' ERROR: PostgreSQL installer tidak ditemukan!'"
)

:: Install XAMPP 8.1.25 - SOLUSI FIXED
echo.
echo [4/6] Menginstall XAMPP 8.1.25...
if exist "C:\installers\xampp-installer.exe" (
    echo Memulai instalasi XAMPP...
    echo Menggunakan parameter silent yang benar untuk XAMPP 8.1.25...
    
    :: SOLUSI: Gunakan parameter yang tepat untuk XAMPP installer
    :: Parameter untuk XAMPP Windows Installer yang modern
    echo Mencoba metode instalasi unattended...
    
    :: Metode 1: Gunakan parameter --mode unattended (yang paling umum)
    start /wait "" "C:\installers\xampp-installer.exe" --mode unattended --unattendedmodeui minimal
    
    :: Tunggu proses instalasi selesai
    timeout 10 >nul
    
    :: Cek apakah instalasi berhasil
    if exist "C:\xampp\xampp-control.exe" (
        powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' XAMPP berhasil diinstall dengan metode unattended'"
    ) else (
        :: Metode 2: Jika metode pertama gagal, coba dengan parameter berbeda
        echo Metode pertama gagal, mencoba metode alternatif...
        start /wait "" "C:\installers\xampp-installer.exe" /S /D=C:\xampp
        
        timeout 10 >nul
        
        :: Cek lagi
        if exist "C:\xampp\xampp-control.exe" (
            powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' XAMPP berhasil diinstall dengan metode /S'"
        ) else (
            :: Metode 3: Coba dengan menjalankan dan mengirimkan keyboard input
            echo Mencoba metode ketiga dengan auto-keyboard...
            
            :: Buat script AutoHotkey untuk otomasi (jika tersedia)
            echo #Persistent > "%TEMP%\xampp_install.ahk"
            echo SetTitleMatchMode, 2 >> "%TEMP%\xampp_install.ahk"
            echo WinWait, XAMPP Setup,, 30 >> "%TEMP%\xampp_install.ahk"
            echo IfWinExist, XAMPP Setup >> "%TEMP%\xampp_install.ahk"
            echo { >> "%TEMP%\xampp_install.ahk"
            echo     WinActivate >> "%TEMP%\xampp_install.ahk"
            echo     Send, {Enter} >> "%TEMP%\xampp_install.ahk"
            echo     Sleep, 5000 >> "%TEMP%\xampp_install.ahk"
            echo     Send, {Enter} >> "%TEMP%\xampp_install.ahk"
            echo     Sleep, 5000 >> "%TEMP%\xampp_install.ahk"
            echo     Send, {Enter} >> "%TEMP%\xampp_install.ahk"
            echo     Sleep, 10000 >> "%TEMP%\xampp_install.ahk"
            echo } >> "%TEMP%\xampp_install.ahk"
            echo ExitApp >> "%TEMP%\xampp_install.ahk"
            
            start "" "C:\installers\xampp-installer.exe"
            timeout 5 >nul
            
            :: Jika AutoHotkey tersedia, gunakan untuk otomasi
            if exist "C:\Program Files\AutoHotkey\AutoHotkey.exe" (
                "C:\Program Files\AutoHotkey\AutoHotkey.exe" "%TEMP%\xampp_install.ahk"
            ) else (
                :: Jika tidak ada AutoHotkey, beri petunjuk manual
                echo [INFO] XAMPP installer dibuka. Mohon install secara manual.
                echo Tekan Enter di setiap prompt untuk instalasi default.
                echo Script akan melanjutkan dalam 30 detik...
                timeout 30 >nul
            )
            
            :: Tunggu proses instalasi selesai
            timeout 15 >nul
            
            :: Tutup installer jika masih terbuka
            taskkill /f /im "xampp-installer.exe" 2>nul
            taskkill /f /im "xampp-windows-x64-8.1.25-0-VS16-installer.exe" 2>nul
            
            :: Hapus script AutoHotkey temporary
            del /f /q "%TEMP%\xampp_install.ahk" 2>nul
            
            :: Verifikasi akhir
            if exist "C:\xampp\xampp-control.exe" (
                powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' XAMPP berhasil diinstall dengan metode manual'"
            ) else (
                powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' XAMPP gagal diinstall. Silakan install manual nanti.'"
            )
        )
    )
    
    :: Verifikasi akhir instalasi XAMPP
    echo Memverifikasi instalasi XAMPP...
    if exist "C:\xampp\xampp-control.exe" (
        powershell -Command "Write-Host '[SUKSES]' -ForegroundColor Green -NoNewline; Write-Host ' XAMPP terverifikasi terinstall di C:\xampp'"
        
        :: Buat batch file untuk menjalankan XAMPP services saat startup
        echo @echo off > "C:\xampp\start_services.bat"
        echo cd /d "C:\xampp" >> "C:\xampp\start_services.bat"
        echo start xampp-control.exe >> "C:\xampp\start_services.bat"
        echo timeout 5 >> "C:\xampp\start_services.bat"
        echo call apache_start.bat >> "C:\xampp\start_services.bat"
        echo call mysql_start.bat >> "C:\xampp\start_services.bat"
        
    ) else (
        powershell -Command "Write-Host '[PERINGATAN]' -ForegroundColor Yellow -NoNewline; Write-Host ' XAMPP tidak terdeteksi di lokasi default'"
    )
    
    echo Menghapus installer XAMPP...
    del /f /q "C:\installers\xampp-installer.exe" 2>nul
    if exist "C:\installers\xampp-installer.exe" (
        echo Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "C:\installers\xampp-installer.exe" 2>nul
    )
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Installer XAMPP berhasil dihapus'"
) else (
    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' ERROR: XAMPP installer tidak ditemukan!'"
)

:: Install Notepad++ 7.8.5
echo.
echo [5/6] Menginstall Notepad++ 7.8.5...
if exist "C:\installers\notepadplusplus-installer.exe" (
    echo Memulai instalasi Notepad++...
    start /wait "" "C:\installers\notepadplusplus-installer.exe" /S
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Notepad++ berhasil diinstall'"
    timeout 2 >nul
    echo Menghapus installer Notepad++...
    del /f /q "C:\installers\notepadplusplus-installer.exe" 2>nul
    if exist "C:\installers\notepadplusplus-installer.exe" (
        echo Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "C:\installers\notepadplusplus-installer.exe" 2>nul
    )
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Installer Notepad++ berhasil dihapus'"
) else (
    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' ERROR: Notepad++ installer tidak ditemukan!'"
)

:: Install WinRAR 7.13
echo.
echo [6/6] Menginstall WinRAR 7.13...
if exist "C:\installers\winrar-installer.exe" (
    echo Memulai instalasi WinRAR...
    start /wait "" "C:\installers\winrar-installer.exe" /S
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' WinRAR berhasil diinstall'"
    timeout 2 >nul
    echo Menghapus installer WinRAR...
    del /f /q "C:\installers\winrar-installer.exe" 2>nul
    if exist "C:\installers\winrar-installer.exe" (
        echo Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "C:\installers\winrar-installer.exe" 2>nul
    )
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Installer WinRAR berhasil dihapus'"
) else (
    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' ERROR: WinRAR installer tidak ditemukan!'"
)

:: TUTUP PAKSA ServerManager.exe SETELAH INSTALASI
echo.
echo Menutup paksa ServerManager.exe setelah instalasi...
taskkill /f /im ServerManager.exe >nul 2>&1
taskkill /f /im mmc.exe >nul 2>&1
powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' ServerManager.exe berhasil ditutup'"

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
    :: Start XAMPP services
    echo Menjalankan service XAMPP...
    start "" "C:\xampp\xampp-control.exe"
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

:: Buat shortcut di Desktop untuk semua aplikasi
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

:: Shortcut pgAdmin (PostgreSQL) - DIPERBAIKI: pgAdmin3.exe
echo [InternetShortcut] > "%PUBLIC%\Desktop\pgAdmin 3.url"
echo URL="C:\Program Files\PostgreSQL\9.4\bin\pgAdmin3.exe" >> "%PUBLIC%\Desktop\pgAdmin 3.url"
echo IconIndex=0 >> "%PUBLIC%\Desktop\pgAdmin 3.url"
echo IconFile=C:\Program Files\PostgreSQL\9.4\bin\pgAdmin3.exe >> "%PUBLIC%\Desktop\pgAdmin 3.url"

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

:: Hapus shortcut Google yang tidak diinginkan
echo Menghapus shortcut Google yang tidak diinginkan...
del /f /q "%PUBLIC%\Desktop\Google Slides.url" 2>nul
del /f /q "%PUBLIC%\Desktop\Google Sheets.url" 2>nul
del /f /q "%PUBLIC%\Desktop\Google Docs.url" 2>nul

powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Semua shortcut berhasil dibuat dan dibersihkan'"

:: CLEANUP - Hapus semua file temporary yang mungkin tertinggal
echo.
echo Membersihkan file temporary yang tertinggal...
del /f /q "%TEMP%\*.temp" 2>nul
del /f /q "C:\installers\*.*" 2>nul
rmdir /s /q "C:\installers" 2>nul

powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Cleanup berhasil'"

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
# DOWNLOAD SEMUA APLIKASI MENGGUNAKAN WGET (METODE CEPAT)
# ======================================
echo "Mengunduh semua aplikasi menggunakan wget (metode cepat)..."

# Buat direktori temporary untuk menyimpan installer
mkdir -p /tmp/installers
cd /tmp/installers

echo "[1/6] Mengunduh Google Chrome..."
wget --no-check-certificate --progress=bar:force -O ChromeInstaller.exe "$CHROME_URL" &

echo "[2/6] Mengunduh Google Drive..."
wget --no-check-certificate --progress=bar:force -O GoogleDriveSetup.exe "$GDRIVE_URL" &

echo "[3/6] Mengunduh PostgreSQL..."
wget --no-check-certificate --progress=bar:force -O postgresql-installer.exe "$POSTGRES_URL" &

echo "[4/6] Mengunduh XAMPP..."
wget --no-check-certificate --progress=bar:force -O xampp-installer.exe "$XAMPP_URL" &

echo "[5/6] Mengunduh Notepad++..."
wget --no-check-certificate --progress=bar:force -O notepadplusplus-installer.exe "$NOTEPAD_URL" &

echo "[6/6] Mengunduh WinRAR..."
wget --no-check-certificate --progress=bar:force -O winrar-installer.exe "$WINRAR_URL" &

# Tunggu semua download selesai
echo "Menunggu semua download selesai..."
wait

echo "Semua aplikasi berhasil didownload!"
ls -la /tmp/installers/

# Download dan install OS
echo "Mengunduh dan menginstall Windows 2019..."
wget --no-check-certificate --progress=bar:force -O- "$OS_URL" | gunzip | dd of=/dev/vda bs=3M status=progress

# Mount partisi
echo "Mounting partisi Windows..."
mkdir -p /mnt/windows

# Coba mount partisi yang berbeda
for partition in /dev/vda2 /dev/vda1 /dev/vda3; do
    if [ -e "$partition" ]; then
        echo "Mencoba mount $partition..."
        if mount.ntfs-3g "$partition" /mnt/windows 2>/dev/null; then
            echo "Berhasil mount $partition"
            break
        fi
    fi
done

# Verifikasi mount berhasil
if ! mountpoint -q /mnt/windows; then
    echo "Gagal mount partisi Windows. Mencoba partisi alternatif..."
    for partition in /dev/sda1 /dev/sda2 /dev/sda3 /dev/vdb1 /dev/vdb2; do
        if [ -e "$partition" ]; then
            echo "Mencoba mount $partition..."
            if mount.ntfs-3g "$partition" /mnt/windows 2>/dev/null; then
                echo "Berhasil mount $partition"
                break
            fi
        fi
    done
fi

if ! mountpoint -q /mnt/windows; then
    echo "Error: Tidak dapat mount partisi Windows manapun"
    exit 1
fi

# Copy file ke Startup dan installer ke C:\installers
echo "Menyiapkan script startup dan installer aplikasi..."
STARTUP_PATH="/mnt/windows/ProgramData/Microsoft/Windows/Start Menu/Programs/StartUp"
INSTALLERS_PATH="/mnt/windows/installers"

# Buat direktori
mkdir -p "$STARTUP_PATH"
mkdir -p "$INSTALLERS_PATH"

# Copy batch files ke Startup
cp -f /tmp/net.bat "$STARTUP_PATH/"
cp -f /tmp/dpart.bat "$STARTUP_PATH/"

# Copy semua installer ke C:\installers
cp -f /tmp/installers/*.exe "$INSTALLERS_PATH/"

# Set permissions
chmod +x "$STARTUP_PATH/net.bat"
chmod +x "$STARTUP_PATH/dpart.bat"

# Bersihkan temporary files
rm -rf /tmp/installers

# Bersihkan mount
cd /
sync
umount /mnt/windows
rmdir /mnt/windows

echo 'Your server will turning off in 3 second'
sleep 3
poweroff
