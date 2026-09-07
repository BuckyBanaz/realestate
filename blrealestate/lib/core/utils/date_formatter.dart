/// Centralized date formatter — all screens use this.
/// Input: ISO string like "2026-04-25T17:22:13.000000Z" or "2026-04-25"
/// Output: "25 April 2026"
class DateFormatter {
  static const _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static String format(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day} ${_months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  /// "25 April 2026, 5:22 PM"
  static String formatWithTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final hour   = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${_months[dt.month]} ${dt.year}, $hour:$minute $period';
    } catch (_) {
      return raw;
    }
  }
}
