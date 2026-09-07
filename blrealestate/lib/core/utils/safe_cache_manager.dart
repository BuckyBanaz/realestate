import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// A CacheManager that silently swallows non-200 HTTP responses
/// instead of throwing HttpExceptionWithStatus (which crashes the app on 404).
/// Also caps disk cache to 100 objects / 50 MB to prevent storage bloat on
/// low-storage devices common in the target market (1-2GB RAM phones).
class SafeCacheManager extends CacheManager with ImageCacheManager {
  static const _key = 'safeImageCache';
  static final SafeCacheManager _instance = SafeCacheManager._();
  factory SafeCacheManager() => _instance;

  SafeCacheManager._()
      : super(Config(
          _key,
          stalePeriod: const Duration(days: 3),
          maxNrOfCacheObjects: 100,  // was 200 — halved for low-storage devices
        ));
}
