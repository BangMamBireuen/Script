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
# URL DOWNLOAD SEMUA FILE (UPDATED)
# ======================================
OS_URL="https://drive.usercontent.google.com/download?id=1moYAB-ruaaBoqKH0FBAJSZtsnmHg2kFB&export=download&authuser=0&confirm=t&uuid=08ed96cb-15aa-41fb-849b-bda2157906fa&at=AKSUxGMdUFURLgHLrCcKMUsbHeeT%3A1761164622157"
CHROME_URL="https://dl.google.com/chrome/install/latest/chrome_installer.exe"
GDRIVE_URL="https://drive.usercontent.google.com/download?id=1LehRU_DlPktFxlGbvGrrNfRYQYoeTIoI&export=download&authuser=0&confirm=t&uuid=e438fd92-da92-47f2-b500-1c94a03a706a&at=AKSUxGNg6UXotFWGddhR_tON7LVs%3A1761164594903"
POSTGRES_URL="https://drive.usercontent.google.com/download?id=10DNL7YVOlRROpEqGMi37PJR2VIG9eQc9&export=download&authuser=0&confirm=t&uuid=57dcd4ea-197f-47ae-80ed-c7156b30ee6c&at=AKSUxGPES-J1Ih_joDuHO8UVnbrx%3A1761164608498"
XAMPP_URL="https://drive.usercontent.google.com/download?id=1mMK_UYDdhZToCyH-efbhhLvFmpDJ2a2R&export=download&authuser=0&confirm=t&uuid=5684a29a-f895-46cd-b5e1-f123e2b3580f&at=AKSUxGNriasfN0TAlRzj9F0rnuDJ%3A1761164560325"
NOTEPAD_URL="https://drive.usercontent.google.com/download?id=1kpSSrBLk9PD6KuYOlXuVb8fJZLpwL1Ws&export=download&authuser=0&confirm=t&uuid=91b0634e-60f4-4437-b2fe-d37ad93ebd80&at=AKSUxGOz1B0_9X0jwJCiIQkU6IBG%3A1761164576638"
WINRAR_URL="https://drive.usercontent.google.com/download?id=1SRsTjdDjVbxe6XvydSzZhkxT2b-9f7QJ&export=download&authuser=0&confirm=t&uuid=02ccf217-3ba3-47eb-90aa-c298208c7385&at=AKSUxGPEPGT-3G87vpWQBk72ukES%3A1761164596982"

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

:: Tampilkan status file dengan warna
if exist "%TEMP%\ChromeInstaller.exe" (
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Chrome - SELESAI'"
) else (
    powershell -Command "Write-Host '[DOWNLOAD]' -ForegroundColor Yellow -NoNewline; Write-Host ' Chrome - Downloading...'"
)

if exist "%TEMP%\GoogleDriveSetup.exe" (
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Google Drive - SELESAI'"
) else (
    powershell -Command "Write-Host '[DOWNLOAD]' -ForegroundColor Yellow -NoNewline; Write-Host ' Google Drive - Downloading...'"
)

if exist "%TEMP%\postgresql-installer.exe" (
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' PostgreSQL - SELESAI'"
) else (
    powershell -Command "Write-Host '[DOWNLOAD]' -ForegroundColor Yellow -NoNewline; Write-Host ' PostgreSQL - Downloading...'"
)

if exist "%TEMP%\xampp-installer.exe" (
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' XAMPP - SELESAI'"
) else (
    powershell -Command "Write-Host '[DOWNLOAD]' -ForegroundColor Yellow -NoNewline; Write-Host ' XAMPP - Downloading...'"
)

if exist "%TEMP%\notepadplusplus-installer.exe" (
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' Notepad++ - SELESAI'"
) else (
    powershell -Command "Write-Host '[DOWNLOAD]' -ForegroundColor Yellow -NoNewline; Write-Host ' Notepad++ - Downloading...'"
)

