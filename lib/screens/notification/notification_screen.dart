import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';

// ====================== CONTROLLER ======================
class NotificationController extends GetxController {
  var selectedTab = 0.obs; // 0=All, 1=Review, 2=Sold, 3=House

  final List<NotificationItem> allNotifications = [
    // Today
    NotificationItem(
      id: 1,
      avatar: "https://i.pravatar.cc/150?img=1",
      name: "Emmet Perry",
      message: "Just messaged you. Check the message in message tab.",
      timeAgo: "10 mins ago",
      type: NotifType.message,
      isToday: true,
    ),
    NotificationItem(
      id: 2,
      avatar: "https://i.pravatar.cc/150?img=2",
      name: "Geraldo",
      message: "Just giving 5 Star review on your listing Fairview Apartment",
      timeAgo: "40 mins ago",
      propertyImage: "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800",
      type: NotifType.review,
      isToday: true,
    ),
    NotificationItem(
      id: 3,
      avatar: "https://i.pravatar.cc/150?img=3",
      name: "Walter Lindsey",
      message: "Just buy your listing Schoolview House",
      timeAgo: "4 hours ago",
      propertyImage: "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800",
      type: NotifType.sold,
      isToday: true,
    ),
    // Older
    NotificationItem(
      id: 4,
      avatar: "https://i.pravatar.cc/150?img=5",
      name: "Velma Cole",
      message: "Just favorited your listing Schoolview House",
      timeAgo: "2 Days ago",
      propertyImage: "https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800",
      type: NotifType.favorite,
      isToday: false,
    ),
    NotificationItem(
      id: 5,
      avatar: "https://i.pravatar.cc/150?img=7",
      name: "Sarah Johnson",
      message: "Just messaged you about Downtown Villa",
      timeAgo: "3 Days ago",
      type: NotifType.message,
      isToday: false,
    ),
  ].obs;
}

// Model
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

enum NotifType { message, review, sold, favorite }

// ====================== MAIN SCREEN ======================
class NotificationScreen extends StatelessWidget {
  final NotificationController controller = Get.put(NotificationController());

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: _circleIconButton(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16),
        //     child: _circleIconButton(IconlyLight.delete, () {}),
        //   ),
        // ],
        title: Text(
          "Notification",
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Tabs: All, Review, Sold, House
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() => Row(
                  children: [
                    _tabButton("All", 0),
                    _tabButton("Review", 1),
                    _tabButton("Sold", 2),
                    _tabButton("House", 3),
                  ],
                )),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      body: Obx(() {
        final notifications = controller.allNotifications;

        final todayNotifs = notifications.where((n) => n.isToday).toList();
        final olderNotifs = notifications.where((n) => !n.isToday).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            // Today Section
            if (todayNotifs.isNotEmpty) ...[
              Text(
                "Today",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              ...todayNotifs.map((notif) => NotificationTile(item: notif)).toList(),
              const SizedBox(height: 30),
            ],

            // Older Notifications
            Text(
              "Older notifications",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ...olderNotifs.map((notif) => NotificationTile(item: notif)).toList(),
            const SizedBox(height: 30),
          ],
        );
      }),
    );
  }

  Widget _tabButton(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTab.value = index,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: controller.selectedTab.value == index
                  ? secondary
                  : cardColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: controller.selectedTab.value == index
                    ? Colors.white
                    : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: secondary),
      ),
    );
  }
}

// ====================== NOTIFICATION TILE ======================
// ====================== NOTIFICATION TILE WITH SWIPE DELETE ======================
class NotificationTile extends StatelessWidget {
  final NotificationItem item;

  const NotificationTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(item.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: secondary, // Deep blue like image
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 28),
          child: const Icon(
            IconlyLight.delete,
            color: Colors.white,
            size: 28,
          ),
        ),
        onDismissed: (direction) {
          // Remove from list (GetX auto rebuild)
          Get.find<NotificationController>()
              .allNotifications
              .removeWhere((e) => e.id == item.id);

          // Get.snackbar(
          //   "Deleted",
          //   "Notification removed",
          //   backgroundColor: Colors.grey[800],
          //   colorText: Colors.white,
          //   snackPosition: SnackPosition.BOTTOM,
          //   margin: const EdgeInsets.all(20),
          //   borderRadius: 12,
          // );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(item.avatar),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Property Image
              if (item.propertyImage != null) ...[
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.propertyImage!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}