import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_providers.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final name = profile.maybeWhen(
      data: (d) => d['name'] as String? ?? AppStrings.partnerDefault,
      orElse: () => AppStrings.partnerDefault,
    );

    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.surfaceLight, fontWeight: FontWeight.w900),
    );
  }
}
