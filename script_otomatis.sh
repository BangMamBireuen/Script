#!/bin/bash
#
# CREATED By NIXPOIN.COM
# EDITION By BANGMAM & aurielly
# Ubuntu 22.04 (LTS) x64
#
echo "Pilih OS yang ingin anda install"
echo "1) Windows 2019 (Default)"
echo "2) Windows 2019 (MediaFire)"
echo "3) Windows 10 Super Lite SF"
echo "4) Windows 10 Super Lite MF"
echo "5) Windows 10 Super Lite CF"
echo "6) Pakai link gz mu sendiri"

read -p "Pilih [1]: " PILIHOS

case "$PILIHOS" in
	1|"") PILIHOS="https://pub-96a3141a1f5b4b3ca15bbd7b03ad1f25.r2.dev/windows2019.gz";;
	2) PILIHOS="https://download1638.mediafire.com/a0mif0wkgssg7-SZEZ7lGaNAQwtFXPDxy32dwK6ndowTze56RQT_8qARmByv3NdoFDABl5Qj_2JkDrjcHAJtIKCqFvnMImeHH3qby7pxM4stVqwOwLdzf2USCJSxQxG200b7CJ48ItqDdQzEaPkMVRTJk7NMzCP7iUzWee9UTpI0/rc16x2q38v9exy2/windows2019.gz";;
	3) PILIHOS="https://master.dl.sourceforge.net/project/manyod/wedus10lite.gz?viasf=1";;
	4) PILIHOS="https://download1582.mediafire.com/lemxvneeredgyBT5P6YtAU5Dq-mikaH29djd8VnlyMcV1iM_vHJzYCiTc8V3PQkUslqgQSG0ftRJ0X2w3t1D7T4a-616-phGqQ2xKCn8894r0fdV9jKMhVYKH8N1dXMvtsZdK6e4t9F4Hg66wCzpXvuD_jcRu9_-i65_Kbr-HeW8Bw/gcxlheshfpbyigg/wedus10lite.gz";;
	5) PILIHOS="https://umbel.my.id/wedus10lite.gz";;
	6) read -p "Masukkan Link GZ mu : " PILIHOS;;
	*) echo "pilihan salah"; exit;;
esac

echo "Password yang saya buat sudah masuk wordlist bruteforce, silahkan masukkan password yang lebih aman!"
read -p "Masukkan password untuk akun Administrator (minimal 12 karakter): " PASSADMIN

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


for /f "tokens=3*" %%i in ('netsh interface show interface ^|findstr /I /R "Local.* Ethernet Ins*"') do (set InterfaceName=%%j)
netsh -c interface ip set address name="Ethernet Instance 0 2" source=static address=$IP4 mask=255.255.240.0 gateway=$GW
netsh -c interface ip add dnsservers name="Ethernet Instance 0 2" address=8.8.8.8 index=1 validate=no
netsh -c interface ip add dnsservers name="Ethernet Instance 0 2" address=8.8.4.4 index=2 validate=no

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
