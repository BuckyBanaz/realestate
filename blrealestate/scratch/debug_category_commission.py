import urllib.request, json, ssl

BASE = "https://108.181.185.27/blapis/api"
PHONE = "9416250029"
OTP = "1234"

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def req(method, path, body=None, token=None):
    r = urllib.request.Request(BASE + path,
        data=json.dumps(body).encode() if body else None,
        headers={"Content-Type":"application/json", **({"Authorization":f"Bearer {token}"} if token else {})},
        method=method)
    with urllib.request.urlopen(r, context=ctx, timeout=20) as res:
        return json.loads(res.read())

req("POST", "/ChannelPartner/send-otp", {"mobile": PHONE})
login = req("POST", "/ChannelPartner/verify-otp", {"mobile": PHONE, "otp": OTP})
token = login.get("token") or login.get("access_token") or (login.get("data") or {}).get("token")
print(f"Logged in: {PHONE}\n")

# Try endpoints that might return category commission rates
endpoints = [
    "/ChannelPartner/commission-rates",
    "/ChannelPartner/category-commissions",
    "/ChannelPartner/commissions/categories",
    "/ChannelPartner/profile/commission",
    "/ChannelPartner/profile/commissions",
    "/ChannelPartner/commissions/rates",
    "/ChannelPartner/my-commissions",
    "/ChannelPartner/commission",
]

print("=== Trying endpoints for category commission ===")
for ep in endpoints:
    try:
        d = req("GET", ep, token=token)
        print(f"\n✅ {ep}")
        print(json.dumps(d, indent=2)[:300])
    except Exception as e:
        print(f"❌ {ep} → {e}")

# Also check profile for commission fields
print("\n\n=== FULL PROFILE (all fields) ===")
p = req("GET", "/ChannelPartner/profile", token=token)
print(json.dumps(p, indent=2))
