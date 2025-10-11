#!/bin/bash
# ======================================
# CREATED By NIXPOIN.COM
# EDITION By BANGMAM
# ======================================
#
echo "Windows 2019 akan diinstall"

PILIHOS="https://my.microsoftpersonalcontent.com/personal/3e7bbf1bd5ba2881/_layouts/15/download.aspx?UniqueId=ed773a13-dced-4e50-a5f7-6e769bb71c2f&Translate=false&tempauth=v1e.eyJzaXRlaWQiOiIwZjM5OWY3NS1mMzkyLTRlODgtOWYzNC1iM2Y4MDRkOWIxZmMiLCJhdWQiOiIwMDAwMDAwMy0wMDAwLTBmZjEtY2UwMC0wMDAwMDAwMDAwMDAvbXkubWljcm9zb2Z0cGVyc29uYWxjb250ZW50LmNvbUA5MTg4MDQwZC02YzY3LTRjNWItYjExMi0zNmEzMDRiNjZkYWQiLCJleHAiOiIxNzYwMTY4MTc5In0.bma7sgectAt4nTHdOjZ9z0ldVBJIdmXhYTZW-SL9qoK3zHdXYDBWTXwl_306TJd9SEHx6Ql9suMG6aUoYcmwHD1Ci-Hi_BPPuct_R79Q5SyGte51zGrxuAZMeh8VDVp50es6qhDe_ZL0B3w9sLHQRZUqAMFRDUjAzVyz2SUisdDtfRhNdYFGWk4t2mZI34SetcHBy-UPEgk_6OMPvLcT3RogV4CzreXYeIUuZDe0Upp3phuil2D4g2WcvJV7W0nrwMAyrIEJVhcMzbeNsUrgz5VHFTovzYA4rJY2i6RvwZ--3CtgrzsuhYA3ixomsfSPh-5_6DUKqYtAB1jrnDph3a7UlJJocjT2q8aIdWCZyj6FFVl6VpcwuIYFvTP2ssUbx5ewAhRft9q4FeC1x7v0BROCFkp3CNVjqM50uEP5Ps5ui2wZ0bpGEK1A7DGMiRl3E7OpYwS3tg1JtQ19HVhpcp0UO7FahxJYuc7Um7BVjtv-TUvDDJGbC8wGKoMlfsiQoIg1z8CTjudBvOOm1i1lew.qJrT5i0oo0JABiD_2-oTT56Y8kvr7NQH338fmTmk7l0&ApiVersion=2.0"
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
