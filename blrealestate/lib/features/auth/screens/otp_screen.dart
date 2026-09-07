import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../dashboard/screens/main_nav_screen.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  // 4 individual controllers + focus nodes — one per box
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _timerSeconds = 30;
  Timer? _timer;
  bool _isLoading = false;

  // Shake animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Auto-focus first box on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ─── Timer ────────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _timerSeconds = 30; // already initialized — no setState needed here
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_timerSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  // ─── Get full OTP string ──────────────────────────────────────────────────
  String get _otp => _controllers.map((c) => c.text).join();

  // ─── Verify ───────────────────────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    if (_otp.length != 4 || _isLoading) return;
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final success = await ref
          .read(authProvider.notifier)
          .verifyOtp(widget.phone, _otp);

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavScreen()),
          (route) => false,
        );
      } else {
        setState(() => _isLoading = false);
        _shakeController.forward(from: 0);
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
        AppSnackBar.error(context, AppStrings.invalidpin);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.error(context, 'Verification failed. Please try again.');
    }
  }

  // ─── Handle each box input ────────────────────────────────────────────────
  void _onChanged(String value, int index) {
    if (value.length > 1) {
      // Handle paste — distribute digits across boxes
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 4 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final nextEmpty = _controllers.indexWhere((c) => c.text.isEmpty);
      if (nextEmpty == -1) {
        _focusNodes[3].requestFocus();
        _verifyOtp();
      } else {
        _focusNodes[nextEmpty].requestFocus();
      }
      return;
    }

    if (value.isNotEmpty) {
      // Move forward
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last box filled — auto submit
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    // Backspace on empty box → go back
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.surface(context),
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          foregroundColor: AppColors.textPrimary(context),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 20 : 32,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.04),

                // ── Icon ──
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_open_rounded,
                    color: AppColors.primary,
                    size: 38,
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                // ── Title ──
                Text(
                  AppStrings.pinTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary(context), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
                    children: [
                      const TextSpan(text: "${AppStrings.enterPin}  "),
                      TextSpan(
                        text: "+91 ${widget.phone}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.06),

                // ── 4 OTP Boxes with shake ──
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    final offset = _shakeController.isAnimating
                        ? 8 * (0.5 - (_shakeAnimation.value - 0.5).abs())
                        : 0.0;
                    return Transform.translate(
                      offset: Offset(offset * 6, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      final isActive = _focusNodes[i].hasFocus;
                      final isFilled = _controllers[i].text.isNotEmpty;
                      return _OtpBox(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        isActive: isActive,
                        isFilled: isFilled,
                        isSmall: isSmall,
                        onChanged: (v) => _onChanged(v, i),
                        onKeyEvent: (e) => _onKeyEvent(e, i),
                        onTap: () {
                          // Clicking a box clears it for re-entry
                          _controllers[i].clear();
                        },
                      );
                    }),
                  ),
                ),

                SizedBox(height: size.height * 0.05),

                // ── Verify Button / Loader ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isLoading
                      ? const SizedBox(
                          key: ValueKey('loader'),
                          height: 56,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : PremiumButton(
                          text: AppStrings.verifypin,
                          onPressed: _otp.length == 4 ? _verifyOtp : null,
                          isLoading: _isLoading,
                        ),
                ),

                const SizedBox(height: 24),

                // ── Resend / Timer ──
                _timerSeconds > 0
                    ? Text(
                        '${AppStrings.resendpinIn} $_timerSeconds s',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      )
                    : OutlinedButton.icon(
                        onPressed: () async {
                          final ctx = context; // capture before async gap
                          final sent = await ref
                              .read(authProvider.notifier)
                              .sendOtp(widget.phone);
                          if (!mounted) return;
                          if (sent) {
                            setState(() => _startTimer());
                          } else {
                            AppSnackBar.error(ctx, AppStrings.pinSendFailed);
                          }
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          AppStrings.resendpin,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),

                const SizedBox(height: 16),

                // ── Wrong number ──
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
                      children: [
                        TextSpan(text: "${AppStrings.wrongNumber}  "),
                        TextSpan(
                          text: AppStrings.changeNumber,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
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

// ─── Single OTP Box Widget ────────────────────────────────────────────────────
class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isActive;
  final bool isFilled;
  final bool isSmall;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;
  final VoidCallback onTap;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isActive,
    required this.isFilled,
    required this.isSmall,
    required this.onChanged,
    required this.onKeyEvent,
    required this.onTap,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  late final VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();
    _focusListener = () {
      if (mounted) setState(() {});
    };
    widget.focusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_focusListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.focusNode.hasFocus;
    final isFilled = widget.controller.text.isNotEmpty;
    final boxSize = widget.isSmall ? 56.0 : 64.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : isFilled
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.textSecondary(context).withValues(alpha: 0.3),
            width: isActive ? 2.2 : 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Focus(
          onKeyEvent: (node, event) {
            // Only handle KeyDownEvent to avoid the KeyUpEvent assertion crash
            // that occurs when Android IME sends key events out of order
            if (event is KeyDownEvent) {
              widget.onKeyEvent(event);
            }
            return KeyEventResult.ignored;
          },
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            onTap: widget.onTap,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}
