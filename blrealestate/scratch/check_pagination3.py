import urllib.request, json, ssl
BASE = 'https://hisarpropertybazar.com/blapis/api'
token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2hpc2FycHJvcGVydHliYXphci5jb20vYmxhcGlzL2FwaS9DaGFubmVsUGFydG5lci92ZXJpZnktb3RwIiwiaWF0IjoxNzg4MzU2MDgyLCJleHAiOjIxMDM3MTYwODIsIm5iZiI6MTc4ODM1NjA4MiwianRpIjoiMjg3blh6RnRoME5hbmltVCIsInN1YiI6Ijc3IiwicHJ2IjoiMjNiZDVjODk0OWY2MDBhZGIzOWU3MDFjNDAwODcyZGI3YTU5NzZmNyJ9.XyJbkiSX-euVfj-FGYzDCVIuS5s6pWQRDiqs0tTZkYo'

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def req(path):
    r = urllib.request.Request(BASE + path, headers={'Authorization':f'Bearer {token}'})
    with urllib.request.urlopen(r, context=ctx, timeout=20) as res:
        return json.loads(res.read())

print("PAGE 1 WITH CATEGORY COMMERCIAL:")
p1 = req('/ChannelPartner/properties?page=1&per_page=20&category=Commercial')
print(f"Total: {p1.get('data', {}).get('total')}, Page: {p1.get('data', {}).get('current_page')}, Last: {p1.get('data', {}).get('last_page')}, Count: {len(p1.get('data', {}).get('data', []))}")
