import 'dart:async';

import 'package:flutter/material.dart';
import 'package:realestate/screens/auth/login_screen.dart';
import '../constant/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay of 2–3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary, // same green shade
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle
          ),
          child: Image.asset(
            "assets/images/logo.png",
            width: 200,
          ),
        ),
      ),
    );
  }
}
