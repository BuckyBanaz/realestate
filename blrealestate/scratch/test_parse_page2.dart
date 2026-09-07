import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2hpc2FycHJvcGVydHliYXphci5jb20vYmxhcGlzL2FwaS9DaGFubmVsUGFydG5lci92ZXJpZnktb3RwIiwiaWF0IjoxNzg4MzU2MDgyLCJleHAiOjIxMDM3MTYwODIsIm5iZiI6MTc4ODM1NjA4MiwianRpIjoiMjg3blh6RnRoME5hbmltVCIsInN1YiI6Ijc3IiwicHJ2IjoiMjNiZDVjODk0OWY2MDBhZGIzOWU3MDFjNDAwODcyZGI3YTU5NzZmNyJ9.XyJbkiSX-euVfj-FGYzDCVIuS5s6pWQRDiqs0tTZkYo';
  final url = Uri.parse('https://hisarpropertybazar.com/blapis/api/ChannelPartner/properties?page=2&per_page=20');
  
  try {
    final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    final body = jsonDecode(res.body);
    final data = body['data']['data'] as List;
    
    print('Found ${data.length} items on page 2');
    
    int successCount = 0;
    for (var i = 0; i < data.length; i++) {
      try {
        final item = data[i];
        // SIMULATE _parseInventoryList from app_providers.dart
        
        // Extracting some fields to simulate what InventoryModel.fromJson does
        final catData  = item['category'] is Map ? item['category'] : null;
        final subData  = item['subcategory'] is Map ? item['subcategory'] : null;
        final ssubData = item['sub_subcategory'] is Map ? item['sub_subcategory'] : null;

        String? category    = catData?['name']?.toString().trim();
        String? subcategory = subData?['name']?.toString().trim();
        String? project     = ssubData?['name']?.toString().trim();

        final mainImg = item['main_image'] ?? item['main_image_url'] ?? item['image'];
        final catImg  = catData?['image'];
        
        // Simulating the actual fromJson...
        // We'll just parse a few critical fields that might crash
        final id = item['id'] is int ? item['id'] : int.tryParse(item['id']?.toString() ?? '0') ?? 0;
        final title = item['title']?.toString() ?? 'Untitled';
        final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
        final status = item['status']?.toString() ?? 'Available';
        final area = item['area']?.toString() ?? '';
        
        // activeHold
        final activeHold = item['active_hold'] is Map<String, dynamic> ? item['active_hold'] : null;
        
        successCount++;
      } catch (e, stack) {
        print('Failed to parse item $i: $e\n$stack');
      }
    }
    print('Successfully parsed $successCount out of ${data.length} items.');
  } catch (e) {
    print('Error fetching: $e');
  }
}
