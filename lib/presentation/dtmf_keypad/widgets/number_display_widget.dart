import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NumberDisplayWidget extends StatelessWidget {
  final String displayedNumber;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  const NumberDisplayWidget({
    Key? key,
    required this.displayedNumber,
    required this.onBackspace,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
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
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: 6.h),
              child: Center(
                child: displayedNumber.isEmpty
                    ? Text(
                        'Enter number',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? AppTheme.textDisabledDark
                              : AppTheme.textDisabledLight,
                          fontSize: 16.sp,
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          displayedNumber,
                          style: AppTheme.getMonospaceStyle(
                            isLight: !isDark,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          ),
          if (displayedNumber.isNotEmpty) ...[
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onBackspace();
              },
              onLongPress: () {
                HapticFeedback.mediumImpact();
                onClear();
              },
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppTheme.backgroundDark
                      : AppTheme.backgroundLight,
                ),
                child: CustomIconWidget(
                  iconName: 'backspace',
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
