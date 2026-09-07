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
print(f"Logged in as: {PHONE}\n")

# ── COMMISSIONS ──────────────────────────────────────────────────────────────
print("=" * 60)
print("COMMISSIONS")
print("=" * 60)
c = req("GET", "/ChannelPartner/commissions?per_page=100", token=token)
items = c.get("data", [])
if isinstance(items, dict): items = items.get("data", [])
print(f"Total commissions: {len(items)}")

if items:
    for i in items:
        print(f"\n  id            : {i.get('id')}")
        print(f"  property_id   : {i.get('property_id')}")
        print(f"  commission_amt: {i.get('commission_amount')}")
        print(f"  commission_%  : {i.get('commission_percentage')}")
        print(f"  commission_type: {i.get('commission_type')}")
        print(f"  status        : {i.get('status')}")
        print(f"  payout_status : {i.get('payout_status')}")
        print(f"  remarks       : {i.get('remarks')}")
        print(f"  earned_amount : {i.get('earned_amount')}")
        print(f"  paid_amount   : {i.get('paid_amount')}")
else:
    print("  >>> NO COMMISSION ENTRIES FOUND <<<")
    print("  This user has 0 commissions — hold button will show 'Not Authorized'")
    print("  Ask backend dev to assign commission to this channel partner")
