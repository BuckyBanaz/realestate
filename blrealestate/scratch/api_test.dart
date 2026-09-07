import 'dart:convert';
import 'dart:io';

Future<void> checkApi(String name, String baseUrl) async {
  print('--- Checking $name ---');
  print('Base URL: $baseUrl');
  
  final httpClient = HttpClient()
    ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    
  try {
    final uri = Uri.parse('$baseUrl/ChannelPartner/verify-otp');
    final req = await httpClient.postUrl(uri);
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode({'mobile': '9416250029', 'otp': '1234'}));
    
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    
    print('Status: ${res.statusCode}');
    print('Response: $body\n');
  } catch (e) {
    print('Error: $e\n');
  }
}

void main() async {
  await checkApi('Old IP (HTTPS)', 'https://108.181.185.27/blapis/api');
  await checkApi('Old IP (HTTP)', 'http://108.181.185.27/blapis/api');
  await checkApi('New Domain (HTTPS)', 'https://hisarpropertybazar.com/blapis/api');
  exit(0);
}
