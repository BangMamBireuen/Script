#!/bin/bash
# ======================================
# CREATED By NIXPOIN.COM
# EDITION By BANGMAM
# Download Chrome langsung di batch file - Lebih reliable
# Hapus installer Chrome setelah install - Otomatis bersih
# Multiple cleanup paths - Pastikan ChromeSetup.exe dihapus dari semua lokasi
# Better mount handling - Coba multiple partisi
# Fixed Startup path - Gunakan path yang konsisten
# PARALLEL DOWNLOAD - Download semua file secara bersamaan
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

:: Download semua file secara paralel
echo MENDOWNLOAD SEMUA APLIKASI SECARA PARALEL...
echo JENDELA INI JANGAN DITUTUP SAMPAI SEMUA DOWNLOAD SELESAI!

:: Buat script PowerShell untuk download paralel
echo Mempersiapkan download paralel...
powershell -Command "
\$jobs = @()

:: Chrome
\$jobs += Start-Job -ScriptBlock {
    Write-Host 'Mengunduh Chrome...'
    Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile \"\$env:TEMP\ChromeInstaller.exe\"
    if (Test-Path \"\$env:TEMP\ChromeInstaller.exe\") {
        Write-Host 'Chrome download selesai!' -ForegroundColor Green
        return \$true
    } else {
        Write-Host 'Chrome download gagal!' -ForegroundColor Red
        return \$false
    }
}

:: Google Drive
\$jobs += Start-Job -ScriptBlock {
    Write-Host 'Mengunduh Google Drive...'
    Invoke-WebRequest -Uri 'https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe' -OutFile \"\$env:TEMP\GoogleDriveSetup.exe\"
    if (Test-Path \"\$env:TEMP\GoogleDriveSetup.exe\") {
        Write-Host 'Google Drive download selesai!' -ForegroundColor Green
        return \$true
    } else {
        Write-Host 'Google Drive download gagal!' -ForegroundColor Red
        return \$false
    }
}

:: PostgreSQL
\$jobs += Start-Job -ScriptBlock {
    Write-Host 'Mengunduh PostgreSQL 9.4.26.1...'
    Invoke-WebRequest -Uri 'https://get.enterprisedb.com/postgresql/postgresql-9.4.26-1-windows-x64.exe' -OutFile \"\$env:TEMP\postgresql-9.4.26.1.exe\"
    if (Test-Path \"\$env:TEMP\postgresql-9.4.26.1.exe\") {
        Write-Host 'PostgreSQL download selesai!' -ForegroundColor Green
        return \$true
    } else {
        Write-Host 'PostgreSQL download gagal!' -ForegroundColor Red
        return \$false
    }
}

:: XAMPP
\$jobs += Start-Job -ScriptBlock {
    Write-Host 'Mengunduh XAMPP 7.4.30...'
    try {
        Invoke-WebRequest -Uri 'https://dl.filehorse.com/win/developer-tools/xampp/xampp-windows-x64-7.4.30-1-VC15-installer.exe?st=WBOMtVRWjwOyX74fXQincQ&e=1760599819&fn=xampp-windows-x64-7.4.30-1-VC15-installer.exe' -OutFile \"\$env:TEMP\xampp-installer.exe\"
        if (Test-Path \"\$env:TEMP\xampp-installer.exe\") {
            Write-Host 'XAMPP download selesai!' -ForegroundColor Green
            return \$true
        }
    } catch {
        Write-Host 'Mencoba direct download XAMPP...'
        try {
            Invoke-WebRequest -Uri 'https://dl.filehorse.com/win/developer-tools/xampp/xampp-windows-x64-7.4.30-1-VC15-installer.exe' -OutFile \"\$env:TEMP\xampp-installer.exe\"
            if (Test-Path \"\$env:TEMP\xampp-installer.exe\") {
                Write-Host 'XAMPP download selesai!' -ForegroundColor Green
                return \$true
            }
        } catch {
            Write-Host 'XAMPP download gagal!' -ForegroundColor Red
            return \$false
        }
    }
    return \$false
}

:: Notepad++
\$jobs += Start-Job -ScriptBlock {
    Write-Host 'Mengunduh Notepad++ 7.8.5...'
    Invoke-WebRequest -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.8.5/npp.7.8.5.Installer.x64.exe' -OutFile \"\$env:TEMP\notepadplusplus-installer.exe\"
    if (Test-Path \"\$env:TEMP\notepadplusplus-installer.exe\") {
        Write-Host 'Notepad++ download selesai!' -ForegroundColor Green
        return \$true
    } else {
        Write-Host 'Notepad++ download gagal!' -ForegroundColor Red
        return \$false
    }
}

:: WinRAR
\$jobs += Start-Job -ScriptBlock {
    Write-Host 'Mengunduh WinRAR 7.13...'
    Invoke-WebRequest -Uri 'https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-713.exe' -OutFile \"\$env:TEMP\winrar-installer.exe\"
    if (Test-Path \"\$env:TEMP\winrar-installer.exe\") {
        Write-Host 'WinRAR download selesai!' -ForegroundColor Green
        return \$true
    } else {
        Write-Host 'WinRAR download gagal!' -ForegroundColor Red
        return \$false
    }
}

Write-Host 'MENUNGGU SEMUA DOWNLOAD SELESAI...' -ForegroundColor Yellow

\$allCompleted = \$false
while (-not \$allCompleted) {
    \$allCompleted = \$true
    foreach (\$job in \$jobs) {
        if (\$job.State -eq 'Running') {
            \$allCompleted = \$false
            break
        }
    }
    if (-not \$allCompleted) {
        Start-Sleep -Seconds 5
        Write-Host 'Masih menunggu download selesai...' -ForegroundColor Cyan
    }
}

Write-Host 'SEMUA DOWNLOAD TELAH SELESAI!' -ForegroundColor Green
Write-Host 'Memulai proses instalasi...' -ForegroundColor Yellow

:: Koleksi hasil download
\$results = \$jobs | Receive-Job
\$jobs | Remove-Job

return \$true
"

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
