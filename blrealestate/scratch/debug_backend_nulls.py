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
print(f"Logged in: {PHONE}\n")

# ── 1. INVENTORY — check Facing + attributes ─────────────────────────────────
print("=" * 60)
print("1. INVENTORY — Facing & Attributes Null Check")
print("=" * 60)
inv = req("GET", "/ChannelPartner/properties?per_page=200", token=token)
items = inv.get("data", {})
if isinstance(items, dict): items = items.get("data", [])
print(f"Total properties: {len(items)}")

facing_null = 0
facing_set  = 0
attrs_null  = 0
attrs_empty = 0
attrs_has_facing = 0

for i in items:
    attrs = i.get("attributes")
    if attrs is None:
        attrs_null += 1
    elif isinstance(attrs, dict) and len(attrs) == 0:
        attrs_empty += 1
    elif isinstance(attrs, dict):
        facing = attrs.get("Facing")
        if facing:
            attrs_has_facing += 1
            facing_set += 1
        else:
            facing_null += 1
    elif isinstance(attrs, str):
        # Sometimes attributes comes as JSON string
        try:
            parsed = json.loads(attrs)
            if isinstance(parsed, dict):
                facing = parsed.get("Facing")
                if facing:
                    facing_set += 1
                else:
                    facing_null += 1
            else:
                attrs_empty += 1
        except:
            attrs_empty += 1

print(f"  attributes=null       : {attrs_null}")
print(f"  attributes=empty dict : {attrs_empty}")
print(f"  Facing key present    : {facing_set}")
print(f"  Facing key missing    : {facing_null}")

# Show sample of first 3 items with their attributes
print("\n  Sample (first 3 items):")
for i in items[:3]:
    attrs = i.get("attributes", {})
    print(f"    id={i.get('id')} title={str(i.get('title',''))[:30]}")
    print(f"      attributes type: {type(attrs).__name__}")
    if isinstance(attrs, dict):
        print(f"      attributes keys: {list(attrs.keys())[:8]}")
        print(f"      Facing value   : {attrs.get('Facing', 'NOT FOUND')}")
        print(f"      Plot Size      : {attrs.get('Plot Size', 'NOT FOUND')}")
    elif isinstance(attrs, str):
        print(f"      attributes raw : {attrs[:100]}")
    else:
        print(f"      attributes val : {attrs}")

# ── 2. COMMISSIONS — check payout_status + remarks ───────────────────────────
print("\n" + "=" * 60)
print("2. COMMISSIONS — payout_status & remarks Null Check")
print("=" * 60)
c = req("GET", "/ChannelPartner/commissions?per_page=100", token=token)
citems = c.get("data", [])
if isinstance(citems, dict): citems = citems.get("data", [])
print(f"Total commissions: {len(citems)}")

if citems:
    payout_null = sum(1 for i in citems if not i.get("payout_status"))
    remarks_null = sum(1 for i in citems if not i.get("remarks"))
    print(f"  payout_status null/empty : {payout_null}")
    print(f"  remarks null/empty       : {remarks_null}")
    print(f"\n  All entries:")
    for i in citems:
        print(f"    id={i.get('id')} payout_status={i.get('payout_status')} remarks={str(i.get('remarks',''))[:50]}")
else:
    print("  >>> 0 commissions — backend has no data for this user <<<")

# ── 3. INVENTORY DETAIL — check a specific property's full data ───────────────
print("\n" + "=" * 60)
print("3. INVENTORY DETAIL — First property full attributes")
print("=" * 60)
if items:
    first = items[0]
    print(f"  id    : {first.get('id')}")
    print(f"  title : {first.get('title')}")
    print(f"  status: {first.get('status')}")
    print(f"  price : {first.get('price')}")
    print(f"  area  : {first.get('area')}")
    attrs = first.get("attributes", {})
    print(f"  attributes ({type(attrs).__name__}):")
    if isinstance(attrs, dict):
        if attrs:
            for k, v in attrs.items():
                print(f"    {k}: {v}")
        else:
            print("    >>> EMPTY DICT — backend sends no attributes <<<")
    elif isinstance(attrs, str):
        print(f"    raw string: {attrs[:200]}")
    else:
        print(f"    value: {attrs}")
