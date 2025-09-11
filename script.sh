#!/bin/bash
# ======================================
# CREATED By NIXPOIN.COM
# EDITION By BANGMAM
# Ubuntu 24.04 (LTS) x64 atau Ke Atas
# Rekomendasi: Ubuntu 24.10 x64
# ======================================
#
echo "Windows 2019 akan diinstall"

PILIHOS="https://download1511.mediafire.com/cajs7b97ecfgYcAqsjNi_eXwKSPR3njsAgnoY61sEPf1foR_94ROiz7GjAKi4qwTuuREK01uPBO63H8lDzB23edvmpjApWJVYmufzzuv3chbEw6wkvJ56BsukY4IqZvpaFcwWLOvy90kSb6csLtqv3_r5i7ATQEQtaFwZmz6tg/oi1bb1p9heg6sbm/windows2019DO.gz"
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
echo KETIK YES LALU ENTER!

cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)

set PORT=5000
set RULE_NAME="Open Port %PORT%"

netsh advfirewall firewall show rule name=%RULE_NAME% >nul
if not ERRORLEVEL 1 (
    rem Rule %RULE_NAME% already exists.
    echo Hey, you already got a out rule by that name, you cannot put another one in!
) else (
    echo Rule %RULE_NAME% does not exist. Creating...
    netsh advfirewall firewall add rule name=%RULE_NAME% dir=in action=allow protocol=TCP localport=%PORT%
)

reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 5000

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

mount.ntfs-3g /dev/vda2 /mnt
cd "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/"
cd Start* || cd start*; \
wget https://raw.githubusercontent.com/BangMamBireuen/Project1/refs/heads/main/ChromeSetup.exe
cp -f /tmp/net.bat net.bat
cp -f /tmp/dpart.bat dpart.bat

echo 'Your server will turning off in 3 second'
sleep 3
poweroff
