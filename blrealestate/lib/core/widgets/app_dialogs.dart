import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppDialogs {
  /// Shows when user has no commission or percentage < 1.
  /// [percentage] — the extracted percentage from remarks (0.0 if none).
  static void showNotAuthorized(BuildContext context, {double percentage = 0.0}) {
    final hasPercentage = percentage > 0;
    final message = hasPercentage
        ? 'Your current commission rate is ${percentage.toStringAsFixed(2)}%, which is less than 1%.\n\nYou are not eligible to hold properties. Please contact your admin to update your commission rate.'
        : 'You do not have a commission assigned to your account.\n\nPlease contact your admin to assign a commission before holding properties.';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.block_rounded, color: AppColors.error),
            SizedBox(width: 10),
            Text('Not Eligible to Hold'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
