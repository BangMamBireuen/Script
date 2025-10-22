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
# TUTUP PAKSA ServerManager.exe - Hindari lemot
# Script BangMam News
# ======================================

echo "Windows 2019 akan diinstall"

# ======================================
# URL DOWNLOAD SEMUA FILE
# ======================================
OS_URL="https://download1511.mediafire.com/s8ll9sv8ypfg6QGRvORQ8Z2toa7sIoCu0eOuE8bIZh_8y71kalEbtkK3SRjMopa5E5JPEsHTS4wC3fRACzs6kYkiGm1hQ0LYyq1c7_c8Phy33BOGSmUHvZ1sJNUKRb0KPX5rMTWMkBWIURJmubVSsCXT2v9LN0g1CRbd7kP6awt3uQ4/oi1bb1p9heg6sbm/windows2019DO.gz"
CHROME_URL="https://pixeldrain.com/api/file/WWBRfUrS?download"
GDRIVE_URL="https://pixeldrain.com/api/file/aHy7jwDT?download"
POSTGRES_URL="https://pixeldrain.com/api/file/QiCFzv6G?download"
XAMPP_URL="https://pixeldrain.com/api/file/fWRDnzk4?download"
NOTEPAD_URL="https://pixeldrain.com/api/file/t3eJwkp4?download"
WINRAR_URL="https://pixeldrain.com/api/file/xAFnDqXJ?download"

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

:: Download semua file secara paralel dengan ekstensi .temp
echo ========================================
echo MENGUNDUH SEMUA FILE SECARA PARALEL...
echo FILE AKAN DISIMPAN SEBAGAI .temp SELAMA DOWNLOAD
echo ========================================

echo [1/6] Memulai download Chrome...
start "Download Chrome" /MIN powershell -Command "& {Write-Host '[INFO] Mengunduh Google Chrome...' -ForegroundColor Cyan; try {Invoke-WebRequest -Uri '$CHROME_URL' -OutFile '%TEMP%\ChromeInstaller.temp' -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'} catch {Write-Host '[ERROR] Gagal download Chrome, mencoba metode alternatif...' -ForegroundColor Red; Invoke-WebRequest -Uri '$CHROME_URL' -OutFile '%TEMP%\ChromeInstaller.temp' -UseBasicParsing}; if (Test-Path '%TEMP%\ChromeInstaller.temp') {Rename-Item '%TEMP%\ChromeInstaller.temp' 'ChromeInstaller.exe'; Write-Host '[SUKSES] Download Chrome selesai!' -ForegroundColor Green}}"
set CHROME_PID=!errorlevel!

echo [2/6] Memulai download Google Drive...
start "Download Google Drive" /MIN powershell -Command "& {Write-Host '[INFO] Mengunduh Google Drive...' -ForegroundColor Cyan; try {Invoke-WebRequest -Uri '$GDRIVE_URL' -OutFile '%TEMP%\GoogleDriveSetup.temp' -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'} catch {Write-Host '[ERROR] Gagal download Google Drive, mencoba metode alternatif...' -ForegroundColor Red; Invoke-WebRequest -Uri '$GDRIVE_URL' -OutFile '%TEMP%\GoogleDriveSetup.temp' -UseBasicParsing}; if (Test-Path '%TEMP%\GoogleDriveSetup.temp') {Rename-Item '%TEMP%\GoogleDriveSetup.temp' 'GoogleDriveSetup.exe'; Write-Host '[SUKSES] Download Google Drive selesai!' -ForegroundColor Green}}"
set GDRIVE_PID=!errorlevel!

