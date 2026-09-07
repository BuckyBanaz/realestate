import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.surfaceLight, fontWeight: FontWeight.w500),
          ),
          backgroundColor: isError
              ? AppColors.error
              : isSuccess
                  ? AppColors.success
                  : AppColors.textPrimary(context),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.45,
            left: 24,
            right: 24,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: duration,
        ),
      );
  }

  static void error(BuildContext context, String message) =>
      show(context, message, isError: true);

  static void success(BuildContext context, String message) =>
      show(context, message, isSuccess: true);
}
