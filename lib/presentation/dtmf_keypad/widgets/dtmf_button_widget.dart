import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DtmfButtonWidget extends StatefulWidget {
  final String number;
  final String letters;
  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;
  final bool isSpecialButton;

  const DtmfButtonWidget({
    Key? key,
    required this.number,
    required this.letters,
    required this.onPressed,
    this.onLongPressed,
    this.isSpecialButton = false,
  }) : super(key: key);

  @override
  State<DtmfButtonWidget> createState() => _DtmfButtonWidgetState();
}

class _DtmfButtonWidgetState extends State<DtmfButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _handleLongPress() {
    if (widget.onLongPressed != null) {
      HapticFeedback.mediumImpact();
      widget.onLongPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onLongPress: widget.onLongPressed != null ? _handleLongPress : null,
            child: Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isPressed
                    ? (isDark
                        ? AppTheme.primaryDark.withValues(alpha: 0.3)
                        : AppTheme.primaryLight.withValues(alpha: 0.1))
                    : (isDark ? AppTheme.cardDark : AppTheme.cardLight),
                border: Border.all(
                  color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.number,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: widget.isSpecialButton
                          ? (isDark
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight)
                          : (isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight),
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                  ),
                  if (widget.letters.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      widget.letters,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                        fontSize: 8.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