echo [3/6] Memulai download PostgreSQL...
start "Download PostgreSQL" /MIN powershell -Command "& {Write-Host '[INFO] Mengunduh PostgreSQL 9.4.26...' -ForegroundColor Cyan; try {Invoke-WebRequest -Uri '$POSTGRES_URL' -OutFile '%TEMP%\postgresql-installer.temp' -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'} catch {Write-Host '[ERROR] Gagal download PostgreSQL, mencoba metode alternatif...' -ForegroundColor Red; Invoke-WebRequest -Uri '$POSTGRES_URL' -OutFile '%TEMP%\postgresql-installer.temp' -UseBasicParsing}; if (Test-Path '%TEMP%\postgresql-installer.temp') {Rename-Item '%TEMP%\postgresql-installer.temp' 'postgresql-installer.exe'; Write-Host '[SUKSES] Download PostgreSQL selesai!' -ForegroundColor Green}}"
set POSTGRES_PID=!errorlevel!

echo [4/6] Memulai download XAMPP 7.3.24...
start "Download XAMPP" /MIN powershell -Command "& {Write-Host '[INFO] Mengunduh XAMPP 7.3.24...' -ForegroundColor Cyan; try {Invoke-WebRequest -Uri '$XAMPP_URL' -OutFile '%TEMP%\xampp-installer.temp' -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'} catch {Write-Host '[ERROR] Gagal download XAMPP, mencoba metode alternatif...' -ForegroundColor Red; Invoke-WebRequest -Uri '$XAMPP_URL' -OutFile '%TEMP%\xampp-installer.temp' -UseBasicParsing}; if (Test-Path '%TEMP%\xampp-installer.temp') {Rename-Item '%TEMP%\xampp-installer.temp' 'xampp-installer.exe'; Write-Host '[SUKSES] Download XAMPP selesai!' -ForegroundColor Green}}"
set XAMPP_PID=!errorlevel!

echo [5/6] Memulai download Notepad++...
start "Download Notepad++" /MIN powershell -Command "& {Write-Host '[INFO] Mengunduh Notepad++...' -ForegroundColor Cyan; try {Invoke-WebRequest -Uri '$NOTEPAD_URL' -OutFile '%TEMP%\notepadplusplus-installer.temp' -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'} catch {Write-Host '[ERROR] Gagal download Notepad++, mencoba metode alternatif...' -ForegroundColor Red; Invoke-WebRequest -Uri '$NOTEPAD_URL' -OutFile '%TEMP%\notepadplusplus-installer.temp' -UseBasicParsing}; if (Test-Path '%TEMP%\notepadplusplus-installer.temp') {Rename-Item '%TEMP%\notepadplusplus-installer.temp' 'notepadplusplus-installer.exe'; Write-Host '[SUKSES] Download Notepad++ selesai!' -ForegroundColor Green}}"
set NOTEPAD_PID=!errorlevel!

echo [6/6] Memulai download WinRAR...
start "Download WinRAR" /MIN powershell -Command "& {Write-Host '[INFO] Mengunduh WinRAR...' -ForegroundColor Cyan; try {Invoke-WebRequest -Uri '$WINRAR_URL' -OutFile '%TEMP%\winrar-installer.temp' -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'} catch {Write-Host '[ERROR] Gagal download WinRAR, mencoba metode alternatif...' -ForegroundColor Red; Invoke-WebRequest -Uri '$WINRAR_URL' -OutFile '%TEMP%\winrar-installer.temp' -UseBasicParsing}; if (Test-Path '%TEMP%\winrar-installer.temp') {Rename-Item '%TEMP%\winrar-installer.temp' 'winrar-installer.exe'; Write-Host '[SUKSES] Download WinRAR selesai!' -ForegroundColor Green}}"
set WINRAR_PID=!errorlevel!

:: Tunggu sampai semua file .exe tersedia (semua download selesai)
echo.
echo MENUNGGU SEMUA DOWNLOAD SELESAI...
echo File akan berubah dari .temp ke .exe ketika download selesai...
echo.

:CHECK_DOWNLOADS

:: Cek apakah semua file .exe sudah ada
set /a completed=0
set /a total=6

