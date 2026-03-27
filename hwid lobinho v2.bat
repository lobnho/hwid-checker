@echo off
setlocal enabledelayedexpansion

:: 
:: AUTO-ADMINISTRATOR ELEVATION
:: 
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell start -verb runas '"%~0"'
    exit /b
)

Title LOBINHO - HWID CHECKER

:: Adjust console buffer for scrolling
powershell -Command "$h = Get-Host; $w = $h.UI.RawUI; $b = $w.BufferSize; $b.Width = 115; $b.Height = 9999; $w.BufferSize = $b;" >nul 2>&1

:: Cyberpunk ANSI Colors
set "C_TITLE=[38;5;45m"
set "C_TEXT=[38;5;198m"
set "C_ACCENT=[38;5;226m"
set "C_RESET=[0m"

:: 
:: DEPENDENCY CHECK & AUTO-INSTALLER
:: 
where wmic >nul 2>&1
if %errorLevel% neq 0 (
    echo %C_ACCENT%[!] WMIC dependency missing. Starting automatic installation...%C_RESET%
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$p = 0; Write-Host 'Connecting to Windows Update Server...' -ForegroundColor Cyan; while($p -lt 100){ $p += 5; Write-Progress -Activity 'Installing WMIC (Windows Optional Feature)' -Status \"$p%% Complete\" -PercentComplete $p; if($p -eq 10){ dism /online /add-capability /capabilityname:WMIC~~~~ /norestart | Out-Null } Start-Sleep -Milliseconds 100; }"
    echo %C_TITLE%[+] WMIC installed successfully!%C_RESET%
    timeout /t 3 >nul
)

:loop
cls
echo.
echo %C_TITLE%
echo           [ SYSTEM / MOTHERBOARD INFO ^& IDENTITY ]
echo %C_RESET%
powershell -NoLogo -Command "$cs=Get-CimInstance Win32_ComputerSystem; $bb=Get-CimInstance Win32_BaseBoard; Write-Host 'System Manufacture: ' -NoNewline; Write-Host $cs.Manufacturer -ForegroundColor White; Write-Host ' | Board Model: ' -NoNewline; Write-Host $bb.Product -ForegroundColor Magenta"
powershell -NoLogo -Command "$b=Get-CimInstance Win32_BIOS; $rd=$b.ReleaseDate; $d=if($rd.Length -ge 8){$rd.Substring(6,2)+'/'+$rd.Substring(4,2)+'/'+$rd.Substring(0,4)}else{'N/A'}; Write-Host 'BIOS Vendor: ' -NoNewline; Write-Host $b.Manufacturer -ForegroundColor White; Write-Host ' | Version: ' -NoNewline; Write-Host $b.SMBIOSBIOSVersion -ForegroundColor Magenta; Write-Host ' | Date: ' -NoNewline; Write-Host $d -ForegroundColor Magenta"
powershell -NoLogo -Command "$sp=Get-CimInstance Win32_ComputerSystemProduct; $cs=Get-CimInstance Win32_ComputerSystem; $sku=if($cs.SystemSKUNumber){$cs.SystemSKUNumber}else{'Default'}; $fam=if($cs.SystemFamily){$cs.SystemFamily}else{'O.E.M.'}; Write-Host 'smBIOS UUID: ' -NoNewline; Write-Host $sp.UUID -ForegroundColor Magenta; Write-Host ' | SKU: ' -NoNewline; Write-Host $sku -ForegroundColor Magenta; Write-Host ' | Family: ' -NoNewline; Write-Host $fam -ForegroundColor Magenta"
powershell -NoLogo -Command "$bb=Get-CimInstance Win32_BaseBoard; $se=Get-CimInstance Win32_SystemEnclosure; Write-Host 'Baseboard Serial: ' -NoNewline; Write-Host $bb.SerialNumber -ForegroundColor Magenta; Write-Host ' | Enclosure Serial: ' -NoNewline; Write-Host $se.SerialNumber -ForegroundColor Magenta"
powershell -NoLogo -Command "$v=(Get-CimInstance Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard).VirtualizationBasedSecurityStatus; Write-Host 'IOMMU Status: ' -NoNewline; if($v -ge 1){Write-Host 'ON' -ForegroundColor Green}else{Write-Host 'OFF' -ForegroundColor Red}; Write-Host ' | Secure Boot: ' -NoNewline; if(Confirm-SecureBootUEFI -ErrorAction SilentlyContinue){Write-Host 'ON' -ForegroundColor Green}else{Write-Host 'OFF' -ForegroundColor Red}"

echo.
echo %C_TITLE%
echo            [ WINDOWS / OS INFO ^& IDENTITY ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$os=Get-CimInstance Win32_OperatingSystem; $reg=Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'; $ver=$reg.DisplayVersion; $ubr=$reg.UBR; $build=$os.Version.Split('.')[-1]; $sw=if($os.Caption -like '*11*'){'W11'}else{'W10'}; $ed=if($os.Caption -like '*Pro*'){'PRO'}elseif($os.Caption -like '*Home*'){'HOME'}else{'OS'}; $fV=($sw+' '+$ver+' '+$ed+' '+$build+'.'+$ubr); $oem=(Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey; $rk=(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform' -ErrorAction SilentlyContinue).BackupProductKeyDefault; $key=if($oem){$oem}elseif($rk){$rk}else{'Digital License / Not Found'}; Write-Host 'Device Name: ' -NoNewline; Write-Host $env:COMPUTERNAME -ForegroundColor Magenta; Write-Host ' | Version: ' -NoNewline; Write-Host $fV -ForegroundColor Magenta; Write-Host ' | Activation: ' -NoNewline; Write-Host $key -ForegroundColor Magenta; $hvci=(Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard).VirtualizationBasedSecurityStatus; Write-Host 'Core Isolation: ' -NoNewline; if($hvci -eq 2){Write-Host 'ON' -ForegroundColor Green}else{Write-Host 'OFF' -ForegroundColor Red}; $guid=(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Cryptography').MachineGuid; Write-Host ' | Machine GUID: ' -NoNewline; Write-Host $guid -ForegroundColor Magenta; $sid=([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value; Write-Host 'User Account SID: ' -NoNewline; Write-Host $sid -ForegroundColor Magenta"


echo.
echo %C_TITLE%
echo            [ MONITOR INFO ^& FUSER DETECTION ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$v = Get-CimInstance Win32_VideoController | Select-Object -First 1; Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID -ErrorAction SilentlyContinue | ForEach-Object { $m = $_; $n = [System.Text.Encoding]::ASCII.GetString(($m.UserFriendlyName | Where-Object{$_ -ne 0})).Trim(); $id = $m.InstanceName; $sp = [System.Text.Encoding]::ASCII.GetString(($m.ProductCodeID | Where-Object{$_ -ne 0})).Trim(); $s_edid = [System.Text.Encoding]::ASCII.GetString($m.SerialNumberID) -replace '\0',''; $rp = \"HKLM:\SYSTEM\CurrentControlSet\Enum\$id\Device Parameters\"; $dna = 'N/A'; $em = 1; if(Test-Path $rp){ $ed = (Get-ItemProperty -Path $rp -ErrorAction SilentlyContinue).EDID; if($ed){ $fh = [System.BitConverter]::ToString($ed).Replace('-',''); $dna = if($fh.Length -ge 32){$fh.Substring(22,8)}else{$fh}; $em = 0; } }; Write-Host 'Name: ' -NoNewline; Write-Host $n -ForegroundColor Magenta; Write-Host ' | Instance ID: ' -NoNewline; Write-Host $id -ForegroundColor Magenta; Write-Host 'SERIAL HEX (DNA): ' -NoNewline; Write-Host $dna -ForegroundColor Magenta; Write-Host ' | Product ID: ' -NoNewline; Write-Host $sp -ForegroundColor Magenta; if($s_edid.Trim()){ Write-Host ' | Monitor Serial (EDID): ' -NoNewline; Write-Host $s_edid.Trim() -ForegroundColor Magenta } else { Write-Host ' | Monitor Serial (EDID): 0' -ForegroundColor Magenta }; Write-Host ' | EMULATED SERIAL (Active): ' -NoNewline; if($em -eq 1){Write-Host 'YES' -ForegroundColor Red}else{Write-Host 'NO' -ForegroundColor Green}; Write-Host '----------------------------------------------------------------------' -ForegroundColor Gray; }; Write-Host 'Resolution: ' -NoNewline; Write-Host ($v.CurrentHorizontalResolution.ToString() + ' x ' + $v.CurrentVerticalResolution.ToString()) -ForegroundColor Magenta; Write-Host ' | Refresh Rate: ' -NoNewline; Write-Host ($v.CurrentRefreshRate.ToString() + ' Hz') -ForegroundColor Magenta;"

echo.
echo %C_TITLE%
echo           [ INTEGRITY / FUSER CHECK ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$v=@('AOC2703','AOC3403','AUS2704','HKC2520','MSI5CA9','SAC2942'); Write-Host '[1] Checking Monitor Registry List...' -ForegroundColor Cyan; $m = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY' -ErrorAction SilentlyContinue | ForEach-Object { $p=$_.Name; foreach($vid in $v){ if($p -like \"*$vid*\"){ $p } } }; $rCount = if($m){ ($m | Measure-Object).Count } else { 0 }; if($rCount -gt 0){ $m | ForEach-Object { Write-Host \"SUSPICIOUS FOUND: $_\" -ForegroundColor Red } } else { Write-Host 'No suspicious hardware found in registry.' -ForegroundColor Gray }; Write-Host ''; Write-Host '[2] Checking Active Monitor & DDC/CI Support...' -ForegroundColor Cyan; $ddc = Get-WmiObject -Namespace root\WMI -Class WmiMonitorBrightnessMethods -ErrorAction SilentlyContinue; $as = if (-not $ddc) { 1 } else { 0 }; if($as -eq 1){ Write-Host 'WARNING: Active monitor WITHOUT DDC/CI support (Common in Fusers)' -ForegroundColor Yellow } else { Write-Host 'Active monitor OK (Supports DDC/CI)' -ForegroundColor Green }; Write-Host ''; Write-Host '------------------------------------------------------' -ForegroundColor Gray; Write-Host 'Final Result:' -ForegroundColor White; Write-Host 'Suspicion Level: ' -NoNewline; Write-Host ($rCount + $as) -ForegroundColor Magenta; Write-Host ' STATUS: ' -NoNewline; if(($rCount+$as) -gt 1){ Write-Host ' HIGHLY SUSPICIOUS ' -BackgroundColor Red -ForegroundColor White } elseif(($rCount+$as) -gt 0){ Write-Host ' ATTENTION REQUIRED ' -BackgroundColor Yellow -ForegroundColor Black } else { Write-Host ' CLEAN ' -BackgroundColor Green -ForegroundColor White }; Write-Host ''; Write-Host 'Reasons:' -ForegroundColor White; if($as -eq 1){ Write-Host '- Brightness handshaking (DDC/CI) failed on current monitor.' -ForegroundColor Gray }; if($rCount -gt 0){ Write-Host \"- Found $rCount fuser-related IDs in registry.\" -ForegroundColor Gray };"

echo.
echo %C_TITLE%
echo           [ DISK DRIVES / STORAGE (MAPPED VOLUMES) ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_DiskDrive | ForEach-Object { $d=$_; $p=Get-PhysicalDisk | Where-Object {$_.SerialNumber -eq $d.SerialNumber}; Write-Host 'Model: ' -NoNewline; Write-Host $d.Model -ForegroundColor Magenta; Write-Host ' | Serial: ' -NoNewline; Write-Host $d.SerialNumber -ForegroundColor Magenta; Write-Host ' | Firmware: ' -NoNewline; Write-Host $d.FirmwareRevision -ForegroundColor Magenta; if($p){Write-Host ' | UUID: ' -NoNewline; Write-Host $p.UniqueId -ForegroundColor Magenta}; Get-CimAssociatedInstance -InputObject $d -Association Win32_DiskDriveToDiskPartition | ForEach-Object { Get-CimAssociatedInstance -InputObject $_ -Association Win32_LogicalDiskToPartition | ForEach-Object { Write-Host '   >> [Volume ' -NoNewline; Write-Host $_.DeviceID -NoNewline -ForegroundColor Cyan; Write-Host '] Serial: ' -NoNewline; Write-Host $_.VolumeSerialNumber -ForegroundColor Cyan } }; Write-Host '----------------------------------------------------------------------' -ForegroundColor Gray }"

echo.
echo %C_TITLE%
echo            [ NETWORK / IP ADDRESS ^& FINGERPRINT ]
echo %C_RESET%
echo %C_TEXT%Active Network Adapters (MAC List):%C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.MACAddress } | ForEach-Object { Write-Host 'Adapter: ' -NoNewline; Write-Host $_.Description -NoNewline -ForegroundColor White; Write-Host ' >> MAC: ' -NoNewline; Write-Host $_.MACAddress -ForegroundColor Magenta }"
echo.
echo %C_TEXT%Gateway Fingerprint (Router):%C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$gw = Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Get-NetNeighbor | Where-Object { $_.State -ne 'Permanent' } | Select-Object -First 1; if($gw){ Write-Host 'Gateway IP: ' -NoNewline; Write-Host $gw.IPAddress -NoNewline -ForegroundColor White; Write-Host ' | Gateway MAC: ' -NoNewline; Write-Host $gw.LinkLayerAddress -ForegroundColor Magenta } else { Write-Host 'Gateway: Not Found' -ForegroundColor Red }"
echo.
powershell -NoLogo -Command "$ip = (Invoke-RestMethod -Uri 'https://api.ipify.org'); $rev = try { [System.Net.Dns]::GetHostEntry($ip).HostName } catch { 'N/A' }; Write-Host 'Public IP: ' -NoNewline; Write-Host $ip -NoNewline -ForegroundColor Magenta; Write-Host ' | Reverse DNS: ' -NoNewline; Write-Host $rev -ForegroundColor Magenta"

echo.
echo %C_TITLE%
echo            [ PERIPHERALS / HID DEVICES ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice -Class 'Mouse','Keyboard' -Status OK | ForEach-Object { Write-Host 'Device: ' -NoNewline; Write-Host $_.FriendlyName -ForegroundColor White; Write-Host ' >> ID: ' -NoNewline; Write-Host $_.InstanceId -ForegroundColor Magenta }"

echo.
echo %C_TITLE%
echo           [ CPU INFO ]
echo %C_RESET%
powershell -NoLogo -Command "Get-CimInstance Win32_Processor | ForEach-Object { Write-Host 'Name: ' -NoNewline; Write-Host $_.Name -ForegroundColor Magenta; Write-Host ' | ID: ' -NoNewline; Write-Host $_.ProcessorId -ForegroundColor Magenta }"

echo.
echo %C_TITLE%
echo          [ PHYSICAL RAM ]
echo %C_RESET%
powershell -NoLogo -Command "Get-CimInstance Win32_PhysicalMemory | ForEach-Object { Write-Host 'Manufacturer: ' -NoNewline; Write-Host $_.Manufacturer -ForegroundColor Magenta; Write-Host ' | Serial: ' -NoNewline; Write-Host $_.SerialNumber -ForegroundColor Magenta; Write-Host ' | Asset Tag: ' -NoNewline; Write-Host $_.Tag -ForegroundColor Magenta; Write-Host '----------------------------------------------------------------------' }"

echo.
echo %C_TITLE%
echo          [ GPU / VIDEO CARD ]
echo %C_RESET%
powershell -NoLogo -Command "Get-CimInstance Win32_VideoController | ForEach-Object { Write-Host 'Name: ' -NoNewline; Write-Host $_.Name -ForegroundColor Magenta; Write-Host ' | PNP Device ID: ' -NoNewline; Write-Host $_.PNPDeviceID -ForegroundColor Magenta }"

echo.
echo %C_TITLE%
echo           [ SECURITY / TPM ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$t = Get-Tpm; if($t.TpmPresent -and $t.TpmEnabled){Write-Host 'TPM ENABLED' -ForegroundColor Green}else{Write-Host 'TPM DISABLED' -ForegroundColor Red; return}; $ek = Get-TpmEndorsementKeyInfo -Hash 'Sha256' -ErrorAction SilentlyContinue; if($ek){ Write-Host 'PublicKey : ' -NoNewline; Write-Host $ek.PublicKey -ForegroundColor Magenta; Write-Host 'PublicKeyHash : ' -NoNewline; Write-Host $ek.PublicKeyHash -ForegroundColor Magenta; Write-Host 'ManufacturerCertificates :' -ForegroundColor Yellow; $cert = $ek.ManufacturerCertificates[0]; if($cert){ Write-Host ' | Subject : ' -NoNewline; Write-Host $cert.Subject -ForegroundColor Magenta; Write-Host ' | Issuer : ' -NoNewline; Write-Host $cert.Issuer -ForegroundColor Magenta; Write-Host ' | Serial Number : ' -NoNewline; Write-Host $cert.SerialNumber -ForegroundColor Magenta; Write-Host ' | Not Before : ' -NoNewline; Write-Host $cert.NotBefore -ForegroundColor Magenta; Write-Host ' | Thumbprint : ' -NoNewline; Write-Host $cert.Thumbprint -ForegroundColor Magenta; } Write-Host 'AdditionalCertificates: {}'; } Write-Host 'Manufacturer ID: ' -NoNewline; Write-Host $t.ManufacturerID -ForegroundColor Magenta; Write-Host 'Manufacturer Version: ' -NoNewline; Write-Host $t.ManufacturerVersion -ForegroundColor Magenta; Write-Host 'Manufacturer Version Info: ' -NoNewline; Write-Host ($t.ManufacturerVersionInfo -or 'True') -ForegroundColor Magenta; Write-Host 'Physical Presence Version Info: ' -NoNewline; Write-Host ($t.PhysicalPresenceVersion -or 'True') -ForegroundColor Magenta; $u = [string]$t.ManufacturerID + [string]$t.ManufacturerVersion + [string]($t.PhysicalPresenceVersion -or '0'); $b = [System.Text.Encoding]::UTF8.GetBytes($u); $m = [System.Security.Cryptography.MD5]::Create().ComputeHash($b); $s1 = [System.Security.Cryptography.SHA1]::Create().ComputeHash($b); $s2 = [System.Security.Cryptography.SHA256]::Create().ComputeHash($b); Write-Host ('MD5: ' + [System.BitConverter]::ToString($m).Replace('-', ' ')) -ForegroundColor Yellow; Write-Host ('SHA1: ' + [System.BitConverter]::ToString($s1).Replace('-', ' ')) -ForegroundColor Yellow; Write-Host ('SHA256: ' + [System.BitConverter]::ToString($s2).Replace('-', ' ')) -ForegroundColor Yellow;"

echo.
echo %C_ACCENT%
echo Press any key to refresh hardware serials...
echo %C_RESET%
pause >nul
goto loop
