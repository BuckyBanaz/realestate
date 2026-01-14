import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:realestate/data/controllers/notification_controller.dart';
import 'package:realestate/data/models/notification_models.dart';

// ====================== MAIN SCREEN ======================
// ====================== MAIN SCREEN ======================
class NotificationScreen extends StatelessWidget {
  final NotificationController controller = Get.put(NotificationController());

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: circleIconButton(context, Icons.arrow_back_ios_new_rounded, () => Get.back()),
        title: Text(
          "Notification",
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color),
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
                  color: Theme.of(context).textTheme.bodyLarge?.color,
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
                color: Theme.of(context).textTheme.bodyLarge?.color,
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



}

// ====================== NOTIFICATION TILE ======================
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
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey.shade800 
                  : const Color(0xFFE5E7EB), 
              width: 1
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                child: Icon(IconlyLight.profile, color: Theme.of(context).iconTheme.color),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                // backgroundImage: NetworkImage(item.avatar),
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
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
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
