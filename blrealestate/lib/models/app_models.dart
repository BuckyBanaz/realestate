// ─── Models ──────────────────────────────────────────────────────────────────
import 'dart:convert';
import '../core/config/app_config.dart';

// ─── Inventory Model ──────────────────────────────────────────────────────────
class InventoryModel {
  final int id;
  final String title;
  final String? image;
  final double price;
  final String status;
  final String area;
  final String? address;
  final String? city;
  final String? propertyType;
  final String? category;
  final String? subcategory;
  final String? project;
  final int? categoryId;
  final int? subcategoryId;
  final int? subSubcategoryId;
  final Map<String, dynamic> attributes;
  final List<dynamic> amenities;
  final String? heldUntil;
  final int? heldBy;
  final double? latitude;
  final double? longitude;
  final String? description;
  final Map<String, dynamic>? activeHold;
  final List<String> images;
  // Computed once at parse time — avoids DateTime.now() + DateTime.parse()
  // on every card build (was called 40–80× per page render during scroll).
  final String displayStatus;

  const InventoryModel({
    required this.id,
    required this.title,
    this.image,
    required this.price,
    required this.status,
    required this.area,
    this.address,
    this.city,
    this.propertyType,
    this.category,
    this.subcategory,
    this.project,
    this.categoryId,
    this.subcategoryId,
    this.subSubcategoryId,
    required this.attributes,
    required this.amenities,
    this.heldUntil,
    this.heldBy,
    this.latitude,
    this.longitude,
    this.description,
    this.activeHold,
    this.images = const [],
    required this.displayStatus,
  });

  /// Computes displayStatus from raw fields — called once inside fromJson.
  static String computeDisplayStatus({
    required String status,
    required Map<String, dynamic>? activeHold,
    required int? heldBy,
    required String? heldUntil,
  }) {
    final s = status.toLowerCase().trim();
    if (s == 'sold' || s == 'booked' || s == 'sold out') return 'SOLD';
    if (s == 'hold' || s == 'held' || s == 'on hold' || s == 'blocked') return 'HOLD';

    if (activeHold != null && activeHold.isNotEmpty) {
      final holdStatus = activeHold['status']?.toString().toLowerCase() ?? '';
      if (holdStatus == 'active' || holdStatus == 'pending') {
        final holdUntil = activeHold['hold_until']?.toString() ?? '';
        if (holdUntil.isNotEmpty) {
          try {
            final expiry = DateTime.parse(holdUntil);
            if (expiry.isAfter(DateTime.now())) return 'HOLD';
          } catch (_) {
            return 'HOLD';
          }
        } else {
          return 'HOLD';
        }
      }
    }

    if (heldBy != null && heldBy > 0) {
      if (heldUntil != null && heldUntil.isNotEmpty) {
        try {
          final expiry = DateTime.parse(heldUntil);
          if (expiry.isAfter(DateTime.now())) return 'HOLD';
        } catch (_) {
          return 'HOLD';
        }
      } else {
        return 'HOLD';
      }
    }

    return 'ACTIVE';
  }

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    final catData  = json['category']         is Map ? json['category']         : null;
    final subData  = json['subcategory']       is Map ? json['subcategory']       : null;
    final ssubData = json['sub_subcategory']   is Map ? json['sub_subcategory']   : null;
    final type = _extractPropertyType(json);

    String? category    = _normalizeName(catData?['name']);
    String? subcategory = _normalizeName(subData?['name']);
    String? project     = _normalizeName(ssubData?['name']);

    final mainImg = json['main_image'] ?? json['main_image_url'] ?? json['image'];
    final catImg  = catData?['image'];

    String? image;
    if (mainImg != null) {
      image = _normalizeImage(mainImg, isCategory: false);
    } else if (catImg != null) {
      image = _normalizeImage(catImg, isCategory: true);
    }

    // Parse images array from backend
    final rawImages = json['images'];
    final List<String> images = [];

    // Always add main_image first
    if (image != null && image.isNotEmpty) images.add(image);

