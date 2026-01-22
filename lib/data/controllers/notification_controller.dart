import 'package:get/get.dart';
import 'package:realestate/data/models/notification_models.dart';
import 'package:realestate/domain/api/api_client.dart';

class NotificationController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  var isLoading = false.obs;
  var unreadCount = 0.obs;
  var allNotifications = <NotificationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get('customer/notifications');

      if (response.statusCode == 200) {
        final notifResponse = NotificationResponse.fromJson(response.data);
        allNotifications.value = notifResponse.data;
        unreadCount.value = notifResponse.unreadCount;
      }
    } catch (e) {
      print('Notification Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiClient.dio.post('customer/notifications/$notificationId/read');
      // Update local state
      final index = allNotifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updatedNotif = NotificationItem(
          id: allNotifications[index].id,
          title: allNotifications[index].title,
          body: allNotifications[index].body,
          type: allNotifications[index].type,
          isRead: true,
          createdAt: allNotifications[index].createdAt,
        );
        allNotifications[index] = updatedNotif;
        if (unreadCount.value > 0) unreadCount.value--;
      }
    } catch (e) {
      print('Mark as read error: $e');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await _apiClient.dio.delete(
        'customer/notifications/$notificationId',
      );
      if (response.statusCode == 200) {
        allNotifications.removeWhere((n) => n.id == notificationId);
      }
    } catch (e) {
      print('Delete notification error: $e');
    }
  }

  List<NotificationItem> get todayNotifications =>
      allNotifications.where((n) => _isToday(n.createdAt)).toList();

  List<NotificationItem> get olderNotifications =>
      allNotifications.where((n) => !_isToday(n.createdAt)).toList();

  bool _isToday(String dateStr) {
    try {
      final now = DateTime.now();
      // Check if the date string contains "today" or matches today's date
      if (dateStr.toLowerCase().contains('today')) return true;

      // Parse the date from format like "16 Jan 2026, 04:56 AM"
      // For simplicity, check if it's within last 24 hours
      return dateStr.contains(
        '${now.day} ${_getMonthName(now.month)} ${now.year}',
      );
    } catch (e) {
      return false;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
