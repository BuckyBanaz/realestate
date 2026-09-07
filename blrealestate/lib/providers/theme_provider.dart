// RIVERPOD FIX #30: Use AsyncNotifier so build() can be async,
// eliminating the light-mode flash on cold start.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

final themeProvider =
    AsyncNotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  static const _themeKey = 'app_theme_mode';

  @override
  Future<ThemeMode> build() async {
    // Reads persisted value on every cold start — no flash
    final storage = ref.read(storageProvider);
    final saved = await storage.read(key: _themeKey);
    return saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final current = state.valueOrNull ?? ThemeMode.light;
    final next = current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = AsyncData(next);
    await ref
        .read(storageProvider)
        .write(key: _themeKey, value: next == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = AsyncData(mode);
    await ref
        .read(storageProvider)
        .write(key: _themeKey, value: mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
