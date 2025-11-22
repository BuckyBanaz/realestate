import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/search/search_screen.dart';

import '../favorite/favorite_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Keep widgets here so they are preserved by the IndexedStack
  final List<Widget> _pages = const [
    HomeScreen(),
    SearchScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // responsive bottom nav height
    final screenHeight = MediaQuery.of(context).size.height;
    final navHeight = screenHeight * 0.065; // 9.5% of height
    final clampedNavHeight = navHeight.clamp(kBottomNavigationBarHeight, 84.0);

    return Scaffold(
      // If you face keyboard overlap issues on pages with TextFields, you can set resizeToAvoidBottomInset: true/false here.
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            _navItem(icon: IconlyLight.home, filledIcon: IconlyBold.home, index: 0, label: 'Home'),
            _navItem(icon: IconlyLight.search, index: 1, label: 'Search'),
            _navItem(icon: IconlyLight.heart, filledIcon: IconlyBold.heart, index: 2, label: 'Favorites'),
            _navItem(icon: IconlyLight.profile, filledIcon: IconlyBold.profile, index: 3, label: 'Profile'),
          ],
        ),
      ),

    );
  }

  Widget _buildBottomNav(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(icon: IconlyLight.home, filledIcon: IconlyBold.home, index: 0, label: 'Home'),
          _navItem(icon: IconlyLight.search, index: 1, label: 'Search'),
          _navItem(icon: IconlyLight.heart, filledIcon: IconlyBold.heart, index: 2, label: 'Favorites'),
          _navItem(icon: IconlyLight.profile, filledIcon: IconlyBold.profile, index: 3, label: 'Profile'),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    IconData? filledIcon,
    required int index,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => _onTap(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  selected: isSelected,
                  label: label,
                  child: Icon(
                    isSelected && filledIcon != null ? filledIcon : icon,
                    size: isSelected ? 28 : 26,
                    color: isSelected ? secondary : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? secondary : Colors.transparent,
                    shape: BoxShape.circle,
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
