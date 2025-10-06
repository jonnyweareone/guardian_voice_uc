import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class NetworkQualityIndicatorWidget extends StatelessWidget {
  final String quality;
  final int signalStrength;
  final String networkType;

  const NetworkQualityIndicatorWidget({
    Key? key,
    required this.quality,
    required this.signalStrength,
    required this.networkType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color qualityColor = _getQualityColor();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSignalBars(),
          SizedBox(width: 2.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                quality,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: qualityColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                networkType,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignalBars() {
    return Row(
      children: List.generate(4, (index) {
        bool isActive = index < (signalStrength / 25).ceil();
        return Container(
          width: 1.w,
          height: (index + 1) * 1.h,
          margin: EdgeInsets.only(right: 0.5.w),
          decoration: BoxDecoration(
            color: isActive
                ? _getQualityColor()
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  Color _getQualityColor() {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return AppTheme.getSuccessColor(true);
      case 'good':
        return AppTheme.getSuccessColor(true);
      case 'fair':
        return AppTheme.getWarningColor(true);
      case 'poor':
        return AppTheme.getErrorColor(true);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
