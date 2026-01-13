import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../constant/app_colors.dart';
import '../home/home_screen.dart';
import '../home/home_view_2.dart';
import '../profile/transaction_detail_screen.dart';
import '../search/search_screen.dart';
import '../favorite/favorite_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeView2(showNavBar: false),
    Center(child: Text("Transactions"),),
    FavoriteScreen(),
    // TransactionListScreen(transactions: [],),

    // // Make sure you have a ChatScreen or replace with any widget.
    // ChatScreen(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // compute nav height responsively if you want:
    final screenHeight = MediaQuery.of(context).size.height;
    final navHeight = (screenHeight * 0.085).clamp(64.0, 88.0);

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onTap,
        height: navHeight,
      ),
    );
  }
}


typedef OnNavTap = void Function(int index);

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final OnNavTap onTap;
  final double height;

  const CustomBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    this.height = 72,
  }) : super(key: key);

  Widget _item({
    required BuildContext context,
    required IconData icon,
    IconData? activeIcon,
    required String label,
    required int index,
    required bool selected,
  }) {
    final color = selected ? secondary : Colors.grey.shade600;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              selected && activeIcon != null ? activeIcon : icon,
              size: selected ? 28 : 26,
              color: color,
            ),
            // label - small, subtle
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? secondary : Colors.grey.shade600,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w200,
              ),
            ),
            // const SizedBox(height: 6),
            // // dot indicator
            // AnimatedContainer(
            //   duration: const Duration(milliseconds: 250),
            //   curve: Curves.easeInOut,
            //   width: 8,
            //   height: 8,
            //   decoration: BoxDecoration(
            //     color: selected ? secondary : Colors.transparent,
            //     shape: BoxShape.circle,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Container with rounded top corners + shadow
    return Container(
      height: height,
      padding: const EdgeInsets.only(top: 2, bottom: 2, left: 8, right: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1F1F1F) 
            : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Slightly stronger shadow
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _item(
            context: context,
            icon: IconlyLight.home,
            activeIcon: IconlyBold.home,
            label: 'Home',
            index: 0,
            selected: selectedIndex == 0,
          ),

          _item(
            context: context,
            icon: IconlyLight.paper,
            activeIcon: IconlyBold.paper,
            label: 'Transactions',
            index: 1,
            selected: selectedIndex == 1,
          ),

          _item(
            context: context,
            icon: IconlyLight.heart,
            activeIcon: IconlyBold.heart,
            label: 'Favorite',
            index: 2,
            selected: selectedIndex == 2,
          ),
          // _item(
          //   context: context,
          //   icon: IconlyLight.message,
          //   activeIcon: IconlyBold.message,
          //   label: 'Chat',
          //   index: 3,
          //   selected: selectedIndex == 3,
          // ),
          _item(
            context: context,
            icon: IconlyLight.profile,
            activeIcon: IconlyBold.profile,
            label: 'Profile',
            index: 3,
            selected: selectedIndex == 3,
          ),
        ],
      ),
    );
  }
}
