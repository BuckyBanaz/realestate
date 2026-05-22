import 'package:get/get.dart';
import 'package:realestate/domain/repo/property_repository.dart';
import 'package:realestate/data/models/property_details_model.dart';
import 'package:realestate/data/models/property_list_model.dart';

class PropertyDetailController extends GetxController {
  final PropertyRepository _propertyRepo = PropertyRepository();
  
  var isLoading = true.obs;
  var isPlotsLoading = false.obs;
  var propertyDetails = Rxn<PropertyListItem>();
  var availablePlots = <PropertyListItem>[].obs;
  var selectedPropertyId = 0.obs;
  
  // Area Unit Management
  var selectedAreaUnit = "".obs;
  var lastAreaRaw = "".obs;

  Future<void> fetchPropertyDetails(int propertyId) async {
    try {
      isLoading.value = true;
      selectedPropertyId.value = propertyId;
      
      final data = await _propertyRepo.fetchPropertyDetails(propertyId);
      if (data != null) {
        propertyDetails.value = data;
        
        // Initialize area unit
        if (data.area.isNotEmpty) {
          lastAreaRaw.value = data.area;
          selectedAreaUnit.value = _guessUnit(data.area);
        }

        // After getting property details, fetch other plots in the same sub-subcategory asynchronously
        fetchRelatedPlots(
          categoryId: data.categoryId,
          subCategoryId: data.subcategoryId,
          subSubCategoryId: data.subSubCategoryId,
        );
      }
    } catch (e) {
      print('PropertyDetailController Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateAreaUnit(String unit) {
    selectedAreaUnit.value = unit;
  }

  String _guessUnit(String raw) {
    final l = raw.toLowerCase();
    if (l.contains('yard') || l.contains('sq-yd') || l.contains('sq.yd') || l.contains('sqyd')) {
      return 'Sq Yd';
    }
    if (l.contains('meter') || l.contains('sqm') || l.contains('sq-m') || l.contains('sq.m')) {
      return 'Sq M';
    }
    if (l.contains('acre')) return 'Acre';
    if (l.contains('ground')) return 'Grounds';
    if (l.contains('aankadam')) return 'Aankadam';
    if (l.contains('rood')) return 'Rood';
    if (l.contains('chatak')) return 'Chatak';
    if (l.contains('perch')) return 'Perch';
    if (l.contains('guntha')) return 'Guntha';
    if (l.contains('are')) return 'Ares';
    if (l.contains('biswa') && l.contains('kaccha')) return 'Biswa (Kaccha)';
    if (l.contains('biswa')) return 'Biswa (Pucca)';
    if (l.contains('ft') || l.contains('sqft') || l.contains('sq.ft')) {
      return 'Sq Ft';
    }
    return 'Sq Ft';
  }

  Future<void> fetchRelatedPlots({
    int? categoryId,
    int? subCategoryId,
    int? subSubCategoryId,
  }) async {
    try {
      isPlotsLoading.value = true;
      final response = await _propertyRepo.searchProperties(
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        subSubCategoryId: subSubCategoryId,
        perPage: 200, // Get all plots for selection
      );
      
      if (response != null) {
        final plots = response.data;
        // Sort plots numerically by Plot Number if possible
        plots.sort((a, b) {
          String getPlotNum(PropertyListItem p) {
            final attr = p.attributes.firstWhereOrNull((at) => 
              at.attribute.toLowerCase().contains("plot number") || 
              at.attribute.toLowerCase() == "plot no"
            );
            String val = attr?.value ?? p.title;
            // Extract numbers from string (e.g., "A69" -> 69, "Plot 1" -> 1)
            final match = RegExp(r'(\d+)').firstMatch(val);
            return match?.group(1) ?? "0";
          }
          
          int numA = int.tryParse(getPlotNum(a)) ?? 0;
          int numB = int.tryParse(getPlotNum(b)) ?? 0;
          return numA.compareTo(numB);
        });
        availablePlots.assignAll(plots);
      }
    } catch (e) {
      print('FetchRelatedPlots Error: $e');
    } finally {
      isPlotsLoading.value = false;
    }
  }

  void onPlotSelected(PropertyListItem plot) {
    if (plot.id == selectedPropertyId.value) return;
    fetchPropertyDetails(plot.id);
  }

  // --- Area Conversion Logic ---

  double _convertArea(double value, String from, String to) {
    const toSqFt = {
      'Sq Ft': 1.0,
      'Sq Yd': 9.0,
      'Sq M': 10.7639,
      'Acre': 43560.0,
      'Grounds': 2400.0,
      'Aankadam': 72.0,
      'Rood': 10890.0,
      'Chatak': 45.0,
      'Perch': 272.25,
      'Guntha': 1089.0,
      'Ares': 1076.39,
      'Biswa (Pucca)': 27225.0,
      'Biswa (Kaccha)': 9075.0,
    };

    final fromFactor = toSqFt[from] ?? 1.0;
    final toFactor = toSqFt[to] ?? 1.0;
    return (value * fromFactor) / toFactor;
  }

  String extractNumber(String raw) {
    final match = RegExp(r'([\d]+(\.[\d]+)?)').firstMatch(raw);
    return match?.group(1) ?? '';
  }

  String unitLabel(String unit) {
    switch (unit) {
      case 'Sq Ft': return 'sq.ft.';
      case 'Sq Yd': return 'sq.yd.';
      case 'Sq M': return 'sq.m.';
      case 'Acre': return 'acre';
      case 'Grounds': return 'grounds';
      case 'Aankadam': return 'aankadam';
      case 'Rood': return 'rood';
      case 'Chatak': return 'chataks';
      case 'Perch': return 'perch';
      case 'Guntha': return 'guntha';
      case 'Ares': return 'ares';
      case 'Biswa (Pucca)': return 'biswa (pucca)';
      case 'Biswa (Kaccha)': return 'biswa (kaccha)';
      default: return unit.toLowerCase();
    }
  }

  String formatNumber(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  String getDisplayArea(String rawValue) {
    final baseUnit = _guessUnit(rawValue);
    final baseValueStr = extractNumber(rawValue);
    final baseValue = double.tryParse(baseValueStr);

    if (baseValue == null) return rawValue;
    
    final selectedUnit = selectedAreaUnit.value.isEmpty ? baseUnit : selectedAreaUnit.value;
    return formatNumber(_convertArea(baseValue, baseUnit, selectedUnit));
  }
}
