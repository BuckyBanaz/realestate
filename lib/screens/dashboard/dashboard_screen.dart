import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import '../../constant/app_colors.dart';
import '../home/home_view_2.dart';
import '../favorite/favorite_screen.dart';
import '../profile/profile_screen.dart';
import '../transaction/transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget Function()> _pageBuilders = [
    () => HomeView2(showNavBar: false),
    () => TransactionListScreen(),
    () => FavoriteScreen(),
    () => ProfileScreen(),
  ];
  final Map<int, Widget> _builtPages = {};

  @override
  void initState() {
    super.initState();
    // Build only the initial tab to avoid extra API calls.
    _builtPages[_selectedIndex] = _pageBuilders[_selectedIndex]();
  }

  void _onTap(int index) {
    if (_selectedIndex == index) return;
    if (!_builtPages.containsKey(index)) {
      _builtPages[index] = _pageBuilders[index]();
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      extendBody: true, // Important for content to show behind nav bar
      body: Stack(
        children: [
          // 1. Content
          IndexedStack(
            index: _selectedIndex,
            children: List.generate(
              _pageBuilders.length,
              (i) => _builtPages[i] ?? const SizedBox.shrink(),
            ),
          ),

          // 2. Floating Glass Navbar
          Positioned(
            bottom: 30.h,
            left: 20.w,
            right: 20.w,
            child: _buildGlassNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 30.0,
          sigmaY: 30.0,
        ), // Increased blur for liquid feel
        child: Container(
          height: 70.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2), // Much more transparent
            // Optional: You could use a gradient for even more depth
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     Colors.black.withOpacity(0.2),
            //     Colors.black.withOpacity(0.1),
            //   ],
            // ),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.08), // More subtle border
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Softer shadow
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(IconlyLight.home, IconlyBold.home, "Home", 0),
              _navItem(IconlyLight.paper, IconlyBold.paper, "Transactions", 1),
              _navItem(IconlyLight.heart, IconlyBold.heart, "Favorite", 2),
              _navItem(IconlyLight.profile, IconlyBold.profile, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, String label, int index) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.1), // Soft highlight
                borderRadius: BorderRadius.circular(20.r),
              )
            : BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
              ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24.sp,
              color: isSelected ? secondary : Colors.grey.shade400,
            ),
            if (isSelected) ...[
              SizedBox(height: 4.h),
              // Optional: Label or Dot
              Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ] else ...[
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
