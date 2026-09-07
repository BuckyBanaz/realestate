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

print(f"Total: {len(items)}\n")

# What _extractPropertyType returns (category.name first, then property_type)
def extract_type(item):
    cat = item.get("category")
    if isinstance(cat, dict) and cat.get("name"):
        return cat["name"].strip()
    raw = item.get("property_type") or item.get("type")
    if raw and str(raw).strip().lower() not in ("", "null", "none"):
        return str(raw).strip()
    return "Other"

types = Counter(extract_type(i) for i in items)
print("=== RAW property types (what Flutter _extractPropertyType returns) ===")
for k, v in sorted(types.items(), key=lambda x: -x[1]):
    print(f"  '{k}': {v}")

print("\n=== After _normalizeName (what Flutter shows in dynData) ===")
def normalize(s):
    if not s or s.lower() in ("null","none","other"): return "Other"
    lower = s.lower().strip()
    if lower in ("plot","plots"): return "Plots"
    if lower in ("farmhouse","farmhouses"): return "Farmhouses"
    if lower in ("flats-housing","flats housing","flat-housing"): return "Flats-Housing"
    if lower in ("agricultural land","agricultural"): return "Agricultural Land"
    if lower == "township": return "Township"
    if lower == "society": return "Society"
    return s[0].upper() + s[1:].lower()

normalized = Counter(normalize(extract_type(i)) for i in items)
for k, v in sorted(normalized.items(), key=lambda x: -x[1]):
    print(f"  '{k}': {v}")

print("\n=== Fixed 6 types ===")
fixed = ['Plots','Farmhouses','Flats-Housing','Agricultural Land','Township','Society']
for t in fixed:
    print(f"  '{t}': {normalized.get(t, 0)}")

print("\n=== Live types NOT in fixed list (these cause duplicates) ===")
for k in normalized:
    if k not in fixed and k != "Other":
        print(f"  '{k}': {normalized[k]}  ← DUPLICATE RISK")
