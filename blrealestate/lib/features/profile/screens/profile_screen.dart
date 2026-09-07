import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_web_view.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/widgets/full_screen_image.dart';
import '../../../core/utils/safe_cache_manager.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../auth/screens/login_screen.dart';
import 'edit_profile_screen.dart';
import '../../dashboard/screens/my_holdings_screen.dart';
import '../../../providers/nav_providers.dart';
// import 'documents_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
      return const _LoadingView();
    }
    final themeAsync = ref.watch(themeProvider);
    final isDark = themeAsync.maybeWhen(
      data: (mode) => mode == ThemeMode.dark,
      orElse: () => false,
    );
    final profileAsync = ref.watch(profileProvider);

    // Responsive expanded height
    final screenHeight = MediaQuery.of(context).size.height;
    final expandedHeight = (screenHeight * 0.35).clamp(260.0, 340.0);

    return profileAsync.when(
      skipLoadingOnReload: true,
      loading: () => const _LoadingView(),
      error: (e, _) => _ErrorView(
        message: AppStrings.couldNotLoadProfile,
        onRetry: () => ref.read(profileProvider.notifier).refresh(),
      ),
      data: (profile) => RefreshIndicator(
        onRefresh: () async => ref.read(profileProvider.notifier).refresh(),
        child: _ProfileScaffold(
          profile: profile,
          isDark: isDark,
          expandedHeight: expandedHeight,
          onToggleTheme: () {
            HapticFeedback.lightImpact();
            ref.read(themeProvider.notifier).toggleTheme();
          },
          onLogout: () async {
            HapticFeedback.mediumImpact();
            try {
              // Reset nav to Home tab
              ref.read(bottomNavIndexProvider.notifier).state = 0;
              // Invalidate all cached providers so next user gets fresh data
              // Providers watch authProvider, so logging out cascades naturally.
              // Logout (clears token)
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            }
          },
        ),
      ),
    );
  }
}

