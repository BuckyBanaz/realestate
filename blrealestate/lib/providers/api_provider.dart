import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';

/// Single shared ApiClient provider.
/// Imported by both auth_provider.dart and app_providers.dart
/// to avoid circular imports.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