    // Then add gallery images (images[].image) — deduplicate by filename
    if (rawImages is List) {
      for (final img in rawImages) {
        String? url;
        if (img is Map) {
          final src = img['image'] ?? img['url'] ?? img['image_url'] ?? img['path'];
          if (src != null) url = _normalizeImage(src.toString(), isCategory: false);
        } else if (img is String && img.isNotEmpty) {
          url = _normalizeImage(img, isCategory: false);
        }
        if (url == null || url.isEmpty) continue;
        // Deduplicate by comparing filenames — handles http vs https,
        // different base paths, or trailing slash mismatches
        final newFile = url.split('/').last.split('?').first;
        final alreadyAdded = images.any(
          (u) => u.split('/').last.split('?').first == newFile,
        );
        if (!alreadyAdded) images.add(url);
      }
    }

    final rawStatus   = json['status'] ?? 'active';
    final rawHeldBy   = parseInt(json['held_by']);
    final rawHeldUntil = json['held_until'] as String?;
    final rawActiveHold = json['active_hold'] is Map
        ? Map<String, dynamic>.from(json['active_hold'])
        : null;

    return InventoryModel(
      id:               json['id'] ?? 0,
      title:            json['title'] ?? 'Property',
      image:            image,
      price:            double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      status:           rawStatus,
      area:             json['area'] ?? '',
      address:          json['address'],
      city:             json['city'],
      propertyType:     type,
      category:         category,
      subcategory:      subcategory,
      project:          project,
      categoryId:       parseInt(json['category_id']),
      subcategoryId:    parseInt(json['subcategory_id']),
      subSubcategoryId: parseInt(json['sub_subcategory_id']),
      attributes:       _parseAttributes(json['attributes']),
      amenities:        _parseAmenities(json['amenities']),
      heldUntil:        rawHeldUntil,
      heldBy:           rawHeldBy,
      latitude:         double.tryParse(json['latitude']?.toString() ?? ''),
      longitude:        double.tryParse(json['longitude']?.toString() ?? ''),
      description:      json['description']?.toString(),
      activeHold:       rawActiveHold,
      images:           images,
      displayStatus:    computeDisplayStatus(
        status:     rawStatus,
        activeHold: rawActiveHold,
        heldBy:     rawHeldBy,
        heldUntil:  rawHeldUntil,
      ),
    );
  }

  static int? parseInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '');
  static double? parseDouble(dynamic v) => v is double ? v : double.tryParse(v?.toString() ?? '');

  InventoryModel copyWith({
    int? id,
    String? title,
    String? image,
    List<String>? images,
    double? price,
    String? status,
    String? area,
    String? address,
    String? city,
    String? propertyType,
    String? category,
    String? subcategory,
    String? project,
    int? categoryId,
    int? subcategoryId,
    int? subSubcategoryId,
    Map<String, dynamic>? attributes,
    List<dynamic>? amenities,
    String? heldUntil,
    int? heldBy,
    double? latitude,
    double? longitude,
    String? description,
    Map<String, dynamic>? activeHold,
    String? displayStatus,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      images: images ?? this.images,
      price: price ?? this.price,
      status: status ?? this.status,
      area: area ?? this.area,
      address: address ?? this.address,
      city: city ?? this.city,
      propertyType: propertyType ?? this.propertyType,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      project: project ?? this.project,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subSubcategoryId: subSubcategoryId ?? this.subSubcategoryId,
      attributes: attributes ?? this.attributes,
      amenities: amenities ?? this.amenities,
      heldUntil: heldUntil ?? this.heldUntil,
      heldBy: heldBy ?? this.heldBy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      activeHold: activeHold ?? this.activeHold,
      displayStatus: displayStatus ?? this.displayStatus,
    );
  }

  /// Handles amenities as List or JSON-encoded string "[]"
  static List<dynamic> _parseAmenities(dynamic raw) {
    if (raw is List) return List<dynamic>.from(raw);
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is List) return List<dynamic>.from(decoded);
      } catch (_) {}
    }
    return [];
  }

  /// Handles attributes as Map or array [{attribute, value}]
  static Map<String, dynamic> _parseAttributes(dynamic raw) {
    if (raw is Map<String, dynamic>) return Map<String, dynamic>.from(raw);
    if (raw is List) {
      final map = <String, dynamic>{};
      for (final item in raw) {
        if (item is Map) {
          final key = item['attribute']?.toString();
          final val = item['value'];
          if (key != null && key.isNotEmpty && val != null) map[key] = val;
        }
      }
      return map;
    }
    return {};
  }

  // ── Pre-computed lowercase getters for fast filtering ──────────────────────
  String get titleLower => title.toLowerCase();
  String get addressLower => address?.toLowerCase() ?? '';
  String get cityLower => city?.toLowerCase() ?? '';
  String get propertyTypeLower => propertyType?.toLowerCase() ?? '';
  String get subcategoryLower => subcategory?.toLowerCase() ?? '';
  String get projectLower => project?.toLowerCase() ?? '';
  String get categoryLower => category?.toLowerCase() ?? '';

  /// Returns HOLD only if THIS user (by userId) is the one holding it.
  /// Used by MyHoldingsScreen to show only the current user's holds.
  String displayStatusForUser(int? userId) {
    if (userId == null) return displayStatus;

    // Check active_hold belongs to this user
    if (activeHold != null && activeHold!.isNotEmpty) {
      final holdStatus = activeHold!['status']?.toString().toLowerCase() ?? '';
      final holdUserId = activeHold!['user_id'];
      final holdUserIdInt = holdUserId is int ? holdUserId : int.tryParse(holdUserId?.toString() ?? '');
      if (holdStatus == 'active' && holdUserIdInt == userId) {
        final holdUntil = activeHold!['hold_until']?.toString() ?? '';
        if (holdUntil.isNotEmpty) {
          try {
            final expiry = DateTime.parse(holdUntil);
            if (expiry.isAfter(DateTime.now())) return 'HOLD';
          } catch (_) {
            return 'HOLD';
          }
        } else {
          return 'HOLD';
        }
      }
    }

    return displayStatus;
  }
}

