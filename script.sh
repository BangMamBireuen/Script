#!/bin/bash
#
# CREATED By NIXPOIN.COM
#
echo "Pilih OS yang ingin anda install"
echo "    1) Windows 2019(Default)"
echo "    2) Windows 2016"
echo "    3) Windows 2012"
echo "    4) Windows 10"
echo "    5) Windows 2022"
echo "    6) Pakai link gz mu sendiri"

read -p "Pilih [1]: " PILIHOS

case "$PILIHOS" in
    1|"") PILIHOS="https://files.sowan.my.id/windows2019.gz"  IFACE="Ethernet Instance 0 2";;
    2) PILIHOS="https://download1503.mediafire.com/sg1dzn7yyiagwQSWD97oAve0wSjPI-5Jpb-BF1LIUOf-Vgd_IHmUj7IB-dmQZeNhUETanxl7duVcmfkI2GnkyLa1UKW4ziDxTplDztRx1Zd0wlu4-SslfULf8NRxeD3L46Z8wloskorwsfFtAxmWNPRG7DoEcKlRMwydpZGIEEmX/s8zxdghgha8m2wj/windows2016.gz"  IFACE="Ethernet Instance 0 2";;
    3) PILIHOS="https://files.sowan.my.id/windows2012.gz"  IFACE="Ethernet";;
    4) PILIHOS="https://files.sowan.my.id/windows10.gz"  IFACE="Ethernet Instance 0 2";;
    5) PILIHOS="https://files.sowan.my.id/windows2022.gz"  IFACE="Ethernet Instance 0 2";;
    6) read -p "Masukkan Link GZ mu : " PILIHOS;;
    *) echo "pilihan salah"; exit;;
esac

echo "Gunakan script ini dengan bijak, jika script ini mengalami masalah silahkan hubungi WA Admin 083117542926"

read -p "Masukkan password untuk akun Administrator: " PASSADMIN

IP4=$(curl -4 -s icanhazip.com)
GW=$(ip route | awk '/default/ { print $3 }')

# Membuat script net.bat yang lebih robust dengan penambahan delay dan retry
cat >/tmp/net.bat<<EOF
@ECHO OFF
cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)

:CHANGE_PASSWORD
net user Administrator $PASSADMIN
if %errorlevel% neq 0 (
    timeout /t 10 /nobreak >nul
    goto CHANGE_PASSWORD
)

:CONFIGURE_NETWORK
echo Mencoba mengkonfigurasi jaringan...
netsh -c interface ip set address name="$IFACE" source=static address=$IP4 mask=255.255.240.0 gateway=$GW
if %errorlevel% neq 0 (
    echo Gagal mengatur IP, mencoba lagi dalam 10 detik...
    timeout /t 10 /nobreak >nul
    goto CONFIGURE_NETWORK
)

:SET_DNS1
netsh -c interface ip add dnsservers name="$IFACE" address=1.1.1.1 index=1 validate=no
if %errorlevel% neq 0 (
    timeout /t 5 /nobreak >nul
    goto SET_DNS1
)

:SET_DNS2
netsh -c interface ip add dnsservers name="$IFACE" address=8.8.4.4 index=2 validate=no
if %errorlevel% neq 0 (
    timeout /t 5 /nobreak >nul
    goto SET_DNS2
)

echo Jaringan berhasil dikonfigurasi!
cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q net.bat
exit
EOF


cat >/tmp/dpart.bat<<EOF
@ECHO OFF
echo JENDELA INI JANGAN DITUTUP
echo SCRIPT INI AKAN MERUBAH PORT RDP MENJADI 5000, SETELAH RESTART UNTUK MENYAMBUNG KE RDP GUNAKAN ALAMAT $IP4:5000
echo KETIK YES LALU ENTER!

cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)

set PORT=5000
set RULE_NAME="Open Port %PORT%"

:CHECK_FIREWALL
netsh advfirewall firewall show rule name=%RULE_NAME% >nul
if not ERRORLEVEL 1 (
    echo Rule %RULE_NAME% sudah ada.
) else (
    echo Membuat rule firewall...
    netsh advfirewall firewall add rule name=%RULE_NAME% dir=in action=allow protocol=TCP localport=%PORT%
    if %errorlevel% neq 0 (
        timeout /t 5 /nobreak >nul
        goto CHECK_FIREWALL
    )
)

:SET_RDP_PORT
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 5000
if %errorlevel% neq 0 (
    timeout /t 5 /nobreak >nul
    goto SET_RDP_PORT
)

:EXTEND_PARTITION
ECHO SELECT VOLUME=%%SystemDrive%% > "%SystemDrive%\diskpart.extend"
ECHO EXTEND >> "%SystemDrive%\diskpart.extend"
START /WAIT DISKPART /S "%SystemDrive%\diskpart.extend"

del /f /q "%SystemDrive%\diskpart.extend"
cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q dpart.bat
timeout 50 >nul
del /f /q ChromeSetup.exe
echo JENDELA INI JANGAN DITUTUP
exit
EOF

wget --no-check-certificate -O- $PILIHOS | gunzip | dd of=/dev/vda bs=3M status=progress

# Tunggu sebentar untuk memastikan device siap
sleep 5

# Mount partisi dengan opsi yang lebih robust
ntfs-3g -o force /dev/vda2 /mnt || {
    echo "Gagal mount /dev/vda2, mencoba lagi..."
    sleep 5
    ntfs-3g -o force /dev/vda2 /mnt || {
        echo "Gagal mount partisi, silakan cek manual"
        exit 1
    }
}

cd "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/"
cd Start* || cd start*; \
wget -q --no-check-certificate https://nixpoin.com/ChromeSetup.exe || {
    echo "Gagal mendownload ChromeSetup.exe, melanjutkan tanpa Chrome..."
}

cp -f /tmp/net.bat net.bat
cp -f /tmp/dpart.bat dpart.bat

# Unmount dengan sync untuk memastikan semua data tertulis
sync
umount /mnt

echo 'Server akan dimatikan dalam 5 detik'
sleep 5
poweroff
