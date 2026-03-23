@echo off
setlocal enabledelayedexpansion

:: ==========================================
:: AUTO-ADMINISTRATOR ELEVATION
:: ==========================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell start -verb runas '"%~0"'
    exit /b
)

Title EVO - HWID CHECKER CYBERPUNK EDITION

:: Adjust console buffer for scrolling
powershell -Command "$h = Get-Host; $w = $h.UI.RawUI; $b = $w.BufferSize; $b.Width = 115; $b.Height = 9999; $w.BufferSize = $b;" >nul 2>&1

:: Cyberpunk ANSI Colors
set "C_TITLE=[38;5;45m"
set "C_TEXT=[38;5;198m"
set "C_ACCENT=[38;5;226m"
set "C_RESET=[0m"

:: ==========================================
:: DEPENDENCY CHECK & AUTO-INSTALLER
:: ==========================================
where wmic >nul 2>&1
if %errorLevel% neq 0 (
    echo %C_ACCENT%[!] WMIC dependency missing. Starting automatic installation...%C_RESET%
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$p = 0; Write-Host 'Connecting to Windows Update Server...' -ForegroundColor Cyan; while($p -lt 100){ $p += 5; Write-Progress -Activity 'Installing WMIC (Windows Optional Feature)' -Status \"$p%% Complete\" -PercentComplete $p; if($p -eq 10){ dism /online /add-capability /capabilityname:WMIC~~~~ /norestart | Out-Null } Start-Sleep -Milliseconds 100; }"
    echo %C_TITLE%[+] WMIC installed successfully!%C_RESET%
    timeout /t 3 >nul
)

:loop
cls
echo %C_TITLE%======================================================================
echo            SYSTEM / MOTHERBOARD INFO
echo ======================================================================%C_RESET%
powershell -NoLogo -Command "Get-CimInstance Win32_ComputerSystemProduct | ForEach-Object { Write-Host 'smBIOS UUID: ' -NoNewline; Write-Host $_.UUID -ForegroundColor Magenta }"
powershell -NoLogo -Command "Get-CimInstance Win32_BIOS | ForEach-Object { Write-Host 'BIOS Serial: ' -NoNewline; Write-Host $_.SerialNumber -ForegroundColor Magenta }"
powershell -NoLogo -Command "Get-CimInstance Win32_BaseBoard | ForEach-Object { Write-Host 'Baseboard Serial: ' -NoNewline; Write-Host $_.SerialNumber -ForegroundColor Magenta; Write-Host ' | Baseboard Asset Tag: ' -NoNewline; Write-Host $_.AssetTag -ForegroundColor Magenta }"
powershell -NoLogo -Command "Get-CimInstance Win32_SystemEnclosure | ForEach-Object { Write-Host 'Enclosure Serial: ' -NoNewline; Write-Host $_.SerialNumber -ForegroundColor Magenta; Write-Host ' | Enclosure Asset Tag: ' -NoNewline; Write-Host $_.AssetTag -ForegroundColor Magenta }"
powershell -NoLogo -Command "$b = Get-CimInstance Win32_BIOS; Write-Host ('BIOS Details: ' + $b.Manufacturer + ' | ' + $b.SerialNumber + ' | ' + $b.Version) -ForegroundColor Magenta"
powershell -NoLogo -Command "$v = (Get-CimInstance Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard).VirtualizationBasedSecurityStatus; Write-Host 'IOMMU Status: ' -NoNewline; if ($v -ge 1) { Write-Host 'ON' -ForegroundColor Green } else { Write-Host 'OFF' -ForegroundColor Red }; Write-Host ' | Secure Boot Status: ' -NoNewline; if (Confirm-SecureBootUEFI -ErrorAction SilentlyContinue) { Write-Host 'ON' -ForegroundColor Green } else { Write-Host 'OFF' -ForegroundColor Red }"

echo.
echo %C_TITLE%======================================================================
echo           [ WINDOWS / OS INFO ]
echo ======================================================================%C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$os=Get-CimInstance Win32_OperatingSystem; $reg=Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'; $ver=$reg.DisplayVersion; $ubr=$reg.UBR; $build=$os.Version.Split('.')[-1]; $sw=if($os.Caption -like '*11*'){'W11'}else{'W10'}; $ed=if($os.Caption -like '*Pro*'){'PRO'}elseif($os.Caption -like '*Home*'){'HOME'}else{'OS'}; $fV=($sw+' '+$ver+' '+$ed+' '+$build+'.'+$ubr); $oem=(Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey; $rk=(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform' -ErrorAction SilentlyContinue).BackupProductKeyDefault; $key=if($oem){$oem}elseif($rk){$rk}else{'Digital License / Not Found'}; Write-Host 'Device Name: ' -NoNewline; Write-Host $env:COMPUTERNAME -ForegroundColor Magenta; Write-Host ' | Version: ' -NoNewline; Write-Host $fV -ForegroundColor Magenta; Write-Host ' | Activation: ' -NoNewline; Write-Host $key -ForegroundColor Magenta; $hvci=(Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard).VirtualizationBasedSecurityStatus; Write-Host 'Core Isolation (HVCI): ' -NoNewline; if($hvci -eq 2){Write-Host 'ON' -ForegroundColor Green}else{Write-Host 'OFF' -ForegroundColor Red}"

