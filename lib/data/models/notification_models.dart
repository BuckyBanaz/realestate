enum NotifType { message, review, sold, favorite, payment }

class NotificationItem {
  final int id;
  final String avatar;
  final String name;
  final String message;
  final String timeAgo;
  final String? propertyImage;
  final NotifType type;
  final bool isToday;

  NotificationItem({
    required this.id,
    required this.avatar,
    required this.name,
    required this.message,
    required this.timeAgo,
    this.propertyImage,
    required this.type,
    required this.isToday,
  });
}
