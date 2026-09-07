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

print("=== NOTIFICATIONS ===")
d = req("GET", "/ChannelPartner/notifications?per_page=50", token=token)
items = d.get("data", [])
if isinstance(items, dict): items = items.get("data", [])
print(f"Total: {len(items)}")
for i in items:
    print(f"  id={i.get('id')} title={i.get('title')} body={str(i.get('body',''))[:50]} is_read={i.get('is_read')} type={i.get('type')} created={str(i.get('created_at',''))[:10]}")

print("\n=== FCM TOKEN IN PROFILE ===")
p = req("GET", "/ChannelPartner/profile", token=token)
data = p.get("data", {})
fcm = data.get("fcm_token", "NOT FOUND")
print(f"  Stored FCM: {fcm[:60]}..." if fcm and len(str(fcm)) > 60 else f"  Stored FCM: {fcm}")