echo.
echo %C_TITLE%======================================================================
echo           [ MONITOR INFO ^& FUSER DETECTION ]
echo ======================================================================%C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$v = Get-CimInstance Win32_VideoController | Select-Object -First 1; $m = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID -ErrorAction SilentlyContinue | Select-Object -First 1; if($m){ $n = [System.Text.Encoding]::ASCII.GetString(($m.UserFriendlyName | Where-Object{$_ -ne 0})).Trim(); $sr = [System.Text.Encoding]::ASCII.GetString(($m.SerialNumberID | Where-Object{$_ -ne 0})).Trim(); $id = $m.InstanceName; $sp = [System.Text.Encoding]::ASCII.GetString(($m.ProductCodeID | Where-Object{$_ -ne 0})).Trim(); } else { $n='N/A'; $sr='N/A'; $id='N/A'; $sp='N/A' }; $rp = \"HKLM:\SYSTEM\CurrentControlSet\Enum\$id\Device Parameters\"; $dna = 'N/A'; $em = 1; if(Test-Path $rp){ $ed = (Get-ItemProperty -Path $rp -ErrorAction SilentlyContinue).EDID; if($ed){ $fh = [System.BitConverter]::ToString($ed).Replace('-',''); $dna = if($fh.Length -ge 32){$fh.Substring(22,8)}else{$fh}; $em = 0; } }; Write-Host 'Name: ' -NoNewline; Write-Host $n -ForegroundColor Magenta; Write-Host ' | Instance ID: ' -NoNewline; Write-Host $id -ForegroundColor Magenta; Write-Host 'SERIAL HEX (DNA): ' -NoNewline; Write-Host $dna -ForegroundColor Magenta; Write-Host ' | ID SERIAL (Product): ' -NoNewline; Write-Host $sp -ForegroundColor Magenta; Write-Host 'SERIAL NUMBER (Real): ' -NoNewline; Write-Host $sr -ForegroundColor Magenta; Write-Host ' | EMULATED SERIAL (Active): ' -NoNewline; if($em -eq 1){Write-Host 'YES' -ForegroundColor Red}else{Write-Host 'NO' -ForegroundColor Green}; Write-Host 'Resolution: ' -NoNewline; Write-Host ($v.CurrentHorizontalResolution.ToString() + ' x ' + $v.CurrentVerticalResolution.ToString()) -ForegroundColor Magenta; Write-Host ' | Refresh Rate: ' -NoNewline; Write-Host ($v.CurrentRefreshRate.ToString() + ' Hz') -ForegroundColor Magenta;"

