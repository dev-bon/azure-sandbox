@echo off
msg * /time:60 "Setting Up Internet Access! Wait..."
curl -k -L -O https://raw.githubusercontent.com/kmille36/thuonghai/master/katacoda/AZ/remote60fps.reg
reg import remote60fps.reg
curl -k -L -O https://github.com/kmille36/thuonghai/releases/download/1.0.0/googlechromestandaloneenterprise64.msi
start MsiExec.exe /i GoogleChromeStandaloneEnterprise64.msi /qn
sc start audiosrv
diskperf -y
sc config Audiosrv start= auto

cd "C:\Users\Public\Desktop"
curl -L -k -O https://raw.githubusercontent.com/kmille36/thuonghai/master/ProxifierSetup.exe
ProxifierSetup.exe /VERYSILENT /DIR="C:\Users\Public\Desktop\Proxifier" /NOICONS
REG ADD "HKEY_CURRENT_USER\Software\Initex\Proxifier\License" /v Key /t REG_SZ /d KFZUS-F3JGV-T95Y7-BXGAS-5NHHP /f
REG ADD "HKEY_CURRENT_USER\Software\Initex\Proxifier\License" /v Owner /t REG_SZ /d NguyenThuongHai /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Initex\Proxifier\License" /v Key /t REG_SZ /d KFZUS-F3JGV-T95Y7-BXGAS-5NHHP /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Initex\Proxifier\License" /v Owner /t REG_SZ /d NguyenThuongHai /f
curl -L -k -O https://raw.githubusercontent.com/kmille36/thuonghai/master/Default.ppx
curl -L -s -k -O https://github.com/2dust/v2rayN/releases/download/5.4/v2rayN-Core.zip
curl -L -k -O https://raw.githubusercontent.com/kmille36/thuonghai/master/7z.dll
curl -L -k -O https://raw.githubusercontent.com/kmille36/thuonghai/master/7z.exe 
7z x v2rayN-Core.zip
move config.json v2rayN-Core
curl -L -k -O https://raw.githubusercontent.com/dev-bon/azure-sandbox/main/AdTraffic.zip
7z x AdTraffic.zip
curl -L -k -O https://www.python.org/ftp/python/3.11.0/python-3.11.0-amd64.exe
C:\Users\Public\Desktop\python-3.11.0-amd64.exe /quiet InstallAllUsers=1 PrependPath=1 
msg * /time:1800 "Set Up Internet Access Complete! VM Ready!"
