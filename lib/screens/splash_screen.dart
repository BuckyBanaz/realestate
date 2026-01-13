import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/domain/app/local_storage.dart';
import '../constant/app_colors.dart';
import 'package:realestate/screens/widgets/helpers.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool showLoader = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // start off-screen (bottom)
      end: Offset.zero,          // end at its Align position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // show loader after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => showLoader = true);
      _controller.forward();
    });

    // navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      
      final token = LocalStorage().getToken();
      if (token != null && token.isNotEmpty) {
         Get.offAllNamed(AppRoutes.home);
      } else {
         Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Logo centered
            // Logo centered
            Center(
              child: Transform.scale(
                scale: 2.0,
                child: const Logoor(animate: true),
              ),
            ),

            // Loader slides from bottom to slightly below center (alignment y = 0.4)
            if (showLoader)
              Align(
                alignment: const Alignment(0, 0.4),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