// ─── Deal Model ───────────────────────────────────────────────────────────────
class DealModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final double amount;
  final String date;
  final String createdAt;      // Required by UI
  final String? bannerImage;   // Required by UI
  final String propertyTitle;  // Required by UI
  final InventoryModel? property;

  const DealModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.amount,
    required this.date,
    required this.createdAt,
    this.bannerImage,
    required this.propertyTitle,
    this.property,
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    final dateVal = json['created_at'] ?? '';
    final prop = json['property'] is Map<String, dynamic> ? InventoryModel.fromJson(json['property'] as Map<String, dynamic>) : null;
    
    return DealModel(
      id:           json['id'] ?? 0,
      title:        json['title'] ?? 'Deal',
      description:  json['description'] ?? '',
      status:       json['status'] ?? 'pending',   // backend sends status
      amount:       double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      date:         dateVal,
      createdAt:    dateVal,
      bannerImage:  _normalizeImage(json['banner_image'] ?? json['image'] ?? (prop?.image), isCategory: false),
      propertyTitle: prop?.title ?? json['property_title']?.toString() ?? 'Associated Property',
      property:     prop,
    );
  }
}

// ─── Task Model ───────────────────────────────────────────────────────────────
class TaskModel {
  final int id;
  final String title;
  final String description;
  final String dueDate;
  final String status;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['due_date'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }
}

// ─── Lead Model ───────────────────────────────────────────────────────────────
class LeadModel {
  final int id;
  final String name;
  final String clientName;
  final String phone;
  final String? email;
  final String? address;
  final String? message;
  final String status;
  final String? propertyTitle;
  final String date;
  final String meetingDate;
  final double? paymentReceived;
  final double? pendingPayment;

