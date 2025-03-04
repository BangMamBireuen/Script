#!/bin/bash
#
# MODIFIKASI By BangMam
#

echo "Pilih OS yang ingin anda install"
echo "	1) Windows 2019 Password : Botol123456789!"
echo "	2) Windows 2016 Password : Nixpoin.com123!"
echo "	3) Windows 2012 Password : Nixpoin.com123!"
echo "	4) Windows 10"
echo "	5) Windows 2022"
echo "	6) Windows 2019 Password : P@ssword64"
echo "	7) Pakai link gz mu sendiri"

read -p "Pilih [1]: " PILIHOS

case "$PILIHOS" in
	1|"") 
		PILIHOS="https://download1511.mediafire.com/windows2019.gz"
		PASSADMIN="Botol123456789!"
		;;
	2) 
		PILIHOS="https://download1503.mediafire.com/ws8tzbmwy8qgIxIvsunGF5q-Sx5_vS8lRz6WndJ0DWJZnvbqDg3wyoceaWuaqG8fLYCSCaQZ39-dVR2uqipXx2JwCrSriYrOPWH6BfO2n9J-UYQt-JFUImLl3yyU8v4gH6enj4HTOEcbgPkq5j6tZu15yZIPhVssfCoANiQrqRXePA/s8zxdghgha8m2wj/windows2016.gz"
		PASSADMIN="Nixpoin.com123!"
		;;
	3) 
		PILIHOS="https://download1349.mediafire.com/windows2012v2.gz"
		PASSADMIN="Nixpoin.com123!"
		;;
	4) 
		PILIHOS="https://files.sowan.my.id/windows10.gz"
		PASSADMIN=""
		;;
	5) 
		PILIHOS="https://files.sowan.my.id/windows2022.gz"
		PASSADMIN=""
		;;
	6) 
		PILIHOS="https://download1349.mediafire.com/windows19.gz"
		PASSADMIN="P@ssword64"
		;;
	7) 
		read -p "Masukkan Link GZ mu : " PILIHOS
		;;
	*) 
		echo "Pilihan salah"
		exit
		;;
esac

echo "Gunakan script ini dengan bijak, jika script ini mengalami masalah silahkan hubungi WA Admin 083117542926"

IP4=$(curl -4 -s icanhazip.com)
GW=$(ip route | awk '/default/ { print $3 }')

# **Mendeteksi Interface yang Aktif**
IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E "eth|ens|eno" | head -n 1)

if [ -z "$IFACE" ]; then
    echo "Tidak ada interface jaringan yang aktif! Periksa konfigurasi jaringan."
    exit 1
fi

cat >/tmp/net.bat<<EOF
@ECHO OFF
net user Administrator $PASSADMIN

echo Mencari interface jaringan...
SET INTERFACES="Ethernet" "Ethernet Instance 0" "Ethernet Instance 0 2" "Local Area Connection"
FOR %%I IN (%INTERFACES%) DO (
    netsh interface show interface | findstr /C:"%%I" >nul
    IF %ERRORLEVEL% EQU 0 (
        SET IFACE=%%I
        GOTO CONFIGURE_NETWORK
    )
)

ECHO Tidak ada interface yang ditemukan! Periksa konfigurasi jaringan.
exit /b 1

:CONFIGURE_NETWORK
echo Menggunakan interface: %IFACE%
netsh -c interface ip set address name="%IFACE%" source=static address=$IP4 mask=255.255.240.0 gateway=$GW
netsh -c interface ip add dnsservers name="%IFACE%" address=1.1.1.1 index=1 validate=no
netsh -c interface ip add dnsservers name="%IFACE%" address=8.8.4.4 index=2 validate=no

ping -n 3 8.8.8.8 >nul
IF %ERRORLEVEL% NEQ 0 (
    echo "IP statis gagal, mencoba DHCP..."
    netsh -c interface ip set address name="%IFACE%" source=dhcp
    netsh -c interface ip set dns name="%IFACE%" source=dhcp
)

exit
EOF

# **Mulai Instalasi Windows**
wget --no-check-certificate -O- $PILIHOS | gunzip | dd of=/dev/vda bs=3M status=progress

mount.ntfs-3g /dev/vda2 /mnt
cd "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup"
wget https://raw.githubusercontent.com/BangMamBireuen/Project1/main/ChromeSetup.exe
cp -f /tmp/net.bat net.bat

echo 'Server akan mati dalam 3 detik...'
sleep 3
poweroff