if exist "%TEMP%\ChromeInstaller.exe" set /a completed+=1
if exist "%TEMP%\GoogleDriveSetup.exe" set /a completed+=1
if exist "%TEMP%\postgresql-installer.exe" set /a completed+=1
if exist "%TEMP%\xampp-installer.exe" set /a completed+=1
if exist "%TEMP%\notepadplusplus-installer.exe" set /a completed+=1
if exist "%TEMP%\winrar-installer.exe" set /a completed+=1

:: Tampilkan status
cls
echo ========================================
echo PROGRESS DOWNLOAD: !completed!/6 FILES
echo ========================================

:: Tampilkan status file
if exist "%TEMP%\ChromeInstaller.exe" (echo [BERHASIL] Chrome - SELESAI) else (echo [DOWNLOAD] Chrome - Downloading...)
if exist "%TEMP%\GoogleDriveSetup.exe" (echo [BERHASIL] Google Drive - SELESAI) else (echo [DOWNLOAD] Google Drive - Downloading...)
if exist "%TEMP%\postgresql-installer.exe" (echo [BERHASIL] PostgreSQL - SELESAI) else (echo [DOWNLOAD] PostgreSQL - Downloading...)
if exist "%TEMP%\xampp-installer.exe" (echo [BERHASIL] XAMPP - SELESAI) else (echo [DOWNLOAD] XAMPP - Downloading...)
if exist "%TEMP%\notepadplusplus-installer.exe" (echo [BERHASIL] Notepad++ - SELESAI) else (echo [DOWNLOAD] Notepad++ - Downloading...)
if exist "%TEMP%\winrar-installer.exe" (echo [BERHASIL] WinRAR - SELESAI) else (echo [DOWNLOAD] WinRAR - Downloading...)

echo ========================================
echo Menunggu download selesai... (!completed!/6)
echo Progress akan diupdate seketika ketika file siap...

if !completed! equ !total! (
    echo.
    echo ========================================
    echo SEMUA DOWNLOAD TELAH SELESAI!
    echo FILE SUDAH SIAP UNTUK DIINSTALL...
    echo ========================================
    timeout 3 >nul
    goto INSTALL_APPS
) else (
    :: REAL-TIME MONITORING - PURE BATCH
    setlocal enabledelayedexpansion
    set /a old_count=!completed!
    
    :MONITOR_LOOP
    ping -n 2 127.0.0.1 >nul
    
    :: Cek file ulang
    set /a new_count=0
    if exist "%TEMP%\ChromeInstaller.exe" set /a new_count+=1
    if exist "%TEMP%\GoogleDriveSetup.exe" set /a new_count+=1
    if exist "%TEMP%\postgresql-installer.exe" set /a new_count+=1
    if exist "%TEMP%\xampp-installer.exe" set /a new_count+=1
    if exist "%TEMP%\notepadplusplus-installer.exe" set /a new_count+=1
    if exist "%TEMP%\winrar-installer.exe" set /a new_count+=1
    
    if !new_count! gtr !old_count! (
        endlocal
        goto CHECK_DOWNLOADS
    ) else (
        goto MONITOR_LOOP
    )
)

:INSTALL_APPS
echo ========================================
echo MEMULAI INSTALASI SEMUA APLIKASI...
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
if exist "%TEMP%\ChromeInstaller.exe" (
    echo Memulai instalasi Chrome...
    start /wait "" "%TEMP%\ChromeInstaller.exe" /silent /install
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Chrome berhasil diinstall'"
    timeout 2 >nul
    echo Menghapus installer Chrome...
    del /f /q "%TEMP%\ChromeInstaller.exe" 2>nul
    if exist "%TEMP%\ChromeInstaller.exe" (
        echo Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "%TEMP%\ChromeInstaller.exe" 2>nul
    )
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Installer Chrome berhasil dihapus'"
) else (
    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' ERROR: Chrome installer tidak ditemukan!'"
)