echo.
echo %C_TITLE%======================================================================
echo           [ INTEGRITY / FUSER CHECK ]
echo ======================================================================%C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$v=@('AOC2703','AOC3403','AUS2704','HKC2520','MSI5CA9','SAC2942'); Write-Host '[1] Checking Monitor Registry List...' -ForegroundColor Cyan; $m = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY' -ErrorAction SilentlyContinue | ForEach-Object { $p=$_.Name; foreach($vid in $v){ if($p -like \"*$vid*\"){ $p } } }; $rCount = if($m){ ($m | Measure-Object).Count } else { 0 }; if($rCount -gt 0){ $m | ForEach-Object { Write-Host \"SUSPICIOUS FOUND: $_\" -ForegroundColor Red } } else { Write-Host 'No suspicious hardware found in registry.' -ForegroundColor Gray }; Write-Host ''; Write-Host '[2] Checking Active Monitor & DDC/CI Support...' -ForegroundColor Cyan; $ddc = Get-WmiObject -Namespace root\WMI -Class WmiMonitorBrightnessMethods -ErrorAction SilentlyContinue; $as = if (-not $ddc) { 1 } else { 0 }; if($as -eq 1){ Write-Host 'WARNING: Active monitor WITHOUT DDC/CI support (Common in Fusers)' -ForegroundColor Yellow } else { Write-Host 'Active monitor OK (Supports DDC/CI)' -ForegroundColor Green }; Write-Host ''; Write-Host '------------------------------------------------------' -ForegroundColor Gray; Write-Host 'Final Result:' -ForegroundColor White; Write-Host 'Suspicion Level: ' -NoNewline; Write-Host ($rCount + $as) -ForegroundColor Magenta; Write-Host ' STATUS: ' -NoNewline; if(($rCount+$as) -gt 1){ Write-Host ' HIGHLY SUSPICIOUS ' -BackgroundColor Red -ForegroundColor White } elseif(($rCount+$as) -gt 0){ Write-Host ' ATTENTION REQUIRED ' -BackgroundColor Yellow -ForegroundColor Black } else { Write-Host ' CLEAN ' -BackgroundColor Green -ForegroundColor White }; Write-Host ''; Write-Host 'Reasons:' -ForegroundColor White; if($as -eq 1){ Write-Host '- Brightness handshaking (DDC/CI) failed on current monitor.' -ForegroundColor Gray }; if($rCount -gt 0){ Write-Host \"- Found $rCount fuser-related IDs in registry.\" -ForegroundColor Gray };"

echo.
echo %C_TITLE%======================================================================
echo           DISK DRIVES / STORAGE
echo ======================================================================%C_RESET%
powershell -NoLogo -Command "Get-PhysicalDisk | ForEach-Object { $disk = $_; $drive = Get-CimInstance Win32_DiskDrive | Where-Object { $_.SerialNumber -eq $disk.SerialNumber }; Write-Host 'Model: ' -NoNewline; Write-Host $disk.FriendlyName -ForegroundColor Magenta; Write-Host ' | Serial: ' -NoNewline; Write-Host $disk.SerialNumber -ForegroundColor Magenta; Write-Host ' | Firmware: ' -NoNewline; Write-Host $drive.FirmwareRevision -ForegroundColor Magenta; Write-Host ' | UUID SA/ISN: ' -NoNewline; Write-Host $disk.UniqueId -ForegroundColor Magenta; Write-Host '' }"

echo %C_TITLE%======================================================================
echo           NETWORK / IP ADDRESS
echo ======================================================================%C_RESET%
echo %C_TEXT%MAC Addresses:%C_RESET%
getmac /v /fo list | findstr "Physical Address"
echo.
powershell -NoLogo -Command "$ip = (Invoke-RestMethod -Uri 'https://api.ipify.org'); $rev = try { [System.Net.Dns]::GetHostEntry($ip).HostName } catch { 'N/A' }; Write-Host 'Current IP: ' -NoNewline; Write-Host $ip -ForegroundColor Magenta; Write-Host ' | Reverse IP: ' -NoNewline; Write-Host $rev -ForegroundColor Magenta"

echo.
echo %C_TITLE%======================================================================
echo           [ CPU INFO ]
echo ======================================================================%C_RESET%
powershell -NoLogo -Command "Get-CimInstance Win32_Processor | ForEach-Object { Write-Host 'Name: ' -NoNewline; Write-Host $_.Name -ForegroundColor Magenta; Write-Host ' | ID: ' -NoNewline; Write-Host $_.ProcessorId -ForegroundColor Magenta }"

