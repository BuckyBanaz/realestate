import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:realestate/data/controllers/notification_controller.dart';
import 'package:realestate/data/models/notification_models.dart';

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
          "Notifications",
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        actions: [
          Obx(() => controller.unreadCount.value > 0
              ? Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: secondary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${controller.unreadCount.value} new',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.allNotifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(IconlyLight.notification, size: 80.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text(
                  'No notifications yet',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final todayNotifs = controller.todayNotifications;
        final olderNotifs = controller.olderNotifications;

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            children: [
              // Today Section
              if (todayNotifs.isNotEmpty) ...[
                Text(
                  "Today",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: 12.h),
                ...todayNotifs.map((notif) => NotificationTile(item: notif)).toList(),
                SizedBox(height: 30.h),
              ],

              // Older Notifications
              if (olderNotifs.isNotEmpty) ...[
                Text(
                  "Older notifications",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: 12.h),
                ...olderNotifs.map((notif) => NotificationTile(item: notif)).toList(),
                SizedBox(height: 30.h),
              ],
            ],
          ),
        );
      }),
    );
  }
}

// ====================== NOTIFICATION TILE ======================
class NotificationTile extends StatelessWidget {
  final NotificationItem item;

  const NotificationTile({super.key, required this.item});

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return IconlyBold.wallet;
      case 'property':
        return IconlyBold.home;
      case 'document':
        return IconlyBold.document;
      case 'visit':
        return IconlyBold.calendar;
      case 'offer':
        return IconlyBold.discount;
      case 'alert':
        return IconlyBold.danger;
      case 'inquiry':
        return IconlyBold.message;
      default:
        return IconlyBold.notification;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return Colors.green;
      case 'property':
        return primary;
      case 'document':
        return Colors.blue;
      case 'visit':
        return Colors.orange;
      case 'offer':
        return secondary;
      case 'alert':
        return Colors.red;
      case 'inquiry':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Dismissible(
        key: Key(item.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20.r),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 28.w),
          child: Icon(
            IconlyLight.delete,
            color: Colors.white,
            size: 28.sp,
          ),
        ),
        onDismissed: (direction) {
          Get.find<NotificationController>().deleteNotification(item.id);
        },
        child: GestureDetector(
          onTap: () {
            if (!item.isRead) {
              Get.find<NotificationController>().markAsRead(item.id);
            }
          },
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: item.isRead 
                  ? Theme.of(context).cardColor 
                  : Theme.of(context).cardColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: item.isRead
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : const Color(0xFFE5E7EB))
                    : secondary.withOpacity(0.3),
                width: item.isRead ? 1 : 2,
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
                // Icon Avatar
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: _getColorForType(item.type).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(item.type),
                    color: _getColorForType(item.type),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 14.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.body,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        item.createdAt,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
