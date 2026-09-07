import urllib.request, json, ssl
BASE = 'https://108.181.185.27/blapis/api'
PHONE = '9416250029'
OTP = '1234'
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def req(method, path, body=None, token=None):
    r = urllib.request.Request(BASE + path,
        data=json.dumps(body).encode() if body else None,
        headers={'Content-Type':'application/json', **({'Authorization':f'Bearer {token}'} if token else {})},
        method=method)
    with urllib.request.urlopen(r, context=ctx, timeout=20) as res:
        return json.loads(res.read())

req('POST', '/ChannelPartner/send-otp', {'mobile': PHONE})
login = req('POST', '/ChannelPartner/verify-otp', {'mobile': PHONE, 'otp': OTP})
token = login.get('token') or login.get('access_token') or (login.get('data') or {}).get('token')

p1 = req('GET', '/ChannelPartner/properties?page=1&per_page=20', token=token)
p2 = req('GET', '/ChannelPartner/properties?page=2&per_page=20', token=token)

def summarize(res):
    d = res.get('data', {})
    items = d.get('data', [])
    print(f"Total: {d.get('total')}, Current Page: {d.get('current_page')}, Last Page: {d.get('last_page')}, Items count: {len(items)}")

print('PAGE 1:')
summarize(p1)
print('PAGE 2:')
summarize(p2)
