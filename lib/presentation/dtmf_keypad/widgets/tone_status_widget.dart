import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ToneStatusWidget extends StatefulWidget {
  final bool isTransmitting;
  final bool isConnected;
  final String? lastTone;

  const ToneStatusWidget({
    Key? key,
    required this.isTransmitting,
    required this.isConnected,
    this.lastTone,
  }) : super(key: key);

  @override
  State<ToneStatusWidget> createState() => _ToneStatusWidgetState();
}

class _ToneStatusWidgetState extends State<ToneStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isTransmitting) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ToneStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTransmitting && !oldWidget.isTransmitting) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isTransmitting && oldWidget.isTransmitting) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: widget.isConnected
            ? (isDark
                ? AppTheme.successDark.withValues(alpha: 0.1)
                : AppTheme.successLight.withValues(alpha: 0.1))
            : (isDark
                ? AppTheme.errorDark.withValues(alpha: 0.1)
                : AppTheme.errorLight.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: widget.isConnected
              ? (isDark ? AppTheme.successDark : AppTheme.successLight)
              : (isDark ? AppTheme.errorDark : AppTheme.errorLight),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isTransmitting ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 3.w,
                  height: 3.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isTransmitting
                        ? (isDark
                            ? AppTheme.warningDark
                            : AppTheme.warningLight)
                        : (widget.isConnected
                            ? (isDark
                                ? AppTheme.successDark
                                : AppTheme.successLight)
                            : (isDark
                                ? AppTheme.errorDark
                                : AppTheme.errorLight)),
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              widget.isTransmitting
                  ? 'Transmitting tone ${widget.lastTone ?? ""}'
                  : (widget.isConnected
                      ? 'Ready to transmit'
                      : 'Connection lost'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: widget.isTransmitting
                    ? (isDark ? AppTheme.warningDark : AppTheme.warningLight)
                    : (widget.isConnected
                        ? (isDark
                            ? AppTheme.successDark
                            : AppTheme.successLight)
                        : (isDark ? AppTheme.errorDark : AppTheme.errorLight)),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
