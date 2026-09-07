import urllib.request, json, ssl

BASE  = "https://108.181.185.27/blapis/api"
PHONE = "9416250029"
OTP   = "1234"

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode    = ssl.CERT_NONE

def req(method, path, body=None, token=None):
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    r = urllib.request.Request(
        BASE + path,
        data=json.dumps(body).encode() if body else None,
        headers=headers,
        method=method,
    )
    with urllib.request.urlopen(r, context=ctx, timeout=20) as res:
        return json.loads(res.read())

# ── Step 1: send OTP ─────────────────────────────────────────────────────────
print("=" * 60)
print("STEP 1 — POST /ChannelPartner/send-otp")
print("=" * 60)
r1 = req("POST", "/ChannelPartner/send-otp", {"mobile": PHONE})
print(json.dumps(r1, indent=2))

# ── Step 2: verify OTP ───────────────────────────────────────────────────────
print("\n" + "=" * 60)
print("STEP 2 — POST /ChannelPartner/verify-otp")
print("=" * 60)
r2 = req("POST", "/ChannelPartner/verify-otp", {"mobile": PHONE, "otp": OTP})
print(json.dumps(r2, indent=2))

# ── Step 3: check which key holds the token ──────────────────────────────────
print("\n" + "=" * 60)
print("STEP 3 — Token key detection")
print("=" * 60)
candidates = [
    r2.get("token"),
    r2.get("access_token"),
    (r2.get("data") or {}).get("token"),
    (r2.get("data") or {}).get("access_token"),
]
print(f"  r2['token']              = {r2.get('token')}")
print(f"  r2['access_token']       = {r2.get('access_token')}")
print(f"  r2['data']['token']      = {(r2.get('data') or {}).get('token')}")
print(f"  r2['data']['access_token']= {(r2.get('data') or {}).get('access_token')}")
found = next((c for c in candidates if c), None)
print(f"\n  Flutter would extract: {found[:30] + '...' if found and len(str(found)) > 30 else found}")
if not found:
    print("\n  *** NO TOKEN FOUND — Flutter verifyOtp() returns false ***")
    print("  *** User sees 'Invalid PIN' even though OTP is correct ***")
    print(f"\n  Full r2 keys: {list(r2.keys())}")
    if isinstance(r2.get("data"), dict):
        print(f"  r2['data'] keys: {list(r2['data'].keys())}")
