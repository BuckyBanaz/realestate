import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:realestate/screens/dashboard/dashboard_screen.dart';
import 'package:realestate/screens/home/home_screen.dart';

import '../../constant/app_colors.dart';

class OTPScreen extends StatefulWidget {
  final String contact; // "jonathan@email.com" ya "+62 812-3456-7890"
  final bool isEmail;   // true = email, false = phone

  const OTPScreen({Key? key, required this.contact, this.isEmail = false}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with TickerProviderStateMixin {
  late TextEditingController _pinController;
  int _secondsRemaining = 21;
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _secondsRemaining),
    )..addListener(() {
      setState(() {
        _secondsRemaining = _timerController.duration!.inSeconds - _timerController.value.toInt() * _timerController.duration!.inSeconds ~/ 100;
      });
    });
    _timerController.reverse(from: 1.0);
  }

  @override
  void dispose() {
    _pinController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  void _resendOTP() {
    setState(() {
      _secondsRemaining = 21;
    });
    _timerController.reset();
    _timerController.reverse(from: 1.0);
    // TODO: API call to resend OTP
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("OTP resent to ${widget.contact}")),
    );
  }

  void _onOTPCompleted(String pin) {
    // TODO: Verify OTP
    Get.offAll(DashboardScreen());
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 64,
      height: 68,
      textStyle:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: secondary),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration:  BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                ),
                child:  Icon(Icons.arrow_back_ios_new_rounded, color: secondary, size: 22),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
             Text(
              "Enter the code",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: secondary),
            ),
            const SizedBox(height: 16),
            Text(
              "Enter the 4 digit code that we just sent to\n${widget.contact}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 60),

            // Pinput Field
            Pinput(
              controller: _pinController,
              length: 4,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color:  secondary, width: 2),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: const Color(0xFFE8F5E8),
                  border: Border.all(color: const Color(0xFF4CAF50)),
                ),
              ),
              onCompleted: _onOTPCompleted,
              keyboardType: TextInputType.number,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
            ),

            const SizedBox(height: 60),

            // Timer + Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  "00:${_secondsRemaining.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                text: "Didn't receive the OTP? ",
                style: TextStyle(color: Colors.grey.shade600),
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: _secondsRemaining == 0 ? _resendOTP : null,
                      child: Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: _secondsRemaining == 0 ? secondary : Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}