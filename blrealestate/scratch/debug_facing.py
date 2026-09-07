import urllib.request, json, ssl
from collections import Counter

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

inv = req("GET", "/ChannelPartner/properties?per_page=500", token=token)
items = inv.get("data", {})
if isinstance(items, dict): items = items.get("data", [])

print(f"Total properties: {len(items)}\n")

# All properties with Facing key
facing_props = []
for i in items:
    attrs = i.get("attributes", {})
    if isinstance(attrs, dict) and attrs.get("Facing"):
        facing_props.append(i)

print(f"Properties WITH Facing key: {len(facing_props)}")
print("-" * 50)
for i in facing_props:
    attrs = i.get("attributes", {})
    print(f"  id={i.get('id'):<5} title={str(i.get('title','')):<35} Facing={attrs.get('Facing')}")

# Summary of facing directions
print("\n=== Facing Direction Summary ===")
facing_values = [i.get("attributes", {}).get("Facing") for i in facing_props]
counts = Counter(facing_values)
for direction, count in sorted(counts.items(), key=lambda x: -x[1]):
    print(f"  {direction}: {count}")
