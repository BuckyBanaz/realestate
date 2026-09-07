import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';

// ─── Search & Pagination State ───────────────────────────────────────────────

final leadSearchProvider = StateProvider<String>((ref) => '');
// Debounced search — only triggers API call after user stops typing
final inventorySearchProvider = StateProvider<String>((ref) => '');

final inventoryPageProvider = StateProvider<int>((ref) => 1);
final categoryFilterProvider = StateProvider<FilterCriteria?>((ref) => null);