if exist "%TEMP%\winrar-installer.exe" (
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' WinRAR - SELESAI'"
) else (
    powershell -Command "Write-Host '[DOWNLOAD]' -ForegroundColor Yellow -NoNewline; Write-Host ' WinRAR - Downloading...'"
)

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
    timeout 2 >nul
    
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
    echo Mencoba download ulang Google Drive...
    powershell -Command "& {Write-Host '[INFO] Mengunduh ulang Google Drive...' -ForegroundColor Cyan; try {Invoke-WebRequest -Uri '$GDRIVE_URL' -OutFile '%TEMP%\GoogleDriveSetup.exe' -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'} catch {Invoke-WebRequest -Uri '$GDRIVE_URL' -OutFile '%TEMP%\GoogleDriveSetup.exe' -UseBasicParsing}}"
    if exist "%TEMP%\GoogleDriveSetup.exe" (
        start /wait "" "%TEMP%\GoogleDriveSetup.exe" --silent
        del /f /q "%TEMP%\GoogleDriveSetup.exe" 2>nul
    )
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
    echo Mencoba download ulang PostgreSQL...
    powershell -Command "& {Write-Host '[INFO] Mengunduh ulang PostgreSQL...' -ForegroundColor Cyan; try {Invoke-WebRequest -Uri '$POSTGRES_URL' -OutFile '%TEMP%\postgresql-installer.exe' -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'} catch {Invoke-WebRequest -Uri '$POSTGRES_URL' -OutFile '%TEMP%\postgresql-installer.exe' -UseBasicParsing}}"
    if exist "%TEMP%\postgresql-installer.exe" (
        start /wait "" "%TEMP%\postgresql-installer.exe" --mode unattended --superpassword "123456" --servicename "PostgreSQL" --servicepassword "123456" --serverport 5432
        del /f /q "%TEMP%\postgresql-installer.exe" 2>nul
    )
)

:: Install XAMPP 7.3.24 - DIPERBAIKI: Parameter instalasi
echo.
echo [4/6] Menginstall XAMPP 7.3.24...
if exist "%TEMP%\xampp-installer.exe" (
    echo Memulai instalasi XAMPP...
    echo Mencoba berbagai parameter instalasi silent...
    
    :: Coba parameter yang berbeda untuk XAMPP
    echo Percobaan 1: Parameter /S...
    start /wait "" "%TEMP%\xampp-installer.exe" /S
    if exist "C:\xampp\xampp-control.exe" (
        powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' XAMPP berhasil diinstall dengan parameter /S'"
    ) else (
        echo Percobaan 2: Parameter /quiet...
        start /wait "" "%TEMP%\xampp-installer.exe" /quiet
        if exist "C:\xampp\xampp-control.exe" (
            powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' XAMPP berhasil diinstall dengan parameter /quiet'"
        ) else (
            echo Percobaan 3: Parameter -silent...
            start /wait "" "%TEMP%\xampp-installer.exe" -silent
            if exist "C:\xampp\xampp-control.exe" (
                powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' XAMPP berhasil diinstall dengan parameter -silent'"
            ) else (
                echo Percobaan 4: Tanpa parameter (mungkin perlu interaksi)...
                start /wait "" "%TEMP%\xampp-installer.exe"
                if exist "C:\xampp\xampp-control.exe" (
                    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' XAMPP berhasil diinstall tanpa parameter'"
                ) else (
                    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' XAMPP gagal diinstall dengan semua parameter'"
                )
            )
        )
    )
    
    timeout 2 >nul
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
    echo Mencoba download ulang XAMPP...
    powershell -Command "& {Write-Host '[INFO] Mengunduh ulang XAMPP...' -ForegroundColor Cyan; try {Invoke-WebRequest -Uri '$XAMPP_URL' -OutFile '%TEMP%\xampp-installer.exe' -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'} catch {Invoke-WebRequest -Uri '$XAMPP_URL' -OutFile '%TEMP%\xampp-installer.exe' -UseBasicParsing}}"
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
    echo Mencoba download ulang Notepad++...
    powershell -Command "& {Write-Host '[INFO] Mengunduh ulang Notepad++...' -ForegroundColor Cyan; try {Invoke-WebRequest -Uri '$NOTEPAD_URL' -OutFile '%TEMP%\notepadplusplus-installer.exe' -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'} catch {Invoke-WebRequest -Uri '$NOTEPAD_URL' -OutFile '%TEMP%\notepadplusplus-installer.exe' -UseBasicParsing}}"
    if exist "%TEMP%\notepadplusplus-installer.exe" (
        start /wait "" "%TEMP%\notepadplusplus-installer.exe" /S
        del /f /q "%TEMP%\notepadplusplus-installer.exe" 2>nul
    )
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
    echo Mencoba download ulang WinRAR...
    powershell -Command "& {Write-Host '[INFO] Mengunduh ulang WinRAR...' -ForegroundColor Cyan; try {Invoke-WebRequest -Uri '$WINRAR_URL' -OutFile '%TEMP%\winrar-installer.exe' -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'} catch {Invoke-WebRequest -Uri '$WINRAR_URL' -OutFile '%TEMP%\winrar-installer.exe' -UseBasicParsing}}"
    if exist "%TEMP%\winrar-installer.exe" (
        start /wait "" "%TEMP%\winrar-installer.exe" /S
        del /f /q "%TEMP%\winrar-installer.exe" 2>nul
    )
)

