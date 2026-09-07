import urllib.request, json, ssl
from datetime import datetime

BASE = "https://108.181.185.27/blapis/api"
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

req("POST", "/ChannelPartner/send-otp", {"mobile":"9416250029"})
login = req("POST", "/ChannelPartner/verify-otp", {"mobile":"9416250029","otp":"1234"})
token = login.get("token") or login.get("access_token") or (login.get("data") or {}).get("token")

data = req("GET", "/ChannelPartner/properties?per_page=1000", token=token)
items = data.get("data", {})
if isinstance(items, dict): items = items.get("data", [])

print(f"Total properties: {len(items)}")

held = []
for i in items:
    # Check active_hold object
    ah = i.get("active_hold")
    if ah and isinstance(ah, dict) and ah.get("status") == "active":
        hold_until = ah.get("hold_until", "")
        if hold_until:
            try:
                expiry = datetime.fromisoformat(hold_until.replace("Z",""))
                if expiry > datetime.now():
                    held.append(i)
                    continue
            except:
                held.append(i)
                continue
        else:
            held.append(i)
            continue
    # Legacy: check held_by
    if i.get("held_by") and str(i.get("held_by")) != "0":
        held.append(i)

print(f"\nTotal HELD properties: {len(held)}")
for h in held:
    ah = h.get("active_hold", {})
    print(f"  id={h['id']} title={h['title'][:40]}")
    print(f"    status={h.get('status')} held_by={h.get('held_by')}")
    print(f"    active_hold.status={ah.get('status') if ah else 'None'}")
    print(f"    active_hold.hold_until={ah.get('hold_until') if ah else 'None'}")
    print(f"    active_hold.user_id={ah.get('user_id') if ah else 'None'}")
