#!/bin/bash
#
# MODIFIKASI By BangMam (Deteksi Interface Jaringan Otomatis)
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
	1|"") PILIHOS="https://download1511.mediafire.com/w3qxhvst0hagzzCX8SQtNf_0UcPzp7unpfhJVu3_wtsV2pMiiEzJizjrJhb8EOYWkD1gO49Gfu9Vbx7Xplr8Mx1oAOUiV-NE3rrXV80YVB9imjT0NKXVFyJBR-hN00_lpFAzEkQTAwerg7ejmtwc7WCL5pVceuZswczjYWWbFrUA/oi1bb1p9heg6sbm/windows2019DO.gz";;
	2) PILIHOS="https://download1503.mediafire.com/0ruxjt7yvpegs4u9I-4_WgHCaGvvVqdPTWAxJBM67Hc8zYX8VbKbn97J2NilZRLAwOgop-sKV8JdFmXb0hAU_OIUGhPGmTAxUJxxp2EC9zNM-U8yPTjoIaQTWTpfLmHu12z8Y02qaHJldGgJUJKitduvY76Tae8nbdq6NIsBtdjIPg/s8zxdghgha8m2wj/windows2016.gz";;
	3) PILIHOS="https://download1349.mediafire.com/7e0d40pgxylg0suMFCA363KENgIe0cKuCWG7GRubeU9ROEmc-4wz2pgeaKyQCcPLb-q7I3Vn66pFJxX2uuf0wni5Hp5WB9viIkJnhm33MVbpaPfuq4YYZ1vV8HP0jXG0gjgdlvlUfpsCyUqT1isQTC2dRBaHMAusou30Ycrp3pXN/66rpxhj70pe3olc/windows2012v2.gz";;
	4) PILIHOS="https://files.sowan.my.id/windows10.gz";;
	5) PILIHOS="https://files.sowan.my.id/windows2022.gz";;
	6) PILIHOS="https://download1349.mediafire.com/vi33u31onrsg56NlxqFTv6EsChol8dhGY-mU8Kqf0AHReK5h4DOhwOWvFJTTPUiWbYl0JmqYneEs_iWSTqxn2FMq2Dll805G1SYwfA7yIU2M1rA3rqmXuWOxIs73SwMZjTMRzu1G8-zoa-rNBdSpGtW4bNHau42zRhjpS5KaZjep2nw/r0h9kuzoxq7rp19/windows19.gz";;
	7) read -p "Masukkan Link GZ mu : " PILIHOS;;
	*) echo "Pilihan salah"; exit;;
esac

echo "Gunakan script ini dengan bijak, jika ada masalah hubungi WA Admin 083117542926"

read -p "Masukkan password untuk akun Administrator: " PASSADMIN

# Menunggu koneksi internet sebelum lanjut
while ! ping -c 1 8.8.8.8 &>/dev/null; do
    echo "Menunggu koneksi internet..."
    sleep 5
done

# Ambil IP Publik (pakai metode alternatif jika gagal)
IP4=$(wget -qO- icanhazip.com || curl -s https://api64.ipify.org)

# Ambil Default Gateway (pakai metode alternatif jika gagal)
GW=$(ip route | grep default | awk '{print $3}')
if [[ -z "$GW" ]]; then
    GW=$(route -n | awk '/UG/ {print $2}')
fi

# **Deteksi Interface Secara Otomatis**
IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E "Ethernet|Instance" | head -n 1)

# **Jika lebih dari satu interface, pilih yang memiliki koneksi aktif**
if [[ $(echo "$IFACE" | wc -l) -gt 1 ]]; then
    IFACE=$(ip -4 route ls | grep default | awk '{print $5}')
fi

# **Jika masih kosong, pakai default "Ethernet"**
if [[ -z "$IFACE" ]]; then
    IFACE="Ethernet"
fi

echo "Interface yang digunakan: $IFACE"

cat >/tmp/net.bat<<EOF
@ECHO OFF
net user Administrator $PASSADMIN
netsh -c interface ip set address name="$IFACE" source=static address=$IP4 mask=255.255.240.0 gateway=$GW
netsh -c interface ip add dnsservers name="$IFACE" address=1.1.1.1 index=1 validate=no
netsh -c interface ip add dnsservers name="$IFACE" address=8.8.4.4 index=2 validate=no
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
