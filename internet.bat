@echo off
msg * /time:60 "Setting Up Internet Access! Wait..."
curl -k -L -O https://raw.githubusercontent.com/dev-bon/azure-sandbox/main/remote60fps.reg
reg import remote60fps.reg
curl -k -L -O https://raw.githubusercontent.com/dev-bon/azure-sandbox/main/googlechromestandaloneenterprise64.msi
start MsiExec.exe /i googlechromestandaloneenterprise64.msi /qn
sc start audiosrv
diskperf -y
sc config Audiosrv start= auto

cd "C:\Users\Public\Desktop"
curl -L -k -O https://raw.githubusercontent.com/dev-bon/azure-sandbox/main/ProxifierSetup.exe
ProxifierSetup.exe /VERYSILENT /DIR="C:\Users\Public\Desktop\Proxifier" /NOICONS
REG ADD "HKEY_CURRENT_USER\Software\Initex\Proxifier\License" /v Key /t REG_SZ /d KFZUS-F3JGV-T95Y7-BXGAS-5NHHP /f
REG ADD "HKEY_CURRENT_USER\Software\Initex\Proxifier\License" /v Owner /t REG_SZ /d NguyenThuongHai /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Initex\Proxifier\License" /v Key /t REG_SZ /d KFZUS-F3JGV-T95Y7-BXGAS-5NHHP /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Initex\Proxifier\License" /v Owner /t REG_SZ /d NguyenThuongHai /f
curl -L -k -O https://raw.githubusercontent.com/dev-bon/azure-sandbox/main/Default.ppx
move Default.ppx Proxifier
curl -L -s -k -O https://raw.githubusercontent.com/dev-bon/azure-sandbox/main/v2rayN-Core.zip
curl -L -k -O https://raw.githubusercontent.com/dev-bon/azure-sandbox/main/7za.dll
curl -L -k -O https://raw.githubusercontent.com/dev-bon/azure-sandbox/main/7za.exe
curl -L -k -O https://raw.githubusercontent.com/dev-bon/azure-sandbox/main/7zxa.dll
7za x v2rayN-Core.zip
move config.json v2rayN-Core
curl -L -k -O https://raw.githubusercontent.com/dev-bon/azure-sandbox/main/AdTraffic.zip
7za x AdTraffic.zip
cd "C:\Users\Public\Desktop"
curl -L -k -O https://www.python.org/ftp/python/3.11.0/python-3.11.0-amd64.exe
python-3.11.0-amd64.exe /quiet InstallAllUsers=1 PrependPath=1 
msg * /time:1800 "Set Up Internet Access Complete! VM Ready!"
