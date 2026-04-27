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
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$os=Get-CimInstance Win32_OperatingSystem; $reg=Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'; $ver=$reg.DisplayVersion; $ubr=$reg.UBR; $build=$os.Version.Split('.')[-1]; $sw=if($os.Caption -like '*11*'){'W11'}else{'W10'}; $ed=if($os.Caption -like '*Pro*'){'PRO'}elseif($os.Caption -like '*Home*'){'HOME'}else{'OS'}; $fV=($sw+' '+$ver+' '+$ed+' '+$build+'.'+$ubr); $oem=(Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey; $rk=(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform' -ErrorAction SilentlyContinue).BackupProductKeyDefault; $key=if($oem){$oem}elseif($rk){$rk}else{'Digital License / Not Found'}; $lic=Get-CimInstance SoftwareLicensingProduct -ErrorAction SilentlyContinue | Where-Object { $_.PartialProductKey -and $_.Name -like '*Windows*' } | Select-Object -First 1; $activated=($lic -and $lic.LicenseStatus -eq 1); Write-Host 'Device Name: ' -NoNewline; Write-Host $env:COMPUTERNAME -ForegroundColor Magenta; Write-Host ' | Version: ' -NoNewline; Write-Host $fV -ForegroundColor Magenta; Write-Host ' | Activation: ' -NoNewline; Write-Host $key -NoNewline -ForegroundColor Magenta; Write-Host ' | Status: ' -NoNewline -ForegroundColor DarkGray; if($activated){Write-Host 'ACTIVATED' -ForegroundColor Green}else{Write-Host 'NOT ACTIVATED' -ForegroundColor Red}; $hvci=(Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard).VirtualizationBasedSecurityStatus; Write-Host 'Core Isolation: ' -NoNewline; if($hvci -eq 2){Write-Host 'ON' -ForegroundColor Green}else{Write-Host 'OFF' -ForegroundColor Red}; $guid=(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Cryptography').MachineGuid; Write-Host ' | Machine GUID: ' -NoNewline; Write-Host $guid -ForegroundColor Magenta; $sid=([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value; Write-Host 'User Account SID: ' -NoNewline; Write-Host $sid -ForegroundColor Magenta"
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$cv=Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'; $wu=Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate' -ErrorAction SilentlyContinue; $profileGuid=(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileGuid' -ErrorAction SilentlyContinue).Guid; Write-Host 'Product ID: ' -NoNewline; Write-Host $cv.ProductId -NoNewline -ForegroundColor Magenta; Write-Host ' | Install Date: ' -NoNewline -ForegroundColor DarkGray; Write-Host ([DateTimeOffset]::FromUnixTimeSeconds([int64]$cv.InstallDate).LocalDateTime) -NoNewline -ForegroundColor Magenta; Write-Host ' | BuildLabEx: ' -NoNewline -ForegroundColor DarkGray; Write-Host $cv.BuildLabEx -ForegroundColor Magenta; Write-Host 'Profile GUID: ' -NoNewline; Write-Host ($(if($profileGuid){$profileGuid}else{'N/A'})) -NoNewline -ForegroundColor Magenta; Write-Host ' | SusClientId: ' -NoNewline -ForegroundColor DarkGray; Write-Host ($(if($wu.SusClientId){$wu.SusClientId}else{'N/A'})) -ForegroundColor Magenta"

echo.
echo %C_TITLE%
echo            [ ADVANCED HARDWARE IDS ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$hw=(Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\IDConfigDB\Hardware Profiles\0001' -ErrorAction SilentlyContinue).HwProfileGuid; Write-Host 'HwProfileGuid: ' -NoNewline; Write-Host ($(if($hw){$hw}else{'N/A'})) -ForegroundColor Magenta"


echo.
echo %C_TITLE%
echo            [ MONITOR INFO ^& FUSER DETECTION ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$v = Get-CimInstance Win32_VideoController | Select-Object -First 1; Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID -ErrorAction SilentlyContinue | ForEach-Object { $m = $_; $n = [System.Text.Encoding]::ASCII.GetString(($m.UserFriendlyName | Where-Object{$_ -ne 0})).Trim(); $id = $m.InstanceName; $sp = [System.Text.Encoding]::ASCII.GetString(($m.ProductCodeID | Where-Object{$_ -ne 0})).Trim(); $s_edid = ([System.Text.Encoding]::ASCII.GetString($m.SerialNumberID) -replace '\0','').Trim(); $rp = \"HKLM:\SYSTEM\CurrentControlSet\Enum\$id\Device Parameters\"; $dna = 'N/A'; $em = 1; if(Test-Path $rp){ $ed = (Get-ItemProperty -Path $rp -ErrorAction SilentlyContinue).EDID; if($ed){ $fh = [System.BitConverter]::ToString($ed).Replace('-',''); $dna = if($fh.Length -ge 32){$fh.Substring(22,8)}else{$fh}; $em = 0; } }; if(-not $s_edid){$s_edid='0'}; Write-Host 'Name: ' -NoNewline; Write-Host $n -NoNewline -ForegroundColor Magenta; Write-Host ' | Instance ID: ' -NoNewline -ForegroundColor DarkGray; Write-Host $id -NoNewline -ForegroundColor Magenta; Write-Host ' | DNA: ' -NoNewline -ForegroundColor DarkGray; Write-Host $dna -NoNewline -ForegroundColor Magenta; Write-Host ' | Product ID: ' -NoNewline -ForegroundColor DarkGray; Write-Host $sp -NoNewline -ForegroundColor Magenta; Write-Host ' | EDID Serial: ' -NoNewline -ForegroundColor DarkGray; Write-Host $s_edid -NoNewline -ForegroundColor Magenta; Write-Host ' | Emulated: ' -NoNewline -ForegroundColor DarkGray; if($em -eq 1){Write-Host 'YES' -ForegroundColor Red}else{Write-Host 'NO' -ForegroundColor Green} }; Write-Host 'Resolution: ' -NoNewline; Write-Host ($v.CurrentHorizontalResolution.ToString() + ' x ' + $v.CurrentVerticalResolution.ToString()) -NoNewline -ForegroundColor Magenta; Write-Host ' | Refresh Rate: ' -NoNewline -ForegroundColor DarkGray; Write-Host ($v.CurrentRefreshRate.ToString() + ' Hz') -ForegroundColor Magenta;"

echo.
echo %C_TITLE%
echo           [ INTEGRITY / FUSER CHECK ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$v=@('AOC2703','AOC3403','AUS2704','HKC2520','MSI5CA9','SAC2942'); $m = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY' -ErrorAction SilentlyContinue | ForEach-Object { $p=$_.Name; foreach($vid in $v){ if($p -like \"*$vid*\"){ $p } } }; $rCount = if($m){ ($m | Measure-Object).Count } else { 0 }; $ddc = Get-WmiObject -Namespace root\WMI -Class WmiMonitorBrightnessMethods -ErrorAction SilentlyContinue; $as = if (-not $ddc) { 1 } else { 0 }; $score=$rCount+$as; Write-Host 'Registry Hits: ' -NoNewline; if($rCount -gt 0){Write-Host $rCount -NoNewline -ForegroundColor Red}else{Write-Host $rCount -NoNewline -ForegroundColor Green}; Write-Host ' | DDC/CI: ' -NoNewline -ForegroundColor DarkGray; if($as -eq 1){ Write-Host 'FAILED' -NoNewline -ForegroundColor Yellow } else { Write-Host 'OK' -NoNewline -ForegroundColor Green }; Write-Host ' | Suspicion Level: ' -NoNewline -ForegroundColor DarkGray; Write-Host $score -NoNewline -ForegroundColor Magenta; Write-Host ' | STATUS: ' -NoNewline -ForegroundColor DarkGray; if($score -gt 1){ Write-Host 'HIGHLY SUSPICIOUS' -ForegroundColor Red } elseif($score -gt 0){ Write-Host 'ATTENTION REQUIRED' -ForegroundColor Yellow } else { Write-Host 'CLEAN' -ForegroundColor Green }; if($rCount -gt 0){ $m | ForEach-Object { Write-Host '>> Registry: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_ -ForegroundColor Red } }; if($as -eq 1){ Write-Host '>> Reason: ' -NoNewline -ForegroundColor DarkGray; Write-Host 'Brightness handshaking (DDC/CI) failed on current monitor.' -ForegroundColor Yellow }"

echo.
echo %C_TITLE%
echo           [ DISK DRIVES / STORAGE (MAPPED VOLUMES) ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_DiskDrive | ForEach-Object { $d=$_; $p=Get-PhysicalDisk | Where-Object {$_.SerialNumber -eq $d.SerialNumber}; Write-Host 'Model: ' -NoNewline; Write-Host $d.Model -NoNewline -ForegroundColor Magenta; Write-Host ' | Serial: ' -NoNewline -ForegroundColor DarkGray; Write-Host $d.SerialNumber -NoNewline -ForegroundColor Magenta; Write-Host ' | Firmware: ' -NoNewline -ForegroundColor DarkGray; Write-Host $d.FirmwareRevision -NoNewline -ForegroundColor Magenta; if($p){Write-Host ' | UUID: ' -NoNewline -ForegroundColor DarkGray; Write-Host $p.UniqueId -NoNewline -ForegroundColor Magenta}; Write-Host ''; Get-CimAssociatedInstance -InputObject $d -Association Win32_DiskDriveToDiskPartition | ForEach-Object { Get-CimAssociatedInstance -InputObject $_ -Association Win32_LogicalDiskToPartition | ForEach-Object { Write-Host '>> Volume ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.DeviceID -NoNewline -ForegroundColor Cyan; Write-Host ' | Serial: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.VolumeSerialNumber -ForegroundColor Cyan } } }"

echo.
echo %C_TITLE%
echo           [ DISK S.M.A.R.T. / RELIABILITY ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$pd=Get-PhysicalDisk -ErrorAction SilentlyContinue; if(-not $pd){Write-Host 'S.M.A.R.T. data: N/A' -ForegroundColor Gray}else{$pd | ForEach-Object { $d=$_; $r=$null; try{$r=$d | Get-StorageReliabilityCounter -ErrorAction Stop}catch{}; Write-Host 'Disk: ' -NoNewline; Write-Host $d.FriendlyName -NoNewline -ForegroundColor Magenta; Write-Host ' | Serial: ' -NoNewline -ForegroundColor DarkGray; Write-Host $d.SerialNumber -NoNewline -ForegroundColor Magenta; Write-Host ' | Health: ' -NoNewline -ForegroundColor DarkGray; Write-Host $d.HealthStatus -NoNewline -ForegroundColor $(if($d.HealthStatus -eq 'Healthy'){'Green'}else{'Yellow'}); Write-Host ' | PowerOnHours: ' -NoNewline -ForegroundColor DarkGray; Write-Host ($(if($r -and $null -ne $r.PowerOnHours){$r.PowerOnHours}else{'N/A'})) -NoNewline -ForegroundColor Magenta; Write-Host ' | StartStopCount: ' -NoNewline -ForegroundColor DarkGray; Write-Host ($(if($r -and $null -ne $r.StartStopCycleCount){$r.StartStopCycleCount}else{'N/A'})) -NoNewline -ForegroundColor Magenta; Write-Host ' | Wear: ' -NoNewline -ForegroundColor DarkGray; Write-Host ($(if($r -and $null -ne $r.Wear){$r.Wear}else{'N/A'})) -ForegroundColor Magenta }}"

echo.
echo %C_TITLE%
echo           [ VOLUME GUIDS / MOUNT POINTS ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Volume | Where-Object { $_.DriveLetter } | Sort-Object DriveLetter | ForEach-Object { Write-Host 'Volume: ' -NoNewline; Write-Host $_.DriveLetter -NoNewline -ForegroundColor Cyan; Write-Host ' | GUID: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.DeviceID -NoNewline -ForegroundColor Magenta; Write-Host ' | Serial: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.SerialNumber -NoNewline -ForegroundColor Magenta; Write-Host ' | Label: ' -NoNewline -ForegroundColor DarkGray; Write-Host ($(if($_.Label){$_.Label}else{'N/A'})) -ForegroundColor Yellow }"

echo.
echo %C_TITLE%
echo            [ NETWORK / IP ADDRESS ^& FINGERPRINT ]
echo %C_RESET%
echo %C_TEXT%Active Network Adapters (MAC List):%C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.MACAddress -and $_.PhysicalAdapter -and $_.Description -notmatch 'WAN Miniport|Bluetooth Device|Virtual|VPN|Loopback' } | ForEach-Object { Write-Host 'Adapter: ' -NoNewline; Write-Host $_.Description -NoNewline -ForegroundColor White; Write-Host ' | MAC: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.MACAddress -NoNewline -ForegroundColor Magenta; Write-Host ' | PNP ID: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.PNPDeviceID -ForegroundColor Magenta }"
echo.
echo %C_TEXT%Gateway Fingerprint (Router):%C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$route=Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Sort-Object RouteMetric | Select-Object -First 1; $gwIp=if($route){$route.NextHop}else{$null}; $gw=if($gwIp){Get-NetNeighbor -IPAddress $gwIp -ErrorAction SilentlyContinue | Select-Object -First 1}else{$null}; if($gw){ Write-Host 'Gateway IP: ' -NoNewline; Write-Host $gw.IPAddress -NoNewline -ForegroundColor White; Write-Host ' | Gateway MAC: ' -NoNewline -ForegroundColor DarkGray; Write-Host $gw.LinkLayerAddress -ForegroundColor Magenta } elseif($gwIp){ Write-Host 'Gateway IP: ' -NoNewline; Write-Host $gwIp -NoNewline -ForegroundColor White; Write-Host ' | Gateway MAC: N/A' -ForegroundColor Yellow } else { Write-Host 'Gateway: Not Found' -ForegroundColor Red }"
echo.
powershell -NoLogo -Command "$ip = (Invoke-RestMethod -Uri 'https://api.ipify.org'); $rev = try { [System.Net.Dns]::GetHostEntry($ip).HostName } catch { 'N/A' }; Write-Host 'Public IP: ' -NoNewline; Write-Host $ip -NoNewline -ForegroundColor Magenta; Write-Host ' | Reverse DNS: ' -NoNewline -ForegroundColor DarkGray; Write-Host $rev -ForegroundColor Magenta"

echo.
echo %C_TEXT%Local ARP / Wi-Fi Fingerprint:%C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$arp=Get-NetNeighbor -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.LinkLayerAddress -and $_.LinkLayerAddress -notmatch '00-00-00-00-00-00|ff-ff-ff-ff-ff-ff' -and $_.State -ne 'Permanent' } | Select-Object -First 8; if($arp){$arp | ForEach-Object { Write-Host 'ARP IP: ' -NoNewline; Write-Host $_.IPAddress -NoNewline -ForegroundColor Magenta; Write-Host ' | MAC: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.LinkLayerAddress -NoNewline -ForegroundColor Magenta; Write-Host ' | State: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.State -ForegroundColor Yellow }}else{Write-Host 'ARP entries: N/A' -ForegroundColor Gray}; $wifi=(netsh wlan show interfaces) 2>$null; $bssidMatch=$wifi | Select-String '^\s*BSSID\s*:' | Select-Object -First 1; $ssidMatch=$wifi | Select-String '^\s*SSID\s*:' | Select-Object -First 1; if($bssidMatch){ $bssid=$bssidMatch.ToString(); $ssid=if($ssidMatch){($ssidMatch.ToString() -split ':',2)[1].Trim()}else{'N/A'}; Write-Host 'Wi-Fi SSID: ' -NoNewline; Write-Host $ssid -NoNewline -ForegroundColor Magenta; Write-Host ' | BSSID: ' -NoNewline -ForegroundColor DarkGray; Write-Host (($bssid -split ':',2)[1].Trim()) -ForegroundColor Magenta } else { Write-Host 'Wi-Fi BSSID: N/A' -ForegroundColor Gray }"

echo.
echo %C_TITLE%
echo            [ PERIPHERALS / USB DEVICES ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "function Short([string]$s,[int]$n){ if([string]::IsNullOrWhiteSpace($s)){return 'N/A'}; if($s.Length -gt $n){return $s.Substring(0,$n-3)+'...'}; return $s }; $roots=@('HKLM:\SYSTEM\CurrentControlSet\Enum\USB','HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR'); $items=foreach($root in $roots){ if(Test-Path $root){ Get-ChildItem $root -ErrorAction SilentlyContinue | ForEach-Object { $deviceKey=$_.PSChildName; Get-ChildItem $_.PSPath -ErrorAction SilentlyContinue | ForEach-Object { $p=Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue; $desc=if($p.DeviceDesc){($p.DeviceDesc -split ';')[-1]}else{$deviceKey}; $name=if($p.FriendlyName){$p.FriendlyName}elseif($p.LocationInformation){$p.LocationInformation}else{$desc}; $class=if($p.Class){$p.Class}else{'Unknown'}; $probe=($desc + ' ' + $name + ' ' + $class + ' ' + $root); $type=if($probe -match 'HID|USB Input|Keyboard|Mouse'){'HID'}elseif($probe -match 'Mass Storage|Disk drive|USBSTOR'){'Mass Storage'}elseif($probe -match 'Audio'){'Audio'}elseif($probe -match 'WinUsb|Vendor'){'Vendor Specific'}elseif($probe -match 'Hub|Composite'){'Hub/Composite'}elseif($class -ne 'Unknown'){$class}else{'Unknown'}; [pscustomobject]@{Name=$name;Description=$desc;Type=$type;Serial=$_.PSChildName} } } } }; $items=@($items | Where-Object { $_.Type -ne 'HID' -or $_.Name -notmatch '^0000\.' } | Sort-Object Name,Description,Serial -Unique); if($items.Count -eq 0){ Write-Host 'No USB devices found.' -ForegroundColor Red } else { $items | Select-Object -First 14 | ForEach-Object { Write-Host (Short $_.Name 28) -NoNewline -ForegroundColor Magenta; Write-Host ' | ' -NoNewline -ForegroundColor DarkGray; Write-Host (Short $_.Type 16) -NoNewline -ForegroundColor Yellow; Write-Host ' | Serial: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.Serial -ForegroundColor Magenta }; if($items.Count -gt 14){ Write-Host ('>> Hidden USB entries: ' + ($items.Count-14) + ' low-signal items') -ForegroundColor DarkGray } }"

echo.
echo %C_TITLE%
echo            [ BLUETOOTH / WIRELESS IDS ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$bt=Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue; if(-not $bt){Write-Host 'Bluetooth devices: N/A' -ForegroundColor Gray}else{$bt | ForEach-Object { Write-Host 'Name: ' -NoNewline; Write-Host $_.FriendlyName -NoNewline -ForegroundColor Magenta; Write-Host ' | Status: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.Status -NoNewline -ForegroundColor Yellow; Write-Host ' | Instance ID: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.InstanceId -ForegroundColor Magenta }}"

echo.
echo %C_TITLE%
echo            [ MEDIA / CAMERA / AUDIO IDS ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$dev=Get-PnpDevice -Class Media,Camera,Image -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -and $_.InstanceId -notlike 'SW\*' }; if(-not $dev){Write-Host 'Media devices: N/A' -ForegroundColor Gray}else{$dev | Select-Object -First 8 | ForEach-Object { Write-Host 'Name: ' -NoNewline; Write-Host $_.FriendlyName -NoNewline -ForegroundColor Magenta; Write-Host ' | Class: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.Class -NoNewline -ForegroundColor Yellow; Write-Host ' | Instance ID: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.InstanceId -ForegroundColor Magenta }; if($dev.Count -gt 8){ Write-Host ('>> Hidden media entries: ' + ($dev.Count-8)) -ForegroundColor DarkGray }}"

echo.
echo %C_TITLE%
echo            [ PCI / CONTROLLER FINGERPRINTS ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$classes=@('USB','SCSIAdapter','Net','HDC'); $dev=Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue | Where-Object { $classes -contains $_.Class -and $_.InstanceId -like 'PCI\*' } | Sort-Object Class,FriendlyName; if(-not $dev){Write-Host 'PCI controllers: N/A' -ForegroundColor Gray}else{$dev | ForEach-Object { Write-Host 'Class: ' -NoNewline; Write-Host $_.Class -NoNewline -ForegroundColor Yellow; Write-Host ' | Name: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.FriendlyName -NoNewline -ForegroundColor Magenta; Write-Host ' | Instance ID: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.InstanceId -ForegroundColor Magenta }}"

echo.
echo %C_TITLE%
echo           [ CPU INFO ]
echo %C_RESET%
powershell -NoLogo -Command "Get-CimInstance Win32_Processor | ForEach-Object { Write-Host 'Name: ' -NoNewline; Write-Host $_.Name -ForegroundColor Magenta; Write-Host ' | ID: ' -NoNewline; Write-Host $_.ProcessorId -ForegroundColor Magenta }"

echo.
echo %C_TITLE%
echo          [ PHYSICAL RAM ]
echo %C_RESET%
powershell -NoLogo -Command "Get-CimInstance Win32_PhysicalMemory | ForEach-Object { Write-Host 'Manufacturer: ' -NoNewline; Write-Host $_.Manufacturer -NoNewline -ForegroundColor Magenta; Write-Host ' | Serial: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.SerialNumber -NoNewline -ForegroundColor Magenta; Write-Host ' | Asset Tag: ' -NoNewline -ForegroundColor DarkGray; Write-Host $_.Tag -ForegroundColor Magenta }"

echo.
echo %C_TITLE%
echo          [ GPU / VIDEO CARD ]
echo %C_RESET%
powershell -NoLogo -Command "Get-CimInstance Win32_VideoController | ForEach-Object { Write-Host 'Name: ' -NoNewline; Write-Host $_.Name -ForegroundColor Magenta; Write-Host ' | PNP Device ID: ' -NoNewline; Write-Host $_.PNPDeviceID -ForegroundColor Magenta }"
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$smi=(Get-Command nvidia-smi.exe -ErrorAction SilentlyContinue).Source; if(-not $smi){$try='C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe'; if(Test-Path $try){$smi=$try}}; if($smi){$out=& $smi -L 2>$null; if($out){$out | ForEach-Object { Write-Host 'NVIDIA UUID: ' -NoNewline; Write-Host $_ -ForegroundColor Magenta }}else{Write-Host 'NVIDIA UUID: N/A' -ForegroundColor Gray}}else{Write-Host 'GPU UUID: N/A (nvidia-smi not found)' -ForegroundColor Gray}"

echo.
echo %C_TITLE%
echo           [ SECURITY / TPM ]
echo %C_RESET%
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$t = Get-Tpm; if($t.TpmPresent -and $t.TpmEnabled){Write-Host 'TPM ENABLED' -ForegroundColor Green}else{Write-Host 'TPM DISABLED' -ForegroundColor Red; return}; $ek = Get-TpmEndorsementKeyInfo -HashAlgorithm sha256 -ErrorAction SilentlyContinue; if($ek){ Write-Host 'PublicKeyHash : ' -NoNewline; Write-Host $ek.PublicKeyHash -ForegroundColor Magenta; $cert = $ek.ManufacturerCertificates[0]; if($cert){ Write-Host 'Certificate: ' -NoNewline; Write-Host $cert.Subject -NoNewline -ForegroundColor Magenta; Write-Host ' | Serial Number: ' -NoNewline -ForegroundColor DarkGray; Write-Host $cert.SerialNumber -NoNewline -ForegroundColor Magenta; Write-Host ' | Thumbprint: ' -NoNewline -ForegroundColor DarkGray; Write-Host $cert.Thumbprint -ForegroundColor Magenta; }; $hexPub = $ek.PublicKey.Format($true).Replace(' ', ''); $pubBytes = [byte[]]::new($hexPub.Length / 2); for($i = 0; $i -lt $hexPub.Length; $i += 2){ $pubBytes[$i / 2] = [Convert]::ToByte($hexPub.Substring($i, 2), 16) }; $md5 = [System.BitConverter]::ToString((New-Object System.Security.Cryptography.MD5CryptoServiceProvider).ComputeHash($pubBytes)).Replace('-', '').ToLower(); $sha1 = [System.BitConverter]::ToString((New-Object System.Security.Cryptography.SHA1CryptoServiceProvider).ComputeHash($pubBytes)).Replace('-', '').ToLower(); $sha256 = [System.BitConverter]::ToString((New-Object System.Security.Cryptography.SHA256CryptoServiceProvider).ComputeHash($pubBytes)).Replace('-', '').ToLower(); Write-Host 'MD5    : ' -NoNewline; Write-Host $md5 -ForegroundColor Magenta; Write-Host 'SHA1   : ' -NoNewline; Write-Host $sha1 -ForegroundColor Magenta; Write-Host 'SHA256 : ' -NoNewline; Write-Host $sha256 -ForegroundColor Magenta; } Write-Host 'Manufacturer ID: ' -NoNewline; Write-Host $t.ManufacturerID -NoNewline -ForegroundColor Magenta; Write-Host ' | Manufacturer Version: ' -NoNewline -ForegroundColor DarkGray; Write-Host $t.ManufacturerVersion -NoNewline -ForegroundColor Magenta; Write-Host ' | Physical Presence: ' -NoNewline -ForegroundColor DarkGray; Write-Host ($t.PhysicalPresenceVersion -or 'True') -ForegroundColor Magenta;"

echo.
echo %C_ACCENT%
echo F5 TO REFRESH SERIAL
echo CTRL C TO COPY SERIALS
echo CTRL + F5 TO SAVE SERIAL FILE ON DESKTOP
echo %C_RESET%

:waitAction
set "ACTION="
for /f "delims=" %%k in ('powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "[Console]::TreatControlCAsInput=$true; $k=$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'); $ctrl=($k.ControlKeyState.ToString() -match 'LeftCtrlPressed|RightCtrlPressed'); if($k.VirtualKeyCode -eq 116 -and $ctrl){'SAVE'} elseif($k.VirtualKeyCode -eq 116){'REFRESH'} elseif(($k.Character -eq [char]3) -or ($k.VirtualKeyCode -eq 67 -and $ctrl)){'COPY'} else {'WAIT'}"') do set "ACTION=%%k"
if /I "%ACTION%"=="REFRESH" goto loop
if /I "%ACTION%"=="COPY" (
    call :CopyConsoleBuffer
    goto waitAction
)
if /I "%ACTION%"=="SAVE" (
    call :SaveConsoleBuffer
    goto waitAction
)
goto waitAction

:CopyConsoleBuffer
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$raw=$Host.UI.RawUI; $width=$raw.BufferSize.Width; $bottom=$raw.CursorPosition.Y; $rect=New-Object System.Management.Automation.Host.Rectangle 0,0,($width-1),$bottom; $cells=$raw.GetBufferContents($rect); $lines=for($y=0;$y -le $bottom;$y++){ $chars=for($x=0;$x -lt $width;$x++){ $cells[$y,$x].Character }; (-join $chars).TrimEnd() }; $text=($lines -join [Environment]::NewLine).TrimEnd(); Set-Clipboard -Value $text"
echo %C_ACCENT%Serials copied to clipboard.%C_RESET%
exit /b

:SaveConsoleBuffer
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$desktop=[Environment]::GetFolderPath('DesktopDirectory'); $folder=Join-Path $desktop 'Serials from HWID CHECKER'; if(-not (Test-Path $folder)){ New-Item -ItemType Directory -Path $folder | Out-Null }; $file=Join-Path $folder ('hwid lobinho checker - ' + (Get-Date -Format 'yyyy-MM-dd-HHmmss') + '.txt'); $raw=$Host.UI.RawUI; $width=$raw.BufferSize.Width; $bottom=$raw.CursorPosition.Y; $rect=New-Object System.Management.Automation.Host.Rectangle 0,0,($width-1),$bottom; $cells=$raw.GetBufferContents($rect); $lines=for($y=0;$y -le $bottom;$y++){ $chars=for($x=0;$x -lt $width;$x++){ $cells[$y,$x].Character }; (-join $chars).TrimEnd() }; $text=($lines -join [Environment]::NewLine).TrimEnd(); Set-Content -LiteralPath $file -Value $text -Encoding UTF8; Write-Host ('Serial file saved: ' + $file) -ForegroundColor Green"
exit /b