  const LeadModel({
    required this.id,
    required this.name,
    required this.clientName,
    required this.phone,
    this.email,
    this.address,
    this.message,
    required this.status,
    this.propertyTitle,
    required this.date,
    required this.meetingDate,
    this.paymentReceived,
    this.pendingPayment,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    final nameVal = json['name'] ?? 'Unknown';
    final dateVal = json['created_at'] ?? '';
    final prop = json['property'];
    return LeadModel(
      id:             json['id'] ?? 0,
      name:           nameVal,
      clientName:     nameVal,
      phone:          json['phone'] ?? json['mobile'] ?? json['mobile_no'] ?? '',
      email:          json['email'],
      address:        json['address'],
      message:        json['message'],
      status:         json['status'] ?? 'new',
      propertyTitle:  prop is Map ? (prop['title'] ?? prop['name']) : (prop?.toString()),
      date:           dateVal,
      meetingDate:    json['appointment_date'] ?? dateVal,
      paymentReceived: double.tryParse(json['payment_received']?.toString() ?? ''),
      pendingPayment:  double.tryParse(json['pending_payment']?.toString() ?? ''),
    );
  }
}

// ─── Commission Model ─────────────────────────────────────────────────────────
class CommissionModel {
  final int id;
  final String propertyTitle;
  final double amount;
  final String commissionType;
  final String commissionPercentage;
  final String remarks;
  final String date;
  final String status;

  const CommissionModel({
    required this.id,
    required this.propertyTitle,
    required this.amount,
    required this.commissionType,
    required this.commissionPercentage,
    required this.remarks,
    required this.date,
    required this.status,
  });

  /// Extracts the commission percentage from the remarks string.
  /// Handles both formats:
  ///   "Base: 1% of ₹1,250,000.00 = ..."
  ///   "Commission generated at 2.50% on selling price ..."
  /// Returns 0.0 if not found.
  double get percentageFromRemarks {
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*%').firstMatch(remarks);
    if (match == null) return 0.0;
    return double.tryParse(match.group(1) ?? '0') ?? 0.0;
  }

  factory CommissionModel.fromJson(Map<String, dynamic> json) {
    final prop = json['property'];
    final payoutStatus = json['payout_status']?.toString() ?? json['status']?.toString() ?? 'unpaid';
    return CommissionModel(
      id:                   json['id'] ?? 0,
      propertyTitle:        prop is Map
          ? (prop['title']?.toString() ?? 'Property')
          : 'Property',
      amount:               double.tryParse(
                              (json['commission_amount'] ?? json['amount'])?.toString() ?? '0'
                            ) ?? 0.0,
      commissionType:       json['commission_type']?.toString() ?? '',
      commissionPercentage: json['commission_percentage']?.toString() ?? '0',
      remarks:              json['remarks']?.toString() ?? '',
      date:                 json['created_at']?.toString() ?? '',
      status:               payoutStatus,
    );
  }
}

// ─── Notification Model ───────────────────────────────────────────────────────
class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String time;
  final String createdAt;   // Non-nullable for UI
  final String type;        // Non-nullable for UI
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.createdAt,
    required this.type,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final timeVal = json['created_at'] ?? '';
    final isReadVal = json['is_read'] ?? json['isRead'];
    
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Notification',
      body: json['body'] ?? json['message'] ?? '',
      time: timeVal,
      createdAt: timeVal,
      type: json['type'] ?? 'info',
      isRead: (isReadVal == true || isReadVal == 1 || json['read_at'] != null),
    );
  }
}

String? _normalizeImage(dynamic value, {bool isCategory = false}) {
  if (value == null) return null;
  final s = value.toString();
  if (s.isEmpty || s == 'null' || s == 'undefined') return null;
  
  // If it's already a full URL, just return it
  if (s.startsWith('http://') || s.startsWith('https://')) return s;
  
  // If it's a relative path, prepend the base URL from AppConfig (HTTPS)
  const propertyBase = AppConfig.propertyImageBase;
  const categoryBase = AppConfig.categoryImageBase;

  // Use category base if it's a category image, otherwise use property base
  return isCategory ? '$categoryBase$s' : '$propertyBase$s';
}

final _nameCache = <String, String>{};

void clearNameCache() => _nameCache.clear();

