import urllib.request, json, ssl
BASE = 'https://hisarpropertybazar.com/blapis/api'
token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2hpc2FycHJvcGVydHliYXphci5jb20vYmxhcGlzL2FwaS9DaGFubmVsUGFydG5lci92ZXJpZnktb3RwIiwiaWF0IjoxNzg4MzU2MDgyLCJleHAiOjIxMDM3MTYwODIsIm5iZiI6MTc4ODM1NjA4MiwianRpIjoiMjg3blh6RnRoME5hbmltVCIsInN1YiI6Ijc3IiwicHJ2IjoiMjNiZDVjODk0OWY2MDBhZGIzOWU3MDFjNDAwODcyZGI3YTU5NzZmNyJ9.XyJbkiSX-euVfj-FGYzDCVIuS5s6pWQRDiqs0tTZkYo'

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

r1 = urllib.request.Request(BASE + '/ChannelPartner/properties?page=1&per_page=20', headers={'Authorization':f'Bearer {token}'})
with urllib.request.urlopen(r1, context=ctx) as res:
    print('Page 1 Content-Type:', res.getheader('Content-Type'))

r2 = urllib.request.Request(BASE + '/ChannelPartner/properties?page=2&per_page=20', headers={'Authorization':f'Bearer {token}'})
with urllib.request.urlopen(r2, context=ctx) as res:
    print('Page 2 Content-Type:', res.getheader('Content-Type'))