// ─── Main Scaffold ────────────────────────────────────────────────────────────
class _ProfileScaffold extends ConsumerWidget {
  final Map<String, dynamic> profile;
  final bool isDark;
  final double expandedHeight;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const _ProfileScaffold({
    required this.profile,
    required this.isDark,
    required this.expandedHeight,
    required this.onToggleTheme,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final hPad = size.width < 360 ? 16.0 : 20.0;

    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildAppBar(context, ref),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 60),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionHeader(context, AppStrings.preferences),
                _row(
                  context,
                  Icons.dark_mode_outlined,
                  AppStrings.darkMode,
                  Switch.adaptive(
                    value: isDark,
                    activeTrackColor: AppColors.primary,
                    onChanged: (_) => onToggleTheme(),
                  ),
                ),
                const Divider(height: 32),
                _sectionHeader(context, AppStrings.accountDetails),
                _row(
                  context,
                  Icons.phone_android,
                  AppStrings.mobile,
                  Text(
                    profile['mobile'] ?? profile['mobile_no'] ?? 'N/A',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _row(
                  context,
                  Icons.work_outline,
                  AppStrings.role,
                  const Text(AppStrings.roleValue),
                ),
                _row(
                  context,
                  Icons.verified_outlined,
                  AppStrings.status,
                  Text(
                    profile['status'] ?? 'Active',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                  ),
                ),
                // Commission rate — extracted from remarks key of latest commission entry
                Builder(builder: (context) {
                  final commissionAsync = ref.watch(commissionProvider);
                  final percentage = commissionAsync.maybeWhen(
                    data: (data) {
                      final list = data.$1;
                      if (list.isEmpty) return null;
                      // Find the highest percentage across all entries (from remarks)
                      final max = list.fold<double>(
                        0.0,
                        (m, c) => c.percentageFromRemarks > m ? c.percentageFromRemarks : m,
                      );
                      return max > 0 ? max : null;
                    },
                    orElse: () => null,
                  );
                  if (percentage == null) return const SizedBox.shrink();
                  return _row(
                    context,
                    Icons.percent_rounded,
                    'Commission Rate',
                    Text(
                      '${percentage.toStringAsFixed(2)}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: percentage >= 1.0 ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
                const Divider(height: 32),
                _menuTileWithNav(
                  context,
                  Icons.edit_outlined,
                  'Edit Profile',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(profile: profile),
                    ),
                  ),
                ),
                _menuTileWithNav(
                  context,
                  Icons.lock_clock_outlined,
                  'My Holdings',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyHoldingsScreen()),
                  ),
                ),
                // _menuTileWithNav(
                //   context,
                //   Icons.upload_file_outlined,
                //   'My Documents',
                //   () => Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                //   ),
                // ),
                const Divider(height: 32),
                _menuTileWithNav(
                  context,
                  Icons.contact_support_outlined,
                  'Contact Us',
                  () => _openWebView(
                    context,
                    'Contact Us',
                    AppConfig.contactUrl,
                  ),
                ),
                _menuTileWithNav(
                  context,
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  () => _openWebView(
                    context,
                    'Privacy Policy',
                    AppConfig.privacyUrl,
                  ),
                ),
                _menuTileWithNav(
                  context,
                  Icons.description_outlined,
                  'Terms & Conditions',
                  () => _openWebView(
                    context,
                    'Terms & Conditions',
                    AppConfig.termsUrl,
                  ),
                ),
                const SizedBox(height: 48),
                PremiumButton(
                  text: AppStrings.logout,
                  onPressed: onLogout,
                  isLoading: false,
                  icon: Icons.logout_rounded,
                  gradient: [
                    AppColors.error,
                    AppColors.error.withValues(alpha: 0.8),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    final name = profile['name'] ?? AppStrings.partnerName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final imageUrl = profile['image_url']?.toString() ?? profile['image']?.toString() ?? '';

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      stretch: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.surfaceLight, size: 20),
        onPressed: () {
          // Go back to whichever tab was active before Profile
          final prevIndex = ref.read(prevNavIndexProvider);
          ref.read(bottomNavIndexProvider.notifier).state = prevIndex;
        },
      ),
      backgroundColor: AppColors.primary,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      iconTheme: const IconThemeData(color: AppColors.surfaceLight),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          // blurBackground removed — applies a real-time GPU blur on every
          // scroll frame, causing dropped frames on mid-range Android phones.
        ],
        centerTitle: true,
        title: const SizedBox.shrink(),
        titlePadding: const EdgeInsetsDirectional.only(start: 0, bottom: 16),
        background: RepaintBoundary(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (imageUrl.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullScreenImage(
                                imageUrl: imageUrl,
                                tag: 'profile_avatar_hero',
                              ),
                            ),
                          );
                        }
                      },
                      child: Hero(
                        tag: 'profile_avatar_hero',
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.surfaceLight,
                          child: ClipOval(
                            child: imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    cacheManager: SafeCacheManager(),
                                    width: 84,
                                    height: 84,
                                    fit: BoxFit.cover,
                                    memCacheWidth: 168,
                                    memCacheHeight: 168,
                                    placeholder: (_, __) => Container(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      child: Text(
                                        initial,
                                        style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: AppColors.surfaceLight,
                                      child: Text(
                                        initial,
                                        style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 84,
                                    height: 84,
                                    color: AppColors.surfaceLight,
                                    alignment: Alignment.center,
                                    child: Text(
                                      initial,
                                      style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.surfaceLight, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _ProfileStats(profile: profile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    Widget trailing,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.45,
            ),
            child: trailing,
          ),
        ],
      ),
    );
  }

  void _openWebView(BuildContext context, String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppWebView(title: title, url: url),
      ),
    );
  }

  Widget _menuTileWithNav(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.textSecondary(context).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.chevron_right, size: 16),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context), fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ─── Loading View ───────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.surfaceLight,
                strokeWidth: 2,
              ),
            ),
          ),
          const Spacer(),
          Text(
            AppStrings.syncProfile,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

// ─── Error View ─────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileTitle), elevation: 0),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            SizedBox(height: 12),
            Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Stats (live data, no hardcoding) ────────────────────────────────
class _ProfileStats extends ConsumerWidget {
  final Map<String, dynamic> profile;
  const _ProfileStats({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch statsProvider — avoids triggering a 500-item lead list
    // fetch just to show 3 numbers on the profile header.
    final stats = ref.watch(statsProvider);

    final totalLeads = stats.maybeWhen(
      data: (s) => s['total_leads']?.toString() ?? '0',
      orElse: () => '—',
    );

    final totalDeals = stats.maybeWhen(
      data: (s) => s['total_deals']?.toString() ?? '0',
      orElse: () => '—',
    );

    final closedLeads = stats.maybeWhen(
      data: (s) => s['closed_leads']?.toString() ??
          s['leads_closed']?.toString() ?? '0',
      orElse: () => '—',
    );

    return Row(
      children: [
        Expanded(child: _statChip(context, AppStrings.leadsLabel, totalLeads)),
        const SizedBox(width: 10),
        Expanded(child: _statChip(context, AppStrings.dealsLabel, totalDeals)),
        const SizedBox(width: 10),
        Expanded(child: _statChip(context, AppStrings.closedLabel, closedLeads)),
      ],
    );
  }

  Widget _statChip(BuildContext context, String label, String value) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.surfaceLight),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.surfaceLight.withValues(alpha: 0.75), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