String? _normalizeName(String? s) {
  if (s == null || s.isEmpty) return null;
  
  final name = s.trim();
  if (name.isEmpty) return null;
  
  if (_nameCache.containsKey(name)) {
    return _nameCache[name]!;
  }

  final lower = name.toLowerCase();
  if (lower == 'null' || lower == 'none') return null;

  String result;
  if (lower == 'plot' || lower == 'plots') {
    result = 'Plots';
  } else if (lower == 'farmhouse' || lower == 'farmhouses' ||
             lower == 'farm house' || lower == 'farm houses' ||
             lower == 'farmhome' || lower == 'farm home' || lower == 'farm homes') {
    result = 'Farmhouses';
  } else if (lower == 'flats-housing' || lower == 'flats housing' ||
             lower == 'flat-housing' || lower == 'flat housing' ||
             lower == 'flats' || lower == 'housing') {
    result = 'Flats-Housing';
  } else if (lower == 'agricultural land' || lower == 'agricultural' ||
             lower == 'agriculture' || lower == 'agri land' ||
             lower == 'agricultural lands') {
    result = 'Agricultural Land';
  } else if (lower == 'township' || lower == 'townships') {
    result = 'Township';
  } else if (lower == 'society' || lower == 'societies') {
    result = 'Society';
  } else if (lower == 'residential') {
    result = 'Residential';
  } else if (lower == 'commercial') {
    result = 'Commercial';
  } else if (lower == 'industrial') {
    result = 'Industrial';
  } else {
    result = name[0].toUpperCase() + name.substring(1);
  }

  // Safety cap: evict all entries if cache grows beyond 300 unique names.
  // Realistic max from 276 items is well under 100, but this guards against
  // server sending garbage data that would grow the map unboundedly.
  if (_nameCache.length >= 300) _nameCache.clear();
  _nameCache[name] = result;
  return result;
}

String _extractPropertyType(Map<String, dynamic> json) {
  // Priority 1: category.name — most reliable grouping from backend
  // e.g. category='Plots' covers property_type='Residential'+'Plot'+'None'
  final cat = json['category'];
  if (cat is Map && cat['name'] != null) {
    final catName = cat['name'].toString().trim();
    if (catName.isNotEmpty && catName.toLowerCase() != 'null') {
      return _normalizeName(catName) ?? 'Other';
    }
  }

  // Priority 2: property_type field (fallback when category is null)
  final rawType = (json['property_type'] ?? json['type'])?.toString();
  if (rawType != null && rawType.isNotEmpty &&
      rawType.toLowerCase() != 'null' && rawType.toLowerCase() != 'none') {
    return _normalizeName(rawType) ?? 'Other';
  }

  return 'Other';
}

// ─── Filter Criteria ─────────────────────────────────────────────────────────
class FilterCriteria {
  final String? type;
  final String? category;
  final String? subCategory;
  final String? location;
  final double? minPrice;
  final double? maxPrice;
  final bool? isCorner;
  final String? facing;
  final double? minAreaSqYd;

  FilterCriteria({
    this.type,
    this.category,
    this.subCategory,
    this.location,
    this.minPrice,
    this.maxPrice,
    this.isCorner,
    this.facing,
    this.minAreaSqYd,
  });

  bool get isEmpty =>
      type == null &&
      category == null &&
      subCategory == null &&
      location == null &&
      minPrice == null &&
      maxPrice == null &&
      isCorner == null &&
      facing == null &&
      minAreaSqYd == null;

  FilterCriteria copyWith({
    String? type,
    String? category,
    String? subCategory,
    String? location,
    double? minPrice,
    double? maxPrice,
    bool? isCorner,
    String? facing,
    double? minAreaSqYd,
    // Explicit clear flags for nullable fields that can't be nulled via ?? pattern
    bool clearType = false,
    bool clearCategory = false,
    bool clearSubCategory = false,
    bool clearLocation = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearIsCorner = false,
    bool clearFacing = false,
    bool clearMinAreaSqYd = false,
  }) {
    return FilterCriteria(
      type:         clearType        ? null : (type        ?? this.type),
      category:     clearCategory    ? null : (category    ?? this.category),
      subCategory:  clearSubCategory ? null : (subCategory ?? this.subCategory),
      location:     clearLocation    ? null : (location    ?? this.location),
      minPrice:     clearMinPrice    ? null : (minPrice    ?? this.minPrice),
      maxPrice:     clearMaxPrice    ? null : (maxPrice    ?? this.maxPrice),
      isCorner:     clearIsCorner    ? null : (isCorner    ?? this.isCorner),
      facing:       clearFacing      ? null : (facing      ?? this.facing),
      minAreaSqYd:  clearMinAreaSqYd ? null : (minAreaSqYd ?? this.minAreaSqYd),
    );
  }
}
