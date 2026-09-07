import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../widgets/earnings_tab.dart';

class CommissionScreen extends ConsumerStatefulWidget {
  const CommissionScreen({super.key});

  @override
  ConsumerState<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends ConsumerState<CommissionScreen> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const SizedBox.shrink(),
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            centerTitle: false,
            toolbarHeight: 64,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MY EARNINGS',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.surfaceLight.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
                ),
                Text(
                  'Commissions',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.surfaceLight, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: AppColors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
          ),
        ],
        body: const EarningsTab(),
      ),
    );
  }
}
