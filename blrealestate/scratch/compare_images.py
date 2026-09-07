import urllib.request, json, ssl

BASE = "https://108.181.185.27/blapis/api"
PHONE = "9416250029"
OTP = "1234"

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def req(method, path, body=None, token=None):
    r = urllib.request.Request(
        BASE + path,
        data=json.dumps(body).encode() if body else None,
        headers={"Content-Type": "application/json",
                 **({"Authorization": f"Bearer {token}"} if token else {})},
        method=method)
    with urllib.request.urlopen(r, context=ctx, timeout=15) as res:
        return json.loads(res.read())

req("POST", "/ChannelPartner/send-otp", {"mobile": PHONE})
login = req("POST", "/ChannelPartner/verify-otp", {"mobile": PHONE, "otp": OTP})
token = login.get("token") or login.get("access_token") or (login.get("data") or {}).get("token")
print(f"Auth: {'OK' if token else 'FAILED'}\n")

# List API — check what image keys come back
inv = req("GET", "/ChannelPartner/properties?per_page=500", token=token)
items = inv.get("data", {})
if isinstance(items, dict):
    items = items.get("data", [])

# Find properties that have images[] in list response
print(f"Total properties from list API: {len(items)}")
has_images_array = [p for p in items if isinstance(p.get("images"), list) and len(p["images"]) > 0]
print(f"Properties with images[] in LIST API: {len(has_images_array)}")

# Show all image-related keys from list API
all_keys = set()
for p in items:
    all_keys.update(k for k in p if "image" in k.lower())
print(f"Image keys in LIST API response: {sorted(all_keys)}\n")

# Pick first 3 properties and compare list vs detail
print("=== Comparing LIST vs DETAIL for first 3 properties ===\n")
for p in items[:3]:
    pid = p.get("id")
    list_main = p.get("main_image") or p.get("main_image_url") or p.get("image")
    list_images = p.get("images", "NOT PRESENT")

    print(f"Property id={pid}  title={p.get('title','')[:40]}")
    print(f"  LIST  main_image : {list_main}")
    print(f"  LIST  images     : {list_images}")

    try:
        detail = req("GET", f"/property/{pid}", token=token)
        d = detail.get("data", detail)
        detail_main = d.get("main_image") or d.get("main_image_url")
        detail_imgs = [i.get("image") for i in d.get("images", [])]
        print(f"  DETAIL main_image: {detail_main}")
        print(f"  DETAIL images[]  : {detail_imgs}")
        print(f"  MATCH: {list_main == detail_main}")
    except Exception as e:
        print(f"  DETAIL error: {e}")
    print()
