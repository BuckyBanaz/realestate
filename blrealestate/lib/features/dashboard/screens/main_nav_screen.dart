import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/nav_providers.dart';
import '../../leads/screens/add_lead_screen.dart';
import '../../leads/screens/lead_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'commission_screen.dart';
import 'dashboard_screen.dart';

class MainNavScreen extends ConsumerStatefulWidget {
  const MainNavScreen({super.key});

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  // Lazy loading: only build a tab when first visited.
  // Index 0 (Home) is pre-built. Others start as false → SizedBox.shrink()
  // This cuts initial widget-build workload by 75%, eliminating startup frame skips.
  final List<bool> _visited = [true, false, false, false];

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    final currentIndex = ref.read(bottomNavIndexProvider);
    if (currentIndex == index) return; // already on this tab
    // Remember where we came from before switching
    ref.read(prevNavIndexProvider.notifier).state = currentIndex;
    if (!_visited[index]) {
      setState(() => _visited[index] = true);
    }
    ref.read(bottomNavIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        
        if (currentIndex != 0) {
          _onTabTapped(0);
          return;
        }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
        index: currentIndex,
        children: [
          // Tab 0: Home — always built (first screen user sees)
          const DashboardScreen(),
          // Tabs 1-3: built on first visit, then kept alive
          _visited[1] ? const CommissionScreen() : const SizedBox.shrink(),
          _visited[2] ? const _LeadTab()         : const SizedBox.shrink(),
          _visited[3] ? const ProfileScreen()    : const SizedBox.shrink(),
        ],
      ),
      floatingActionButton: currentIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddLeadScreen()),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surfaceLight,
              elevation: 4,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text('Add Lead', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _BottomNav(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
      ),
      ),
    );
  }
}

// ── Wraps LeadListScreen and removes its internal Scaffold AppBar back-btn ────
class _LeadTab extends StatelessWidget {
  const _LeadTab();

  @override
  Widget build(BuildContext context) {
    // LeadListScreen has its own Scaffold+AppBar — used directly
    return const LeadListScreen();
  }
}

// ── Premium Bottom Navigation Bar ────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'Commission',
    ),
    _NavItem(
      icon: Icons.people_alt_outlined,
      activeIcon: Icons.people_alt_rounded,
      label: 'Leads',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final shadow = isDark ? AppColors.transparent : AppColors.textPrimary(context).withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.surfaceLight.withValues(alpha: 0.06)
                : AppColors.textSecondary(context).withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 94,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: _NavButton(
                  item: item,
                  isActive: isActive,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Individual nav button with animated indicator ─────────────────────────────
class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark
        ? AppColors.surfaceLight.withValues(alpha: 0.35)
        : AppColors.textSecondary(context).withValues(alpha: 0.55);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pill indicator + icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.13)
                  : AppColors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isActive ? item.activeIcon : item.icon,
              size: 24,
              color: isActive ? AppColors.primary : inactiveColor,
            ),
          ),
          const SizedBox(height: 2),
          // Label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: isActive ? AppColors.primary : inactiveColor),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

// ── Data model for nav items ──────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
