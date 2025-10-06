import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AudioFeedbackToggleWidget extends StatelessWidget {
  final bool isAudioEnabled;
  final ValueChanged<bool> onToggle;

  const AudioFeedbackToggleWidget({
    Key? key,
    required this.isAudioEnabled,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isAudioEnabled ? 'volume_up' : 'volume_off',
            color: isAudioEnabled
                ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                : (isDark
                    ? AppTheme.textDisabledDark
                    : AppTheme.textDisabledLight),
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Audio Feedback',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: isAudioEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              onToggle(value);
            },
            activeColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            inactiveThumbColor:
                isDark ? AppTheme.textDisabledDark : AppTheme.textDisabledLight,
            inactiveTrackColor:
                isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
          ),
        ],
      ),
    );
  }
}
