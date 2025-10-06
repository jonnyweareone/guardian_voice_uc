import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SipStatusCardWidget extends StatelessWidget {
  final String status;
  final String statusMessage;
  final bool isConnected;
  final VoidCallback? onRefresh;

  const SipStatusCardWidget({
    Key? key,
    required this.status,
    required this.statusMessage,
    required this.isConnected,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor();
    Color backgroundColor = statusColor.withValues(alpha: 0.1);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: isConnected ? 'check_circle' : 'error',
              color: Colors.white,
              size: 6.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SIP Status',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  status,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  statusMessage,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onRefresh != null)
            GestureDetector(
              onTap: onRefresh,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'refresh',
                  color: statusColor,
                  size: 5.w,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'registered':
      case 'connected':
        return AppTheme.getSuccessColor(true);
      case 'registering':
      case 'connecting':
        return AppTheme.getWarningColor(true);
      case 'failed':
      case 'disconnected':
      case 'error':
        return AppTheme.getErrorColor(true);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
