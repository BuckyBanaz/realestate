import urllib.request, json, ssl

BASE  = "https://108.181.185.27/blapis/api"
PHONE = "9416250029"
OTP   = "1234"
TEST_ID = 359  # property we know has images

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode    = ssl.CERT_NONE

def req(method, path, body=None, token=None):
    r = urllib.request.Request(
        BASE + path,
        data=json.dumps(body).encode() if body else None,
        headers={
            "Content-Type": "application/json",
            **({"Authorization": f"Bearer {token}"} if token else {}),
        },
        method=method,
    )
    try:
        with urllib.request.urlopen(r, context=ctx, timeout=10) as res:
            return res.status, json.loads(res.read())
    except urllib.error.HTTPError as e:
        return e.code, {}

# Auth
req("POST", "/ChannelPartner/send-otp", {"mobile": PHONE})
_, login = req("POST", "/ChannelPartner/verify-otp", {"mobile": PHONE, "otp": OTP})
token = (login.get("token") or login.get("access_token")
         or (login.get("data") or {}).get("token"))
print(f"Auth: {'OK' if token else 'FAILED'}\n")

# Probe candidate routes
candidates = [
    f"/ChannelPartner/properties/{TEST_ID}",
    f"/ChannelPartner/property/{TEST_ID}",
    f"/ChannelPartner/properties/{TEST_ID}/detail",
    f"/ChannelPartner/properties/{TEST_ID}/images",
    f"/ChannelPartner/properties/{TEST_ID}/gallery",
    f"/ChannelPartner/properties?id={TEST_ID}",
    f"/ChannelPartner/properties?property_id={TEST_ID}",
    f"/properties/{TEST_ID}",
    f"/property/{TEST_ID}",
]

print(f"Probing routes for property id={TEST_ID}:\n")
for path in candidates:
    status, data = req("GET", path, token=token)
    has_images = "images" in str(data)
    print(f"  {status}  {path}  {'✅ has images' if has_images else ''}")
