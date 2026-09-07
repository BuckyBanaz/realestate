import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks which bottom-nav tab is currently active.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Tracks the previously active tab so the Profile back button can return to it.
final prevNavIndexProvider = StateProvider<int>((ref) => 0);
