import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final bool isSearchResult;

  const EmptyStateWidget({
    Key? key,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.isSearchResult = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: isSearchResult ? 'search_off' : 'call',
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.6),
                size: 15.w,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: isDarkMode
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              isSearchResult
                  ? 'Try adjusting your search terms or filters'
                  : 'Your call history will appear here once you start making calls',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: isDarkMode
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              SizedBox(height: 4.h),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: CustomIconWidget(
                  iconName: 'call',
                  color: Colors.white,
                  size: 5.w,
                ),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
