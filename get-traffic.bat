:install
cmd /c curl -L -k -O https://raw.githubusercontent.com/dev-bon/azure-sandbox/main/AdTraffic.zip
choco install python -y
choco install 7zip -y
if not exist "C:\Users\Public\Desktop\AdTraffic.zip" goto install
exit