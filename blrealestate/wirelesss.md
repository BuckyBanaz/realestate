# Android Wireless Debugging Fix

If your device shows as **"unsupported"** or **"API null"** in Flutter, use this guide.

### 🚀 Fast Fix (Copy & Paste)
Run this first to reset everything:
```powershell
adb disconnect; adb kill-server; adb start-server
```

### 🔍 Current Network State
- **Laptop IP:** `192.168.31.169`
- **Phone IP:** `192.168.31.25`

### 🔍 Step 1: Find the Port
On your phone, go to **Wireless Debugging** and look for the **Port** number (the number after the colon).

### 🔗 Step 2: Connect
Replace `[PORT]` with the number you see on your phone screen:
```powershell
adb connect 192.168.31.25:[PORT]
```

### ✅ Step 3: Verify
```powershell
flutter devices
```

---

> [!TIP]
> **Why this happens:** Android's mDNS (Wireless Discovery) sometimes creates "ghost" entries or stale IDs like `adb-00121649... (2)`. This reset clears those ghosts and forces a clean connection via the IP address.


adb disconnect; 
adb kill-server; 
adb start-server
adb mdns services
adb disconnect
adb connect 192.168.31.25:46727
flutter devices


adb -s 192.168.31.25:46727 uninstall com.blrealestateapp.blrealestate


adb disconnect "adb-00121649A004747-PQqPUy (2)._adb-tls-connect._tcp"


 powershell -ExecutionPolicy Bypass -File .\fix_adb.ps1
 powershell -ExecutionPolicy Bypass -File .\fix_adb.ps1