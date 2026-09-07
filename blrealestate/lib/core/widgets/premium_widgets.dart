import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final List<Color>? gradient;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : LinearGradient(
                colors: gradient ??
                    [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDisabled ? AppColors.textSecondary(context).withValues(alpha: 0.3) : null,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },

          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.surfaceLight,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: AppColors.surfaceLight, size: 20),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        text,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.surfaceLight),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.color,
    this.borderRadius,
    this.border,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: (color ?? AppColors.surfaceLight).withValues(alpha: opacity),
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          border: border ??
              Border.all(
                color: AppColors.surfaceLight.withValues(alpha: 0.2),
                width: 1.5,
              ),
        ),
        child: child,
      ),
    );
  }
}

class StaggeredFadeItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const StaggeredFadeItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 80),
  });

  @override
  State<StaggeredFadeItem> createState() => _StaggeredFadeItemState();
}

class _StaggeredFadeItemState extends State<StaggeredFadeItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Items beyond index 3 share the same 240ms delay cap — no controller
    // overhead for items that animate at the same time anyway.
    final cappedDelay = widget.index <= 3
        ? widget.delay * widget.index
        : const Duration(milliseconds: 240);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(cappedDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
