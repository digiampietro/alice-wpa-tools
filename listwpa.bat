echo off
for /f "usebackq delims==" %%m in (`ssid2mac.exe %1`) do for /f "usebackq delims==" %%s in (`ssid2ser.exe -s %1 -c config.txt -m %%m`) do sermac2wpa.exe -q -s %%s -m %%m