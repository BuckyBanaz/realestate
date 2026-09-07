import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../core/api/api_endpoints.dart';
import 'auth_provider.dart';
import 'api_provider.dart';
import 'state_providers.dart';

// ─── Global compute isolate semaphore ────────────────────────────────────────
// Only ONE compute isolate runs at a time across ALL providers.
// This is the root cause of the ANR (signal 3): profile, notifications,
// properties, commissions and leads all completed their network calls within
// seconds of each other, each spawning a compute isolate simultaneously.
// 4-5 isolates delivering parsed results back to the main thread at the same
// time caused 4-5 simultaneous setState/provider updates → GPU flooded →
// main thread blocked → Android ANR watchdog fires signal 3.
final _computeLock = _Semaphore(1);

class _Semaphore {
  int _count;
  final _queue = <Completer<void>>[];

  _Semaphore(int maxCount) : _count = maxCount;

  Future<void> acquire() async {
    if (_count > 0) {
      _count--;
      return;
    }
    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
  }

  void release() {
    if (_queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      next.complete();
    } else {
      _count++;
    }
  }
}

/// Drop-in replacement for [compute] that serializes isolate execution.
/// Prevents simultaneous isolate completions from flooding the main thread.
Future<R> _computeSerial<Q, R>(R Function(Q) callback, Q message) async {
  await _computeLock.acquire();
  try {
    return await compute(callback, message);
  } finally {
    _computeLock.release();
  }
}

// ─── Dynamic Filters — 100% from live inventory, no hardcoding ───────────────
Map<String, dynamic> _computeDynamicFilters(List<InventoryModel> items) {
  final Map<String, dynamic> result = {'__cities__': <String>[]};
  if (items.isEmpty) return result;

  final Set<String> citySet = {};

  for (final item in items) {
    final type = item.propertyType?.trim();
    final city = item.city?.trim();

    if (type == null || type.isEmpty) continue;

    result.putIfAbsent(type, () => <String, List<String>>{});
    final dynamic rawMap = result[type];
    if (rawMap is! Map<String, List<String>>) continue;
    final Map<String, List<String>> typeMap = rawMap;

    // For the fixed-6 chip hierarchy:
    //   propertyType (e.g. "Plots") → subcategory (e.g. "Residential") → project (e.g. "Raja Ram Aero City")
    final effectiveCat = (item.subcategory != null && item.subcategory!.isNotEmpty)
        ? item.subcategory!.trim()
        : 'Other';

    typeMap.putIfAbsent(effectiveCat, () => <String>[]);

    // project = sub_subcategory name — the deepest level
    final proj = item.project?.trim();
    if (proj != null && proj.isNotEmpty && !typeMap[effectiveCat]!.contains(proj)) {
      typeMap[effectiveCat]!.add(proj);
    }

    if (city != null && city.isNotEmpty) {
      citySet.add(city[0].toUpperCase() + city.substring(1).toLowerCase());
    }
  }

  result['__cities__'] = citySet.toList()..sort();

  // Sort sub-categories
  for (final type in result.keys) {
    if (type == '__cities__') continue;
    final dynamic rawMap = result[type];
    if (rawMap is! Map<String, List<String>>) continue;
    for (final cat in rawMap.keys) {
      rawMap[cat]!.sort();
    }
  }

  return result;
}

// Page-1 inventory snapshot — stable seed for filter chips & city list ────
// Only written when page-1 data arrives (see InventoryNotifier.build).
// Both dynamicFiltersProvider and locationListProvider watch this instead of
// inventoryProvider so their values never change when the user navigates to
// page 2+ (which previously caused filter chips to go blank or show wrong values).
// Public (no underscore) so auth_provider.dart can invalidate it on logout.
final inventoryFilterSeedProvider = StateProvider<List<InventoryModel>>(
  (ref) => const [],
);

final dynamicFiltersProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Watch the stable page-1 seed — NOT inventoryProvider directly.
  // This means filter chips are computed once from page-1 data and never
  // change when user navigates to page 2+.
  final items = ref.watch(inventoryFilterSeedProvider);

  if (items.isEmpty) return {'__cities__': <String>[]};

  // Yield one frame before spawning the isolate — prevents the compute burst
  // from landing on the same frame as the inventory widget tree rebuild,
  // which was causing BLASTBufferQueue overflow → ANR on MediaTek devices.
  await Future.delayed(Duration.zero);

  // Run in an isolate — avoids blocking the main thread with hundreds of items.
  return _computeSerial(_computeDynamicFilters, items);
});