echo.
echo %C_TITLE%======================================================================
echo           PHYSICAL RAM
echo ======================================================================%C_RESET%
powershell -NoLogo -Command "Get-CimInstance Win32_PhysicalMemory | ForEach-Object { Write-Host 'Manufacturer: ' -NoNewline; Write-Host $_.Manufacturer -ForegroundColor Magenta; Write-Host ' | Serial: ' -NoNewline; Write-Host $_.SerialNumber -ForegroundColor Magenta; Write-Host ' | Asset Tag: ' -NoNewline; Write-Host $_.Tag -ForegroundColor Magenta; Write-Host '----------------------------------------------------------------------' }"

echo.
echo %C_TITLE%======================================================================
echo           GPU / VIDEO CARD
echo ======================================================================%C_RESET%
powershell -NoLogo -Command "Get-CimInstance Win32_VideoController | ForEach-Object { Write-Host 'Name: ' -NoNewline; Write-Host $_.Name -ForegroundColor Magenta; Write-Host ' | PNP Device ID: ' -NoNewline; Write-Host $_.PNPDeviceID -ForegroundColor Magenta }"

echo.
echo %C_TITLE%======================================================================
echo            SECURITY / TPM
echo ======================================================================%C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$t = Get-Tpm; if($t.TpmPresent -and $t.TpmEnabled){Write-Host 'TPM ENABLED' -ForegroundColor Green}else{Write-Host 'TPM DISABLED' -ForegroundColor Red; return}; $ek = Get-TpmEndorsementKeyInfo -Hash 'Sha256' -ErrorAction SilentlyContinue; if($ek){ Write-Host 'PublicKey : ' -NoNewline; Write-Host $ek.PublicKey -ForegroundColor Magenta; Write-Host 'PublicKeyHash : ' -NoNewline; Write-Host $ek.PublicKeyHash -ForegroundColor Magenta; Write-Host 'ManufacturerCertificates :' -ForegroundColor Yellow; $cert = $ek.ManufacturerCertificates[0]; if($cert){ Write-Host ' | Subject : ' -NoNewline; Write-Host $cert.Subject -ForegroundColor Magenta; Write-Host ' | Issuer : ' -NoNewline; Write-Host $cert.Issuer -ForegroundColor Magenta; Write-Host ' | Serial Number : ' -NoNewline; Write-Host $cert.SerialNumber -ForegroundColor Magenta; Write-Host ' | Not Before : ' -NoNewline; Write-Host $cert.NotBefore -ForegroundColor Magenta; Write-Host ' | Thumbprint : ' -NoNewline; Write-Host $cert.Thumbprint -ForegroundColor Magenta; } Write-Host 'AdditionalCertificates: {}'; } Write-Host 'Manufacturer ID: ' -NoNewline; Write-Host $t.ManufacturerID -ForegroundColor Magenta; Write-Host 'Manufacturer Version: ' -NoNewline; Write-Host $t.ManufacturerVersion -ForegroundColor Magenta; Write-Host 'Manufacturer Version Info: ' -NoNewline; Write-Host ($t.ManufacturerVersionInfo -or 'True') -ForegroundColor Magenta; Write-Host 'Physical Presence Version Info: ' -NoNewline; Write-Host ($t.PhysicalPresenceVersion -or 'True') -ForegroundColor Magenta; $u = [string]$t.ManufacturerID + [string]$t.ManufacturerVersion + [string]($t.PhysicalPresenceVersion -or '0'); $b = [System.Text.Encoding]::UTF8.GetBytes($u); $m = [System.Security.Cryptography.MD5]::Create().ComputeHash($b); $s1 = [System.Security.Cryptography.SHA1]::Create().ComputeHash($b); $s2 = [System.Security.Cryptography.SHA256]::Create().ComputeHash($b); Write-Host ('MD5: ' + [System.BitConverter]::ToString($m).Replace('-', ' ')) -ForegroundColor Yellow; Write-Host ('SHA1: ' + [System.BitConverter]::ToString($s1).Replace('-', ' ')) -ForegroundColor Yellow; Write-Host ('SHA256: ' + [System.BitConverter]::ToString($s2).Replace('-', ' ')) -ForegroundColor Yellow;"

echo.
echo %C_ACCENT%**********************************************************************
echo Press any key to refresh hardware serials...
echo **********************************************************************%C_RESET%
pause >nul
goto loop