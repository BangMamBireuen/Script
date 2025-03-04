#!/bin/bash
#
# MODIFIKASI By BangMam
#
echo "Pilih OS yang ingin anda install"
echo "\t1) Windows 2019 Password : Botol123456789!"
echo "\t2) Windows 2016 Password : Nixpoin.com123!"
echo "\t3) Windows 2012 Password : Nixpoin.com123!"
echo "\t4) Windows 10"
echo "\t5) Windows 2022"
echo "\t6) Windows 2019 Password : P@ssword64"
echo "\t7) Pakai link gz mu sendiri"

read -p "Pilih [1]: " PILIHOS

case "$PILIHOS" in
    1|"") PILIHOS="https://download1511.mediafire.com/w3qxhvst0hag/windows2019DO.gz"; PASSADMIN="Botol123456789!"; IFACE="Ethernet Instance 0";;
    2) PILIHOS="https://download1503.mediafire.com/ws8tzbmwy8qgIxIvsunGF5q-Sx5_vS8lRz6WndJ0DWJZnvbqDg3wyoceaWuaqG8fLYCSCaQZ39-dVR2uqipXx2JwCrSriYrOPWH6BfO2n9J-UYQt-JFUImLl3yyU8v4gH6enj4HTOEcbgPkq5j6tZu15yZIPhVssfCoANiQrqRXePA/s8zxdghgha8m2wj/windows2016.gz"; PASSADMIN="Nixpoin.com123!"; IFACE="Ethernet Instance 0";;
    3) PILIHOS="https://download1349.mediafire.com/7e0d40pg/windows2012v2.gz"; PASSADMIN="Nixpoin.com123!"; IFACE="Ethernet Instance 0";;
    4) PILIHOS="https://files.sowan.my.id/windows10.gz"; read -p "Masukkan password untuk akun Administrator: " PASSADMIN; IFACE="Ethernet Instance 0 2";;
    5) PILIHOS="https://files.sowan.my.id/windows2022.gz"; read -p "Masukkan password untuk akun Administrator: " PASSADMIN; IFACE="Ethernet Instance 0 2";;
    6) PILIHOS="https://download1349.mediafire.com/vi33u31/windows19.gz"; PASSADMIN="P@ssword64"; IFACE="Ethernet Instance 0 2";;
    7) read -p "Masukkan Link GZ mu : " PILIHOS; read -p "Masukkan password untuk akun Administrator: " PASSADMIN;;
    *) echo "Pilihan salah"; exit;;
esac

echo "Gunakan script ini dengan bijak, jika ada masalah silahkan hubungi WA Admin 083117542926"

IP4=$(curl -4 -s icanhazip.com)
GW=$(ip route | awk '/default/ { print $3 }')

cat >/tmp/net.bat<<EOF
@ECHO OFF
net user Administrator $PASSADMIN
netsh -c interface ip set address name="$IFACE" source=static address=$IP4 mask=255.255.240.0 gateway=$GW
netsh -c interface ip add dnsservers name="$IFACE" address=1.1.1.1 index=1 validate=no
netsh -c interface ip add dnsservers name="$IFACE" address=8.8.4.4 index=2 validate=no
cd /d "%Public%/Desktop"
del /f /q net.bat
exit
EOF

cat >/tmp/dpart.bat<<EOF
@ECHO OFF
echo JENDELA INI JANGAN DITUTUP
echo SCRIPT INI AKAN MERUBAH PORT RDP MENJADI 5000
echo KETIK YES LALU ENTER!

set PORT=5000
set RULE_NAME="Open Port %PORT%"
netsh advfirewall firewall add rule name=%RULE_NAME% dir=in action=allow protocol=TCP localport=%PORT%
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 5000

ECHO SELECT VOLUME=%%SystemDrive%% > "%SystemDrive%\diskpart.extend"
ECHO EXTEND >> "%SystemDrive%\diskpart.extend"
START /WAIT DISKPART /S "%SystemDrive%\diskpart.extend"
del /f /q "%SystemDrive%\diskpart.extend"
cd /d "%Public%/Desktop"
del /f /q dpart.bat
timeout 50 >nul
del /f /q ChromeSetup.exe
echo JENDELA INI JANGAN DITUTUP
exit
EOF

wget --no-check-certificate -O- $PILIHOS | gunzip | dd of=/dev/vda bs=3M status=progress

mount.ntfs-3g /dev/vda2 /mnt
cd "/mnt/Users/Public/Desktop"
wget https://raw.githubusercontent.com/BangMamBireuen/Project1/main/ChromeSetup.exe
cp -f /tmp/net.bat net.bat
cp -f /tmp/dpart.bat dpart.bat

echo 'Your server will turning off in 3 seconds'
sleep 3
poweroff