// ─── Filter Counts ──────────────────────────────────────────────────────────────────
// REMOVED: filterCountsProvider was never watched by any widget, just wasted
// CPU on every inventory update. Deleted per bugs.md dead code audit.

// ─── Cache Metadata ──────────────────────────────────────────────────────────
class CacheMetadata {
  final DateTime lastUpdated;
  final int totalPages;
  final int currentPage;
  final String? error;
  final int? totalItems;

  CacheMetadata({
    required this.lastUpdated,
    this.totalPages = 1,
    this.currentPage = 1,
    this.totalItems,
    this.error,
  });

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(lastUpdated);
    
    // Handle edge cases where clock might be out of sync
    if (diff.isNegative) return 'Just now';
    
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}



// ─── Helper: parse paginated response safely ─────────────────────────────────
(List<dynamic>, int, int?) _parsePaginated(dynamic raw) {
  try {
    if (raw is! Map) return (<dynamic>[], 1, null);
    final dataWrapper = raw['data'] ?? raw;
    List<dynamic> items;
    if (dataWrapper is Map) {
      final d = dataWrapper['data'];
      items = d is List ? d : [];
    } else if (dataWrapper is List) {
      items = dataWrapper;
    } else {
      items = [];
    }
    // last_page can come as int or String from some backends
    final rawPages = dataWrapper is Map ? dataWrapper['last_page'] : null;
    final totalPages = rawPages is int
        ? rawPages
        : int.tryParse(rawPages?.toString() ?? '') ?? 1;
        
    final rawTotal = dataWrapper is Map ? dataWrapper['total'] : null;
    final totalItems = rawTotal is int
        ? rawTotal
        : int.tryParse(rawTotal?.toString() ?? '');
        
    return (items, totalPages, totalItems);
  } catch (_) {
    return (<dynamic>[], 1, null);
  }
}

// ─── 1. Profile ──────────────────────────────────────────────────────────────
final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, Map<String, dynamic>>(
        ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    // Keep data alive once loaded
    
    final auth = await ref.watch(authProvider.future);
    if (auth == null) return {};
    
    try {
      final res = await ref.read(apiClientProvider).get(ApiEndpoints.profile);
      final raw = res.data;
      final data = raw['data'] ?? raw;
      return data is Map<String, dynamic> ? data : {};
    } catch (_) {
      rethrow; // surface error so ProfileScreen shows the retry button
    }
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<bool> updateProfile(
    Map<String, dynamic> data, {
    String? imagePath,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final hasPath  = imagePath != null && imagePath.isNotEmpty;
      final hasBytes = imageBytes != null && imageBytes.isNotEmpty;

      if (hasPath || hasBytes) {
        final formData = FormData.fromMap(data);

        if (hasPath) {
          // Local file path — guard existence before reading.
          // imagePath is non-null here because hasPath == true.
          final localPath = imagePath;
          final file = File(localPath);
          if (!file.existsSync()) {
            dev.log('[ProfileNotifier] Image file not found: $localPath', name: 'ProfileNotifier');
            return false;
          }
          formData.files.add(MapEntry(
            'image',
            await MultipartFile.fromFile(
              localPath,
              filename: localPath.split(RegExp(r'[/\\]')).last,
            ),
          ));
        } else {
          // In-memory bytes — used for cloud/Google Photos picks where path is null.
          // imageBytes is non-null here because hasBytes == true.
          formData.files.add(MapEntry(
            'image',
            MultipartFile.fromBytes(
              imageBytes as List<int>,
              filename: imageName ?? 'profile_image.jpg',
            ),
          ));
        }

        // Use a longer timeout for file uploads — 60 s send, 60 s receive.
        await ref.read(apiClientProvider).postFormDataWithTimeout(
          ApiEndpoints.updateProfile,
          data: formData,
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        );
      } else {
        await ref.read(apiClientProvider).post(ApiEndpoints.updateProfile, data: data);
      }
      ref.invalidateSelf();
      return true;
    } catch (e, stack) {
      dev.log('[ProfileNotifier] updateProfile failed: $e',
          name: 'ProfileNotifier', error: e, stackTrace: stack);
      return false;
    }
  }
}

// ─── 2. Stats ────────────────────────────────────────────────────────────────
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, Map<String, dynamic>>(
        StatsNotifier.new);

