# Auto-Connect Android Wireless ADB (Pro Version + Ghost Cleaner)
Clear-Host
Write-Host "--- Network Diagnostics ---" -ForegroundColor Cyan

# 1. Show Laptop Wi-Fi IP
$laptopIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -like '*Wi-Fi*' }).IPAddress
Write-Host "Laptop Wi-Fi IP: $laptopIP" -ForegroundColor Green

Write-Host "`n--- Resetting ADB ---" -ForegroundColor Cyan
adb disconnect
adb kill-server
adb start-server

Write-Host "`nSearching for Phone (A015)..." -ForegroundColor Yellow
$found = $false
for ($i=1; $i -le 10; $i++) {
    Write-Host "Scan attempt $i/10..." -NoNewline
    $mdns = adb mdns services
    $match = $mdns | Select-String -Pattern '\b192\.168\.\d{1,3}\.\d{1,3}:\d+\b'
    
    if ($match) {
        $address = $match.Matches[-1].Value
        Write-Host " FOUND at $address" -ForegroundColor Green
        $found = $true
        break
    }
    Write-Host " ..." -ForegroundColor Gray
    Start-Sleep -Seconds 1
}

# 3. Connect and Clean Ghosts
if ($found) {
    Write-Host "Connecting..." -ForegroundColor Green
    adb connect $address
    Start-Sleep -Seconds 1
    
    # GHOST CLEANER: Disconnect the long MDNS names that cause "unsupported" errors
    $devices = adb devices
    $ghosts = $devices | Select-String -Pattern 'adb-.*?\s'
    foreach ($ghost in $ghosts) {
        $ghostID = $ghost.ToString().Trim().Split("`t")[0]
        if ($ghostID -ne $address) {
            Write-Host "Cleaning ghost: $ghostID" -ForegroundColor Gray
            adb disconnect $ghostID | Out-Null
        }
    }

    Write-Host "`nResult:" -ForegroundColor Cyan
    flutter devices
} else {
    Write-Host "`n[FAIL] Could not find phone automatically." -ForegroundColor Red
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
