import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../providers/auth_provider.dart';
import 'otp_screen.dart';
import '../../../core/widgets/premium_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      AppSnackBar.error(context, AppStrings.invalidPhone);
      return;
    }
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final success = await ref.read(authProvider.notifier).sendOtp(phone);
      // Reset loading before mounted check — prevents frozen button
      // if widget is briefly unmounted during push animation
      if (mounted) setState(() => _isLoading = false);
      if (!mounted) return;
      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OtpScreen(phone: phone)),
        );
      } else {
        AppSnackBar.error(context, AppStrings.pinSendFailed);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (!mounted) return;
      AppSnackBar.error(context, 'Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = ResponsiveHelper.isSmallScreen(context);
    final hPad = isSmall ? 24.0 : 32.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: size.height * 0.38,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.home_work_rounded, size: 80, color: AppColors.surfaceLight),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.loginTitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.loginSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: AppStrings.phoneHint,
                        prefixText: AppStrings.phonePrefix,
                        prefixIcon: const Icon(Icons.phone_android, color: AppColors.primary),
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    PremiumButton(
                      text: AppStrings.sendpin,
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
