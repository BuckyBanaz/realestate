import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/main_nav_screen.dart';
import 'providers/auth_provider.dart';
import 'core/constants/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      systemNavigationBarColor: AppColors.primary,
      statusBarIconBrightness: Brightness.light,
    ));
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    try {
      // Wait for both: the splash animation AND the auth token read (3s timeout)
      final (delay, tokenResult) = await (
        Future.delayed(const Duration(milliseconds: 1800)),
        ref.read(authProvider.future).timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        )
      ).wait;

      // Fix #6: Double-check mounting and context before navigation
      if (!mounted || !context.mounted) return;

      // tokenResult is already properly typed as String? by the future.
      final token = tokenResult;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              token != null ? const MainNavScreen() : const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    } catch (e) {
      // Fallback for safety
      if (mounted && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Image.asset(
          'assets/splash.png',
          width: 220,
          height: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
