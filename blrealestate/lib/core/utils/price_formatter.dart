class PriceFormatter {
  static String formatFull(double price) {
    // 1. Get the basic 2-decimal string (e.g., 1000.00)
    String priceStr = price.toStringAsFixed(2);
    List<String> parts = priceStr.split('.');
    String whole = parts[0];
    String decimal = parts[1];

    // 2. Handle Indian comma formatting (e.g., 12,34,567)
    if (whole.length > 3) {
      String lastThree = whole.substring(whole.length - 3);
      String remaining = whole.substring(0, whole.length - 3);
      
      // Add commas every 2 digits for Indian system
      final reg = RegExp(r'\B(?=(\d{2})+(?!\d))');
      remaining = remaining.replaceAll(reg, ',');
      
      whole = '$remaining,$lastThree';
    }

    return '$whole.$decimal';
  }

  static String formatWithRupee(double price) {
    return '₹${formatFull(price)}';
  }

  static String format(double price) => formatFull(price);

  /// Compact format for small cards — e.g. 5815999 → "58.2L", 100000 → "1L", 999 → "999"
  static String formatCompact(double price) {
    if (price >= 10000000) {
      // Crore
      final cr = price / 10000000;
      return '${_trim(cr)}Cr';
    } else if (price >= 100000) {
      // Lakh
      final lk = price / 100000;
      return '${_trim(lk)}L';
    } else if (price >= 1000) {
      // Thousand
      final k = price / 1000;
      return '${_trim(k)}K';
    }
    return price.toInt().toString();
  }

  static String _trim(double v) {
    // Show 1 decimal only if needed — e.g. 58.0 → "58", 58.2 → "58.2"
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}