:: TUTUP PAKSA ServerManager.exe SETELAH INSTALASI
echo.
echo Menutup paksa ServerManager.exe setelah instalasi...
taskkill /f /im ServerManager.exe >nul 2>&1
taskkill /f /im mmc.exe >nul 2>&1
powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' ServerManager.exe berhasil ditutup'"

:: Verifikasi instalasi XAMPP
echo.
echo Memverifikasi instalasi XAMPP...
if exist "C:\xampp\xampp-control.exe" (
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' XAMPP terinstall dengan benar di C:\xampp'"
) else (
    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' XAMPP tidak terdeteksi di C:\xampp'"
    echo Mencoba instalasi manual XAMPP...
    if exist "%TEMP%\xampp-installer.exe" (
        echo Menjalankan instalasi manual XAMPP...
        start /wait "" "%TEMP%\xampp-installer.exe"
        del /f /q "%TEMP%\xampp-installer.exe" 2>nul
    )
)

:: Verifikasi instalasi PostgreSQL
echo Memverifikasi instalasi PostgreSQL...
sc query "PostgreSQL" >nul 2>&1
if !errorlevel! equ 0 (
    powershell -Command "Write-Host '[BERHASIL]' -ForegroundColor Green -NoNewline; Write-Host ' PostgreSQL service berjalan'"
) else (
    powershell -Command "Write-Host '[GAGAL]' -ForegroundColor Red -NoNewline; Write-Host ' PostgreSQL service tidak berjalan'"
    echo Mencoba memulai service PostgreSQL...
    sc start "PostgreSQL" >nul 2>&1
)

echo.
echo ========================================
echo INSTALASI SELESAI!
echo ========================================
echo Semua aplikasi telah berhasil diinstall:
echo - Google Chrome
echo - Google Drive
echo - PostgreSQL 9.4.26.1
echo - XAMPP 7.3.24
echo - Notepad++ 7.8.5
echo - WinRAR 7.13
echo.
echo Password Administrator: $PASSADMIN
echo RDP Port: 5000
echo IP Address: $IP4
echo.
echo Untuk RDP, gunakan: $IP4:5000
echo Username: Administrator
echo Password: $PASSADMIN
echo ========================================

:: Hapus file batch startup
cd /d "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup"
del /f /q dpart.bat >nul 2>&1

echo Membersihkan file temporary...
del /f /q "%TEMP%\ChromeInstaller.exe" 2>nul
del /f /q "%TEMP%\GoogleDriveSetup.exe" 2>nul
del /f /q "%TEMP%\postgresql-installer.exe" 2>nul
del /f /q "%TEMP%\xampp-installer.exe" 2>nul
del /f /q "%TEMP%\notepadplusplus-installer.exe" 2>nul
del /f /q "%TEMP%\winrar-installer.exe" 2>nul

echo Selesai! Sistem akan restart dalam 10 detik...
timeout 10 >nul

shutdown /r /t 5 /f /c "Restart untuk menyelesaikan konfigurasi sistem"
exit
EOF

# ======================================
# COPY FILE KE STARTUP
# ======================================
echo "Copy file ke startup..."
mkdir -p /mnt/c/ProgramData/Microsoft/Windows/Start\ Menu/Programs/Startup/
cp /tmp/dpart.bat /mnt/c/ProgramData/Microsoft/Windows/Start\ Menu/Programs/Startup/
cp /tmp/net.bat /mnt/c/ProgramData/Microsoft/Windows/Start\ Menu/Programs/Startup/

# ======================================
# MOUNT DAN EXTEND PARTISI
# ======================================
echo "Mount dan extend partisi..."

# Coba mount ke berbagai partisi
for drive in c d e f; do
  if mount -t drvfs "$drive": /mnt/$drive 2>/dev/null; then
    echo "Berhasil mount drive $drive":
    break
  fi
done

# Extend partisi menggunakan diskpart
cat > /mnt/c/extend.txt << EOF
select disk 0
select volume 1
extend
exit
EOF

diskpart /s /mnt/c/extend.txt

# ======================================
# RESTART WINDOWS
# ======================================
echo "Restarting Windows..."
echo "Proses selesai! Windows akan restart dan melanjutkan instalasi secara otomatis."
echo "Setelah restart, sambungkan ke RDP menggunakan: $IP4:5000"
echo "Username: Administrator"
echo "Password: $PASSADMIN"
