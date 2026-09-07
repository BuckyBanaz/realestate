import urllib.request, json, ssl

BASE  = "https://108.181.185.27/blapis/api"
PHONE = "9416250029"
OTP   = "1234"

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
    with urllib.request.urlopen(r, context=ctx, timeout=20) as res:
        return json.loads(res.read())

# Auth
req("POST", "/ChannelPartner/send-otp", {"mobile": PHONE})
login = req("POST", "/ChannelPartner/verify-otp", {"mobile": PHONE, "otp": OTP})
token = (login.get("token") or login.get("access_token")
         or (login.get("data") or {}).get("token"))
print(f"Auth: {'OK' if token else 'FAILED'}\n")

# Fetch inventory
inv   = req("GET", "/ChannelPartner/properties?per_page=500", token=token)
items = inv.get("data", {})
if isinstance(items, dict):
    items = items.get("data", [])
print(f"Total properties: {len(items)}\n")

# Discover all image-related keys
img_keys = sorted({k for i in items for k in i if "image" in k.lower() or "photo" in k.lower() or "gallery" in k.lower()})
print(f"Image-related keys in response: {img_keys}\n")

# Show raw image fields for first 3 items
print("=== Sample (first 3 items) ===")
for item in items[:3]:
    print(f"  id={item.get('id')} title={item.get('title')}")
    for k in img_keys:
        if k in item:
            print(f"    {k}: {item[k]}")
print()

# Find plots with multiple images
multi = []
for item in items:
    for k in img_keys:
        val = item.get(k)
        if isinstance(val, list) and len(val) > 1:
            multi.append({"id": item.get("id"), "title": item.get("title"), "key": k, "count": len(val), "values": val})
            break

if multi:
    print(f"=== Plots with MULTIPLE images ({len(multi)}) ===")
    for p in multi:
        print(f"  id={p['id']} | {p['title']} | key='{p['key']}' | count={p['count']}")
        for v in p["values"]:
            print(f"    - {v}")
else:
    print("No plots found with multiple images in any array field.")
