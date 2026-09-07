import requests
import json

BASE_URL = "http://108.181.185.27/blapis/api"
PHONE = "9416250029"
OTP = "1234"

def get_token():
    # Step 1: Send OTP
    print(f"[*] Sending OTP to {PHONE}...")
    r1 = requests.post(f"{BASE_URL}/ChannelPartner/send-otp", json={"mobile": PHONE})
    print(f"    Status: {r1.status_code}, Res: {r1.text}")
    
    # Step 2: Verify OTP
    print(f"[*] Verifying OTP...")
    r2 = requests.post(f"{BASE_URL}/ChannelPartner/verify-otp", json={
        "mobile": PHONE,
        "otp": OTP,
        "fcm_token": "audit_script_token"
    })
    print(f"    Status: {r2.status_code}")
    
    if r2.status_code == 200:
        data = r2.json()
        token = data.get("token") or data.get("access_token") or data.get("data", {}).get("token")
        if token:
            print(f"[+] SUCCESS! Token found: {token}")
            return token
    print("[-] FAILED to get token.")
    return None

if __name__ == "__main__":
    token = get_token()
    if token:
        with open("scratch/latest_token.txt", "w") as f:
            f.write(token)