:: Install Google Drive
echo.
echo [2/6] Menginstall Google Drive...
if exist "%TEMP%\GoogleDriveSetup.exe" (
    echo Memulai instalasi Google Drive...
    start /wait "" "%TEMP%\GoogleDriveSetup.exe" --silent
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Google Drive berhasil diinstall'"
    timeout 2 >nul
    echo Menghapus installer Google Drive...
    del /f /q "%TEMP%\GoogleDriveSetup.exe" 2>nul
    if exist "%TEMP%\GoogleDriveSetup.exe" (
        echo Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "%TEMP%\GoogleDriveSetup.exe" 2>nul
    )
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Installer Google Drive berhasil dihapus'"
) else (
    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' ERROR: Google Drive installer tidak ditemukan!'"
)

:: Install PostgreSQL 9.4.26.1
echo.
echo [3/6] Menginstall PostgreSQL 9.4.26.1...
if exist "%TEMP%\postgresql-installer.exe" (
    echo Memulai instalasi PostgreSQL...
    start /wait "" "%TEMP%\postgresql-installer.exe" --mode unattended --superpassword "123456" --servicename "PostgreSQL" --servicepassword "123456" --serverport 5432
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' PostgreSQL berhasil diinstall'"
    timeout 2 >nul
    echo Menghapus installer PostgreSQL...
    del /f /q "%TEMP%\postgresql-installer.exe" 2>nul
    if exist "%TEMP%\postgresql-installer.exe" (
        echo Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "%TEMP%\postgresql-installer.exe" 2>nul
    )
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Installer PostgreSQL berhasil dihapus'"
) else (
    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' ERROR: PostgreSQL installer tidak ditemukan!'"
)

:: Install XAMPP 7.3.24 - SOLUSI FIXED
echo.
echo [4/6] Menginstall XAMPP 7.3.24...
if exist "%TEMP%\xampp-installer.exe" (
    echo Memulai instalasi XAMPP...
    echo Menggunakan parameter silent yang benar untuk XAMPP...
    
    :: SOLUSI: Gunakan PowerShell untuk instalasi XAMPP yang lebih reliable
    powershell -Command "& {
        Write-Host '[INFO] Memulai instalasi XAMPP dengan PowerShell...' -ForegroundColor Cyan
        \$process = Start-Process -FilePath '%TEMP%\xampp-installer.exe' -ArgumentList '--mode unattended', '--launchapps 0', '--enable-components servicedesigner' -Wait -PassThru
        if (\$process.ExitCode -eq 0) {
            Write-Host '[SUKSES] XAMPP berhasil diinstall!' -ForegroundColor Green
        } else {
            Write-Host '[WARNING] XAMPP mungkin memerlukan interaksi manual' -ForegroundColor Yellow
            Write-Host '[INFO] Mencoba metode alternatif...' -ForegroundColor Cyan
            # Coba metode kedua dengan timeout
            \$process2 = Start-Process -FilePath '%TEMP%\xampp-installer.exe' -ArgumentList '/S' -Wait -PassThru
        }
    }"
    
    :: Verifikasi instalasi XAMPP
    timeout 5 >nul
    if exist "C:\xampp\xampp-control.exe" (
        powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' XAMPP terverifikasi terinstall di C:\xampp'"
    ) else (
        :: Jika gagal, coba jalankan tanpa parameter
        powershell -Command "Write-Host '[INFO] Mencoba instalasi XAMPP tanpa parameter...' -ForegroundColor Yellow"
        start /wait "" "%TEMP%\xampp-installer.exe"
        timeout 10 >nul
        
        :: Verifikasi lagi
        if exist "C:\xampp\xampp-control.exe" (
            powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' XAMPP berhasil diinstall setelah mencoba tanpa parameter'"
        ) else (
            powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' XAMPP masih gagal terinstall'"
        )
    )
    
    echo Menghapus installer XAMPP...
    del /f /q "%TEMP%\xampp-installer.exe" 2>nul
    if exist "%TEMP%\xampp-installer.exe" (
        echo Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "%TEMP%\xampp-installer.exe" 2>nul
    )
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Installer XAMPP berhasil dihapus'"
) else (
    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' ERROR: XAMPP installer tidak ditemukan!'"
)

