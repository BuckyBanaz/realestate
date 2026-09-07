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

print("=== RAW property_type field (exact from backend) ===")
pt = Counter(repr(i.get("property_type")) for i in items)
for k, v in sorted(pt.items(), key=lambda x: -x[1]):
    print(f"  {k}: {v}")

print("\n=== RAW category.name field (exact from backend) ===")
cn = Counter()
for i in items:
    cat = i.get("category")
    cn[repr(cat["name"] if isinstance(cat, dict) else None)] += 1
for k, v in sorted(cn.items(), key=lambda x: -x[1]):
    print(f"  {k}: {v}")

print("\n=== RAW subcategory.name field (exact from backend) ===")
sn = Counter()
for i in items:
    sub = i.get("subcategory")
    sn[repr(sub["name"] if isinstance(sub, dict) else None)] += 1
for k, v in sorted(sn.items(), key=lambda x: -x[1]):
    print(f"  {k}: {v}")

print("\n=== RAW sub_subcategory.name field (exact from backend) ===")
ssn = Counter()
for i in items:
    ss = i.get("sub_subcategory")
    ssn[repr(ss["name"] if isinstance(ss, dict) else None)] += 1
for k, v in sorted(ssn.items(), key=lambda x: -x[1]):
    print(f"  {k}: {v}")
