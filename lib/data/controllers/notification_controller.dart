import 'package:get/get.dart';
import 'package:realestate/data/models/notification_models.dart';

class NotificationController extends GetxController {
  var selectedTab = 0.obs; // 0=All, 1=Review, 2=Sold, 3=House

  // Use RxList for GetX reactivity
  var allNotifications = <NotificationItem>[
    // Today
    NotificationItem(
      id: 1,
      avatar: "https://i.pravatar.cc/150?img=1",
      name: "Chetan Sharma",
      message: "Payment due of ₹2,500. Please pay to avoid penalty.",
      timeAgo: "10 mins ago",
      type: NotifType.payment,
      isToday: true,
    ),
    NotificationItem(
      id: 2,
      avatar: "https://i.pravatar.cc/150?img=2",
      name: "Chetan Sharma",
      message: "Payment due of ₹4,750 for maintenance. Due in 3 days.",
      timeAgo: "40 mins ago",
      propertyImage:
      "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800",
      type: NotifType.payment,
      isToday: true,
    ),
    NotificationItem(
      id: 3,
      avatar: "https://i.pravatar.cc/150?img=3",
      name: "Chetan Sharma",
      message: "Payment due of ₹12,000 for monthly rent. Pay now.",
      timeAgo: "4 hours ago",
      propertyImage:
      "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800",
      type: NotifType.payment,
      isToday: true,
    ),
    // Older
    NotificationItem(
      id: 4,
      avatar: "https://i.pravatar.cc/150?img=5",
      name: "Chetan Sharma",
      message: "Payment due of ₹850 for parking. Please clear the dues.",
      timeAgo: "2 Days ago",
      propertyImage:
      "https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800",
      type: NotifType.payment,
      isToday: false,
    ),
    NotificationItem(
      id: 5,
      avatar: "https://i.pravatar.cc/150?img=7",
      name: "Chetan Sharma",
      message: "Payment due of ₹3,200. Last reminder sent.",
      timeAgo: "3 Days ago",
      type: NotifType.payment,
      isToday: false,
    ),
  ].obs;
}
