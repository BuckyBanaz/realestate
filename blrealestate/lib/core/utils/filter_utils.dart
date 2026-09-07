class FilterUtils {
  static const List<String> allPropertyTypes = [
    'Plots',
    'Farmhouses',
    'Flats-Housing',
    'Agricultural Land',
    'Township',
    'Society',
  ];

  static const Map<String, List<String>> fixedCategories = {
    'Plots': ['Residential', 'Commercial', 'Industrial'],
    'Farmhouses': ['Build-in', 'Plots'],
    'Flats-Housing': ['House', 'Flats'],
    'Agricultural Land': ['Agricultural land'],
    'Township': ['Residential', 'Integrated', 'Gated'],
    'Society': ['Apartment Society', 'Under Construction'],
  };

  static List<String> getLiveCategories(String? type, Map<dynamic, dynamic> dynData) {
    if (type == null) return <String>[];
    try {
      final typeMap = dynData[type];
      final liveKeys = typeMap is Map
          ? typeMap.keys
                .whereType<String>()
                .where((k) => k != 'Other')
                .toSet()
          : <String>{};
      final fixed = fixedCategories[type] ?? <String>[];
      final merged = {...liveKeys, ...fixed}.toList()..sort();
      return merged.isNotEmpty ? merged : fixed;
    } catch (_) {
      return fixedCategories[type] ?? <String>[];
    }
  }

  static List<String> getSubCategories(String? type, String? category, Map<dynamic, dynamic> dynData) {
    if (type == null || category == null) return <String>[];
    try {
      final typeMap = dynData[type];
      if (typeMap is Map) {
        final raw = typeMap[category];
        return raw is List ? raw.whereType<String>().toList() : <String>[];
      }
      return <String>[];
    } catch (_) {
      return <String>[];
    }
  }
}