class StatsNotifier extends AsyncNotifier<Map<String, dynamic>> {

  @override
  Future<Map<String, dynamic>> build() async {
    
    final auth = await ref.watch(authProvider.future);
    if (auth == null) return {};

    // Stagger stats behind profile/notifications — fires 2s after auth so it
    // doesn't pile onto the same frame as commissions + leads compute isolates
    // completing, which was the exact timing that caused signal 3 on profile tab switch.
    await Future.delayed(const Duration(milliseconds: 2000));
    
    try {
      final res = await ref.read(apiClientProvider).get(ApiEndpoints.stats);
      final raw = res.data;
      final data = raw['data'] ?? raw;
      return data is Map<String, dynamic> ? data : {};
    } catch (e) {
      return {}; // Stats are non-critical — empty map shows '—' in UI, no retry needed
    }
  }

  Future<void> refresh() async => ref.invalidateSelf();
}

// ─── 2b. Total Earnings Derived Provider ──────────────────────────────────────
final totalEarningsProvider = Provider<double>((ref) {
  final commissionState = ref.watch(commissionProvider);
  final statsState = ref.watch(statsProvider);

  // If commission list is available, use it (Source of Truth)
  if (commissionState.hasValue) {
    final (list, _) = commissionState.value!;
    return list.fold(0.0, (sum, c) => sum + c.amount);
  }
  
  // Otherwise, if stats summary is available, use it (Fast Fallback)
  if (statsState.hasValue) {
    final stats = statsState.value!;
    final raw = stats['total_commission'] ?? stats['earnings'] ?? 0;
    return double.tryParse(raw.toString()) ?? 0.0;
  }

  // If nothing is loaded yet, return 0.0
  return 0.0;
});

// ─── 2c. Category Tree ──────────────────────────────────────────────────────────────────
// REMOVED: categoryTreeProvider was never watched by any widget. It duplicated
// categoriesProvider which returns typed CategoryNode objects. Deleted per bugs.md.

// ─── 2d. Location List (Extracted from Inventory) ─────────────────────────────
// Watches _inventoryFilterSeedProvider (page-1 snapshot) instead of
// inventoryProvider so the city dropdown in the filter sheet does not
// change / go empty when the user navigates to page 2+.
final locationListProvider = Provider<List<String>>((ref) {
  final items = ref.watch(inventoryFilterSeedProvider);
  if (items.isEmpty) return [];
  final cities = items
      .map((e) => e.city?.trim())
      .where((e) => e != null && e.isNotEmpty)
      .cast<String>()
      .toSet()
      .toList();
  cities.sort();
  return cities;
});

// NEW: A separate provider specifically for unpaginated fetching (e.g. Dropdowns, My Holdings)
final allPropertiesDropdownProvider = FutureProvider<List<InventoryModel>>((ref) async {
  // Keep alive so re-opening My Holdings or Add Lead doesn't re-fetch 500 items.
  // Invalidated explicitly after holdUnit() and on logout.
  ref.keepAlive();

  final auth = await ref.watch(authProvider.future);
  if (auth == null) return [];
  
  try {
    // Request a large limit to bypass pagination for dropdowns
    final res = await ref.read(apiClientProvider).get(
      ApiEndpoints.inventory,
      queryParameters: {'per_page': 500},
    );
    final (items, _, _) = _parsePaginated(res.data);
    return await _computeSerial(_parseInventoryList, items);
  } catch (e) {
    dev.log('[allPropertiesDropdownProvider] failed: $e', name: 'AppProviders');
    return [];
  }
});

// ─── 3. Inventory ────────────────────────────────────────────────────────────
final inventoryProvider =
    AsyncNotifierProvider<InventoryNotifier, (List<InventoryModel>, CacheMetadata)>(
        InventoryNotifier.new);

// Top-level functions required by compute() — must not be closures or methods
List<InventoryModel> _parseInventoryList(List<dynamic> items) {
  final result = <InventoryModel>[];
  for (final e in items) {
    if (e is! Map<String, dynamic>) continue; // skip non-Map entries — hard cast was crashing isolate
    try {
      result.add(InventoryModel.fromJson(e));
    } catch (_) {
      // skip single malformed item, never kill the whole list
    }
  }
  return result;
}

