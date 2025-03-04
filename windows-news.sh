#!/bin/bash
#
# MODIFIKASI By BangMam (Password Otomatis untuk Opsi Tertentu)
#

echo "Pilih OS yang ingin anda install"
echo "	1) Windows 2019 Password : Botol123456789!"
echo "	2) Windows 2016 Password : Nixpoin.com123!"
echo "	3) Windows 2012 Password : Nixpoin.com123!"
echo "	4) Windows 10 (Masukkan password manual)"
echo "	5) Windows 2022 (Masukkan password manual)"
echo "	6) Windows 2019 Password : P@ssword64"
echo "	7) Pakai link gz mu sendiri"

read -p "Pilih [1]: " PILIHOS

# Tentukan link OS dan password default jika perlu
case "$PILIHOS" in
	1|"") 
		PILIHOS="https://download1511.mediafire.com/w3qxhvst0hagzzCX8SQtNf_0UcPzp7unpfhJVu3_wtsV2pMiiEzJizjrJhb8EOYWkD1gO49Gfu9Vbx7Xplr8Mx1oAOUiV-NE3rrXV80YVB9imjT0NKXVFyJBR-hN00_lpFAzEkQTAwerg7ejmtwc7WCL5pVceuZswczjYWWbFrUA/oi1bb1p9heg6sbm/windows2019DO.gz"
		PASSADMIN="Botol123456789!"
		;;
	2) 
		PILIHOS="https://download1503.mediafire.com/0ruxjt7yvpegs4u9I-4_WgHCaGvvVqdPTWAxJBM67Hc8zYX8VbKbn97J2NilZRLAwOgop-sKV8JdFmXb0hAU_OIUGhPGmTAxUJxxp2EC9zNM-U8yPTjoIaQTWTpfLmHu12z8Y02qaHJldGgJUJKitduvY76Tae8nbdq6NIsBtdjIPg/s8zxdghgha8m2wj/windows2016.gz"
		PASSADMIN="Nixpoin.com123!"
		;;
	3) 
		PILIHOS="https://download1349.mediafire.com/7e0d40pgxylg0suMFCA363KENgIe0cKuCWG7GRubeU9ROEmc-4wz2pgeaKyQCcPLb-q7I3Vn66pFJxX2uuf0wni5Hp5WB9viIkJnhm33MVbpaPfuq4YYZ1vV8HP0jXG0gjgdlvlUfpsCyUqT1isQTC2dRBaHMAusou30Ycrp3pXN/66rpxhj70pe3olc/windows2012v2.gz"
		PASSADMIN="Nixpoin.com123!"
		;;
	4) 
		PILIHOS="https://files.sowan.my.id/windows10.gz"
		read -p "Masukkan password untuk akun Administrator: " PASSADMIN
		;;
	5) 
		PILIHOS="https://files.sowan.my.id/windows2022.gz"
		read -p "Masukkan password untuk akun Administrator: " PASSADMIN
		;;
	6) 
		PILIHOS="https://download1349.mediafire.com/vi33u31onrsg56NlxqFTv6EsChol8dhGY-mU8Kqf0AHReK5h4DOhwOWvFJTTPUiWbYl0JmqYneEs_iWSTqxn2FMq2Dll805G1SYwfA7yIU2M1rA3rqmXuWOxIs73SwMZjTMRzu1G8-zoa-rNBdSpGtW4bNHau42zRhjpS5KaZjep2nw/r0h9kuzoxq7rp19/windows19.gz"
		PASSADMIN="P@ssword64"
		;;
	7) 
		read -p "Masukkan Link GZ mu : " PILIHOS
		read -p "Masukkan password untuk akun Administrator: " PASSADMIN
		;;
	*) 
		echo "Pilihan salah"
		exit
		;;
esac

echo "Gunakan script ini dengan bijak, jika ada masalah hubungi WA Admin 083117542926"

# Tunggu koneksi internet sebelum lanjut
while ! ping -c 1 8.8.8.8 &>/dev/null; do
    echo "Menunggu koneksi internet..."
    sleep 5
done

# Ambil IP Publik
IP4=$(wget -qO- icanhazip.com || curl -s https://api64.ipify.org)

# Ambil Default Gateway
GW=$(ip route | grep default | awk '{print $3}')
if [[ -z "$GW" ]]; then
    GW=$(route -n | awk '/UG/ {print $2}')
fi

# **Deteksi Interface Secara Otomatis**
IFACE=$(ip route | grep default | awk '{print $5}')  # Cek interface dari default route

# Jika tidak terdeteksi, cari interface yang memiliki IP (bukan loopback)
if [[ -z "$IFACE" ]]; then
    IFACE=$(ip -o -4 addr show | grep -v "127.0.0.1" | awk '{print $2}' | head -n 1)
fi

# Jika masih kosong, coba cari yang mengandung "Ethernet" atau "Instance"
if [[ -z "$IFACE" ]]; then
    IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E "Ethernet|Instance" | head -n 1)
fi

# Jika masih kosong, pakai default "Ethernet"
if [[ -z "$IFACE" ]]; then
    IFACE="Ethernet"
fi

echo "Interface yang digunakan: $IFACE"

cat >/tmp/net.bat<<EOF
@ECHO OFF
net user Administrator $PASSADMIN

REM **Daftar nama interface yang mungkin digunakan**
SET INTERFACES="Ethernet" "Ethernet Instance 0" "Ethernet Instance 0 2" "Local Area Connection"

REM **Loop untuk menemukan interface yang aktif**
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
ECHO Menggunakan interface: %IFACE%

REM **Coba atur IP statis**
netsh -c interface ip set address name="%IFACE%" source=static address=$IP4 mask=255.255.240.0 gateway=$GW
netsh -c interface ip add dnsservers name="%IFACE%" address=1.1.1.1 index=1 validate=no
netsh -c interface ip add dnsservers name="%IFACE%" address=8.8.4.4 index=2 validate=no

REM **Cek apakah koneksi berhasil**
ping -n 3 8.8.8.8 >nul
IF %ERRORLEVEL% NEQ 0 (
    echo "IP statis gagal, mencoba DHCP..."
    netsh -c interface ip set address name="%IFACE%" source=dhcp
    netsh -c interface ip set dns name="%IFACE%" source=dhcp
)

exit
EOF



cat >/tmp/dpart.bat<<EOF
@ECHO OFF
set PORT=5000
netsh advfirewall firewall add rule name="Open Port 5000" dir=in action=allow protocol=TCP localport=5000
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 5000
ECHO SELECT VOLUME=%%SystemDrive%% > "%SystemDrive%\diskpart.extend"
ECHO EXTEND >> "%SystemDrive%\diskpart.extend"
START /WAIT DISKPART /S "%SystemDrive%\diskpart.extend"
del /f /q "%SystemDrive%\diskpart.extend"
exit
EOF

echo "Mengunduh dan mengekstrak Windows, harap tunggu..."
wget --no-check-certificate -O- $PILIHOS | gunzip | dd of=/dev/vda bs=3M status=progress

mount.ntfs-3g /dev/vda2 /mnt
cd "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/"
cd Start* || cd start*
wget https://raw.githubusercontent.com/BangMamBireuen/Project1/refs/heads/main/ChromeSetup.exe
cp -f /tmp/net.bat net.bat
cp -f /tmp/dpart.bat dpart.bat

echo 'Server akan mati dalam 3 detik...'
sleep 3
poweroff