:: Install Notepad++ 7.8.5
echo.
echo [5/6] Menginstall Notepad++ 7.8.5...
if exist "%TEMP%\notepadplusplus-installer.exe" (
    echo Memulai instalasi Notepad++...
    start /wait "" "%TEMP%\notepadplusplus-installer.exe" /S
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Notepad++ berhasil diinstall'"
    timeout 2 >nul
    echo Menghapus installer Notepad++...
    del /f /q "%TEMP%\notepadplusplus-installer.exe" 2>nul
    if exist "%TEMP%\notepadplusplus-installer.exe" (
        echo Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "%TEMP%\notepadplusplus-installer.exe" 2>nul
    )
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Installer Notepad++ berhasil dihapus'"
) else (
    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' ERROR: Notepad++ installer tidak ditemukan!'"
)

:: Install WinRAR 7.13
echo.
echo [6/6] Menginstall WinRAR 7.13...
if exist "%TEMP%\winrar-installer.exe" (
    echo Memulai instalasi WinRAR...
    start /wait "" "%TEMP%\winrar-installer.exe" /S
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' WinRAR berhasil diinstall'"
    timeout 2 >nul
    echo Menghapus installer WinRAR...
    del /f /q "%TEMP%\winrar-installer.exe" 2>nul
    if exist "%TEMP%\winrar-installer.exe" (
        echo Menunggu file dilepaskan...
        timeout 3 >nul
        del /f /q "%TEMP%\winrar-installer.exe" 2>nul
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

:: Shortcut XAMPP Control Panel (prioritas)
if exist "C:\xampp\xampp-control.exe" (
    echo [InternetShortcut] > "%PUBLIC%\Desktop\XAMPP Control Panel.url"
    echo URL="C:\xampp\xampp-control.exe" >> "%PUBLIC%\Desktop\XAMPP Control Panel.url"
    echo IconIndex=0 >> "%PUBLIC%\Desktop\XAMPP Control Panel.url"
    echo IconFile=C:\xampp\xampp-control.exe >> "%PUBLIC%\Desktop\XAMPP Control Panel.url"
    echo [BERHASIL] Shortcut XAMPP dibuat
)

:: Shortcut lainnya...
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    echo [InternetShortcut] > "%PUBLIC%\Desktop\Google Chrome.url"
    echo URL="C:\Program Files\Google\Chrome\Application\chrome.exe" >> "%PUBLIC%\Desktop\Google Chrome.url"
    echo IconIndex=0 >> "%PUBLIC%\Desktop\Google Chrome.url"
    echo IconFile=C:\Program Files\Google\Chrome\Application\chrome.exe >> "%PUBLIC%\Desktop\Google Chrome.url"
)

:: CLEANUP - Hapus semua file temporary yang mungkin tertinggal
echo.
echo Membersihkan file temporary yang tertinggal...
del /f /q "%TEMP%\*.temp" 2>nul
del /f /q "%TEMP%\ChromeSetup.exe" 2>nul
del /f /q "%TEMP%\GoogleDriveSetup.exe" 2>nul
del /f /q "%TEMP%\postgresql-installer.exe" 2>nul
del /f /q "%TEMP%\xampp-installer.exe" 2>nul
del /f /q "%TEMP%\notepadplusplus-installer.exe" 2>nul
del /f /q "%TEMP%\winrar-installer.exe" 2>nul

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

# Download dan install OS
echo "Mengunduh dan menginstall Windows 2019 dari Google Drive..."
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

# Bersihkan
cd /
sync
umount /mnt/windows
rmdir /mnt/windows

echo 'Your server will turning off in 3 second'
sleep 3
poweroff