List<LeadModel> _parseLeadList(List<dynamic> items) {
  final result = <LeadModel>[];
  for (final e in items) {
    if (e is! Map<String, dynamic>) continue;
    try { result.add(LeadModel.fromJson(e)); } catch (_) {}
  }
  return result;
}

List<DealModel> _parseDealList(List<dynamic> items) {
  final result = <DealModel>[];
  for (final e in items) {
    if (e is! Map<String, dynamic>) continue;
    try { result.add(DealModel.fromJson(e)); } catch (_) {}
  }
  return result;
}

List<CommissionModel> _parseCommissionList(List<dynamic> items) {
  final result = <CommissionModel>[];
  for (final e in items) {
    if (e is! Map<String, dynamic>) continue;
    try { result.add(CommissionModel.fromJson(e)); } catch (_) {}
  }
  return result;
}

List<TaskModel> _parseTaskList(List<dynamic> items) {
  final result = <TaskModel>[];
  for (final e in items) {
    if (e is! Map<String, dynamic>) continue;
    try { result.add(TaskModel.fromJson(e)); } catch (_) {}
  }
  return result;
}

List<NotificationModel> _parseNotificationList(List<dynamic> items) {
  final result = <NotificationModel>[];
  for (final e in items) {
    if (e is! Map<String, dynamic>) continue;
    try { result.add(NotificationModel.fromJson(e)); } catch (_) {}
  }
  return result;
}

class InventoryNotifier
    extends AsyncNotifier<(List<InventoryModel>, CacheMetadata)> {

  // Timer for the post-hold background refresh. Stored as a field so it can
  // be cancelled on dispose, preventing ref access on a disposed notifier.
  Timer? _holdRefreshTimer;
  bool _disposed = false;
  static const int perPage = 20;

  @override
  Future<(List<InventoryModel>, CacheMetadata)> build() async {
    // Reset on every build — Riverpod reuses the same notifier instance when a
    // watched dependency changes (page/filter/search). The previous build scope's
    // onDispose fires and sets _disposed=true on this same instance. Without this
    // reset, the 1500ms delay guard below silently returns [] on every page change.
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _holdRefreshTimer?.cancel();
    });

    final auth = await ref.watch(authProvider.future);
    if (auth == null) {
      return (<InventoryModel>[], CacheMetadata(lastUpdated: DateTime.now()));
    }

    final page = ref.watch(inventoryPageProvider);
    final filter = ref.watch(categoryFilterProvider);
    final search = ref.watch(inventorySearchProvider).trim();

    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (search.isNotEmpty) queryParams['search'] = search;
      if (filter != null) {
        // property_type confirmed by live API test: ?property_type=Plots → 261 items
        // (type=Plots was silently ignored by the server → returned 276 unfiltered)
        if (filter.type     != null) queryParams['property_type'] = filter.type;
        if (filter.category != null) queryParams['category']      = filter.category;
        if (filter.minPrice != null) queryParams['min_price']     = filter.minPrice;
        if (filter.maxPrice != null) queryParams['max_price']     = filter.maxPrice;
        if (filter.location != null) queryParams['city']          = filter.location;
        if (filter.isCorner == true) queryParams['is_corner']     = 1;
      }

      final res = await ref.read(apiClientProvider).get(
        ApiEndpoints.inventory,
        queryParameters: queryParams,
      );
      final (items, totalPages, totalItems) = _parsePaginated(res.data);
      final list = await _computeSerial(_parseInventoryList, items);

      // Populate the filter-chip seed from page-1 data ONLY when no filter is active.
      // If a filter is active (e.g. property_type=Plots), the returned list only contains
      // Plots items. Writing that to the seed would destroy category chips for all other
      // property types until the next cold start.
      if (page == 1 && filter == null && list.isNotEmpty && !_disposed) {
        Future.microtask(() {
          if (!_disposed) {
            ref.read(inventoryFilterSeedProvider.notifier).state = list;
          }
        });
      }

      final result = (
        list,
        CacheMetadata(lastUpdated: DateTime.now(), totalPages: totalPages, currentPage: page, totalItems: totalItems),
      );
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  void nextPage(int totalPages) {
    final notifier = ref.read(inventoryPageProvider.notifier);
    if (notifier.state < totalPages) {
      notifier.state++;
    }
  }

  void previousPage() {
    final notifier = ref.read(inventoryPageProvider.notifier);
    if (notifier.state > 1) {
      notifier.state--;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }


  Future<bool> holdUnit({
    required int propertyId,
    required String customerName,
    required String customerMobile,
    required double amount,
    required List<String> documentPaths,
  }) async {
    try {
      final formData = FormData.fromMap({
        'customer_name': customerName,
        'customer_mobile': customerMobile,
        'amount': amount.toString(),
      });
      for (final path in documentPaths) {
        if (path.isEmpty) continue;
        final file = File(path);
        if (!file.existsSync()) continue;
        try {
          formData.files.add(MapEntry(
            'documents[]',
            await MultipartFile.fromFile(
              path,
              filename: path.split(RegExp(r'[/\\]')).last,
            ),
          ));
        } catch (_) {
          // Skip files that can't be read (permission denied, moved, etc.)
          continue;
        }
      }
      await ref.read(apiClientProvider).postFormDataWithTimeout(
        ApiEndpoints.holdProperty(propertyId),
        data: formData,
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      );

      // ── Optimistic update — flip status to HELD instantly, no network wait ──
      if (state.hasValue) {
        final (currentList, metadata) = state.value!;
        final updatedList = currentList.map((item) {
          if (item.id != propertyId) return item;
          // Rebuild with status='held' so displayStatus returns 'HOLD' immediately.
          // Also inject a fake activeHold so MyHoldingsScreen can find this property
          // before the 2s background refresh syncs from the server.
          final myUserIdRaw = ref.read(profileProvider).valueOrNull?['id'];
          final myUserId = myUserIdRaw is int ? myUserIdRaw : int.tryParse(myUserIdRaw?.toString() ?? '') ?? 0;
          final fakeActiveHold = <String, dynamic>{
            'status': 'active',
            'user_id': myUserId,
            'hold_until': null,
          };
          return InventoryModel(
            id: item.id,
            title: item.title,
            image: item.image,
            price: item.price,
            status: 'held',
            area: item.area,
            address: item.address,
            city: item.city,
            propertyType: item.propertyType,
            category: item.category,
            subcategory: item.subcategory,
            project: item.project,
            categoryId: item.categoryId,
            subcategoryId: item.subcategoryId,
            subSubcategoryId: item.subSubcategoryId,
            attributes: item.attributes,
            amenities: item.amenities,
            heldUntil: null,
            heldBy: myUserId, // set to actual user id so MyHoldingsScreen filter works
            latitude: item.latitude,
            longitude: item.longitude,
            description: item.description,
            activeHold: fakeActiveHold,
            images: item.images,
            displayStatus: InventoryModel.computeDisplayStatus(
              status: 'held',
              activeHold: fakeActiveHold,
              heldBy: myUserId,
              heldUntil: null,
            ),
          );
        }).toList();
        state = AsyncData((updatedList, metadata));

        // Invalidate dropdown provider so My Holdings picks up the latest backend state
        ref.invalidate(allPropertiesDropdownProvider);
      }

      // Description: Background refresh 2s after hold to sync status with server.
      // Why: Uses a class-level Timer field (cancelled in onDispose via build)
      //      so the callback never runs on a disposed notifier.
      //      so the callback never runs on a disposed notifier.
      if (_disposed) return true;
      ref.invalidate(statsProvider);
      _holdRefreshTimer?.cancel();
      _holdRefreshTimer = Timer(const Duration(seconds: 2), () {
        if (!_disposed) ref.invalidateSelf();
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

}

// ─── 4. Leads ────────────────────────────────────────────────────────────────
final leadProvider =
    AsyncNotifierProvider<LeadNotifier, (List<LeadModel>, CacheMetadata)>(
        LeadNotifier.new);

class LeadNotifier extends AsyncNotifier<(List<LeadModel>, CacheMetadata)> {
  Timer? _actionTimer;
  bool _disposed = false;

  @override
  Future<(List<LeadModel>, CacheMetadata)> build() async {
    _disposed = false; // reset — same notifier instance reused on authProvider change
    ref.onDispose(() {
      _disposed = true;
      _actionTimer?.cancel();
    });
    final auth = await ref.watch(authProvider.future);
    if (auth == null) {
      return (<LeadModel>[], CacheMetadata(lastUpdated: DateTime.now()));
    }
    
    try {
      final res = await ref.read(apiClientProvider).get(ApiEndpoints.leads);
      final (items, totalPages, totalItems) = _parsePaginated(res.data);
      final list = await _computeSerial(_parseLeadList, items);
      return (
        list,
        CacheMetadata(
          lastUpdated: DateTime.now(),
          totalPages: totalPages,
          currentPage: 1,
          totalItems: totalItems,
        ),
      );
    } catch (e, stack) {
      dev.log('[LeadProvider] build() failed: $e', name: 'Providers', error: e, stackTrace: stack);
      rethrow;
    }
  }


  Future<void> refresh() async => ref.invalidateSelf();

  Future<bool> addLead(Map<String, dynamic> data) async {
    try {
      await ref.read(apiClientProvider).post(ApiEndpoints.leads, data: data);
      if (_disposed) return true;
      _actionTimer?.cancel();
      _actionTimer = Timer(const Duration(milliseconds: 400), () {
        if (!_disposed) {
          ref.invalidateSelf();
          ref.invalidate(statsProvider);
        }
      });
      return true;
    } catch (e, stack) {
      dev.log('[LeadNotifier] addLead failed: $e', name: 'Providers', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<bool> updateLeadStatus(int leadId, String status) async {
    try {
      await ref.read(apiClientProvider).patch(
        ApiEndpoints.leadStatus(leadId),
        data: {'status': status},
      );
      // Optimistic update
      if (state.hasValue) {
        final (list, meta) = state.value!;
        final updatedList = list.map((l) {
          if (l.id == leadId) {
            return LeadModel(
              id: l.id,
              name: l.name,
              clientName: l.clientName,
              phone: l.phone,
              email: l.email,
              address: l.address,
              message: l.message,
              status: status, // Optimistic update
              propertyTitle: l.propertyTitle,
              date: l.date,
              meetingDate: l.meetingDate,
              paymentReceived: l.paymentReceived,
              pendingPayment: l.pendingPayment,
            );
          }
          return l;
        }).toList();
        state = AsyncData((updatedList, meta));
      }

      // Delay invalidation — gives the backend time to propagate the status change.
      // 5s is enough for any reasonable backend; the optimistic update already
      // shows the new status instantly so the user never sees a blank period.
      if (_disposed) return true;
      _actionTimer?.cancel();
      _actionTimer = Timer(const Duration(seconds: 5), () {
        if (!_disposed) {
          ref.invalidateSelf();
          ref.invalidate(statsProvider);
        }
      });
      return true;
    } catch (e, stack) {
      dev.log('[LeadNotifier] updateLeadStatus failed: $e', name: 'Providers', error: e, stackTrace: stack);
      return false;
    }
  }

}

// ─── 5. Deals ────────────────────────────────────────────────────────────────
final dealsProvider =
    AsyncNotifierProvider<DealsNotifier, (List<DealModel>, CacheMetadata)>(
        DealsNotifier.new);

class DealsNotifier extends AsyncNotifier<(List<DealModel>, CacheMetadata)> {

  @override
  Future<(List<DealModel>, CacheMetadata)> build() async {
    final auth = await ref.watch(authProvider.future);
    if (auth == null) {
      return (<DealModel>[], CacheMetadata(lastUpdated: DateTime.now()));
    }
    
    try {
      final res = await ref.read(apiClientProvider).get(ApiEndpoints.deals);
      final (items, totalPages, totalItems) = _parsePaginated(res.data);
      final list = await _computeSerial(_parseDealList, items);
      return (
        list,
        CacheMetadata(
          lastUpdated: DateTime.now(),
          totalPages: totalPages,
          currentPage: 1,
          totalItems: totalItems,
        ),
      );
    } catch (e, stack) {
      dev.log('[DealsProvider] build() failed: $e', name: 'Providers', error: e, stackTrace: stack);
      rethrow;
    }
  }


  Future<void> refresh() async => ref.invalidateSelf();

}

// ─── 6. Commissions ──────────────────────────────────────────────────────────
final commissionProvider =
    AsyncNotifierProvider<CommissionNotifier, (List<CommissionModel>, CacheMetadata)>(
        CommissionNotifier.new);

class CommissionNotifier
    extends AsyncNotifier<(List<CommissionModel>, CacheMetadata)> {

  @override
  Future<(List<CommissionModel>, CacheMetadata)> build() async {

    final auth = await ref.watch(authProvider.future);
    if (auth == null) {
      return (<CommissionModel>[], CacheMetadata(lastUpdated: DateTime.now()));
    }

    try {
      final res = await ref.read(apiClientProvider).get(ApiEndpoints.commissions);
      final (items, totalPages, totalItems) = _parsePaginated(res.data);
      final list = await _computeSerial(_parseCommissionList, items);
      return (
        list,
        CacheMetadata(
          lastUpdated: DateTime.now(),
          totalPages: totalPages,
          currentPage: 1,
          totalItems: totalItems,),
      );
    } catch (e, stack) {
      dev.log('[CommissionProvider] build() failed: $e', name: 'Providers', error: e, stackTrace: stack);
      rethrow;
    }
  }


  Future<void> refresh() async => ref.invalidateSelf();

}

// ─── 7. Tasks ────────────────────────────────────────────────────────────────
final taskProvider =
    AsyncNotifierProvider<TaskNotifier, (List<TaskModel>, CacheMetadata)>(
        TaskNotifier.new);

class TaskNotifier extends AsyncNotifier<(List<TaskModel>, CacheMetadata)> {
  Timer? _actionTimer;
  bool _disposed = false;

  @override
  Future<(List<TaskModel>, CacheMetadata)> build() async {
    _disposed = false; // reset — same notifier instance reused on authProvider change
    ref.onDispose(() {
      _disposed = true;
      _actionTimer?.cancel();
    });

    final auth = await ref.watch(authProvider.future);
    if (auth == null) {
      return (<TaskModel>[], CacheMetadata(lastUpdated: DateTime.now()));
    }
    
    try {
      final res = await ref.read(apiClientProvider).get(ApiEndpoints.tasks);
      final (items, totalPages, totalItems) = _parsePaginated(res.data);
      final list = await _computeSerial(_parseTaskList, items);
      return (
        list,
        CacheMetadata(
          lastUpdated: DateTime.now(),
          totalPages: totalPages,
          currentPage: 1,
          totalItems: totalItems,
        ),
      );
    } catch (e, stack) {
      dev.log('[TaskProvider] build() failed: $e', name: 'Providers', error: e, stackTrace: stack);
      rethrow;
    }
  }


  Future<void> refresh() async => ref.invalidateSelf();

  Future<bool> updateTaskStatus(int taskId, String status) async {
    try {
      await ref.read(apiClientProvider).patch(
        ApiEndpoints.taskStatus(taskId),
        data: {'status': status},
      );
      if (_disposed) return true;
      _actionTimer?.cancel();
      _actionTimer = Timer(const Duration(milliseconds: 400), () {
        if (!_disposed) ref.invalidateSelf();
      });
      return true;
    } catch (e, stack) {
      dev.log('[TaskNotifier] updateTaskStatus failed: $e', name: 'Providers', error: e, stackTrace: stack);
      return false;
    }
  }

}

// ─── 8. Notifications ────────────────────────────────────────────────────────
final notificationsProvider =
    AsyncNotifierProvider<NotificationNotifier, (List<NotificationModel>, CacheMetadata)>(
        NotificationNotifier.new);

class NotificationNotifier
    extends AsyncNotifier<(List<NotificationModel>, CacheMetadata)> {

  @override
  Future<(List<NotificationModel>, CacheMetadata)> build() async {

    final auth = await ref.watch(authProvider.future);
    if (auth == null) {
      return (<NotificationModel>[], CacheMetadata(lastUpdated: DateTime.now()));
    }
    
    try {
      final res = await ref.read(apiClientProvider).get(ApiEndpoints.notifications);
      final (items, totalPages, totalItems) = _parsePaginated(res.data);
      final list = await _computeSerial(_parseNotificationList, items);
      return (
        list,
        CacheMetadata(
          lastUpdated: DateTime.now(),
          totalPages: totalPages,
          currentPage: 1,
          totalItems: totalItems,
        ),
      );
    } catch (e, stack) {
      dev.log('[NotificationsProvider] build() failed: $e', name: 'Providers', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refresh() async => ref.invalidateSelf();
}

// ─── 9. Filtered Providers ───────────────────────────────────────────────────

// ─── Filter params passed to compute isolate ─────────────────────────────────
class _FilterParams {
  final List<InventoryModel> items;
  final String search;
  final FilterCriteria? filter;
  const _FilterParams(this.items, this.search, this.filter);
}

(List<InventoryModel>, FilterCriteria?) _runInventoryFilter(_FilterParams p) {
  var visible = p.items;

  if (p.search.isNotEmpty) {
    visible = visible.where((item) {
      return item.titleLower.contains(p.search) ||
          item.addressLower.contains(p.search) ||
          item.cityLower.contains(p.search) ||
          item.propertyTypeLower.contains(p.search) ||
          item.subcategoryLower.contains(p.search) ||
          item.projectLower.contains(p.search) ||
          item.price.toString().contains(p.search);
    }).toList();
  }

  final f = p.filter;
  if (f == null || f.isEmpty) return (visible, f);

  final fType = f.type?.toLowerCase();
  final fCat  = f.category?.toLowerCase();
  final fSub  = f.subCategory?.toLowerCase();
  final fLoc  = f.location?.toLowerCase();

  final filtered = visible.where((item) {
    if (fType != null && item.propertyTypeLower != fType) return false;
    if (fCat != null && item.subcategoryLower != fCat && item.categoryLower != fCat) return false;
    if (fSub != null && item.subcategoryLower != fSub && item.projectLower != fSub) return false;
    if (fLoc != null && item.cityLower != fLoc) return false;
    if (f.minPrice != null && item.price < f.minPrice!) return false;
    if (f.maxPrice != null && item.price > f.maxPrice!) return false;
    if (f.isCorner == true) {
      final val = item.attributes['Corner Plot']?.toString().toLowerCase() ?? '';
      if (val != 'yes') return false;
    }
    if (f.facing != null) {
      final raw = item.attributes['Facing']?.toString().trim() ?? '';
      final normalized = _normalizeFacing(raw);
      if (normalized.toLowerCase() != f.facing!.toLowerCase()) return false;
    }
    if (f.minAreaSqYd != null) {
      final sizeStr = item.attributes['Plot Size']?.toString() ?? item.area;
      final areaSqYd = _parseAreaToSqYd(sizeStr);
      if (areaSqYd < f.minAreaSqYd!) return false;
    }
    return true;
  }).toList();

  return (filtered, f);
}

final filteredInventoryProvider =
    Provider<AsyncValue<(List<InventoryModel>, CacheMetadata)>>((ref) {
  final filter = ref.watch(categoryFilterProvider);
  final search = ref.watch(inventorySearchProvider).trim().toLowerCase();
  final asyncList = ref.watch(inventoryProvider);

  return asyncList.whenData((data) {
    final (items, metadata) = data;
    // Fast path — no filter, no search, return as-is without touching the list
    if (search.isEmpty && (filter == null || filter.isEmpty)) {
      return (items, metadata);
    }
    // Synchronous filter — only runs when user actively filters/searches.
    // Safe: items is always the paginated page result (max 20 items per page)
    // so this never causes a main-thread spike regardless of dataset size.
    final (filtered, _) = _runInventoryFilter(_FilterParams(items, search, filter));
    return (filtered, metadata);
  });
});



final filteredLeadProvider =
    Provider<AsyncValue<(List<LeadModel>, CacheMetadata)>>((ref) {
  final query = ref.watch(leadSearchProvider).trim().toLowerCase();
  final asyncList = ref.watch(leadProvider);
  if (query.isEmpty) return asyncList;
  return asyncList.whenData((data) {
    final (items, metadata) = data;
    return (
      items
          .where((item) =>
              item.clientName.toLowerCase().contains(query) ||
              item.phone.toLowerCase().contains(query))
          .toList(),
      metadata,
    );
  });
});

// Normalize facing abbreviations: W→West, E→East, N→North, S→South
String _normalizeFacing(String raw) {
  switch (raw.trim().toUpperCase()) {
    case 'W':  return 'West';
    case 'E':  return 'East';
    case 'N':  return 'North';
    case 'S':  return 'South';
    case 'NE': return 'North-East';
    case 'NW': return 'North-West';
    case 'SE': return 'South-East';
    case 'SW': return 'South-West';
    default:   return raw.isEmpty ? '' : raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }
}

double _parseAreaToSqYd(String areaStr) {
  try {
    final normalized = areaStr.toLowerCase();
    // Match the first number in the string
    final numMatch = RegExp(r'(\d+)').firstMatch(areaStr);
    if (numMatch == null) return 0.0;
    
    final val = double.parse(numMatch.group(1)!);
    
    // Logic: 1 sqyd = 9 sqft
    if (normalized.contains('ft') || normalized.contains('feet')) {
      return val / 9.0;
    }
    // Default to sqyd (standard for your requested filters)
    return val;
  } catch (_) {
    return 0.0;
  }
}
