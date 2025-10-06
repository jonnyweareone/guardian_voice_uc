import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CallOptionsWidget extends StatelessWidget {
  final VoidCallback onMinimize;
  final VoidCallback onTransfer;
  final VoidCallback onRecord;
  final VoidCallback onConference;
  final bool isRecording;

  const CallOptionsWidget({
    Key? key,
    required this.onMinimize,
    required this.onTransfer,
    required this.onRecord,
    required this.onConference,
    required this.isRecording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Minimize Button
          _buildOptionButton(
            icon: 'minimize',
            label: 'Minimize',
            onTap: onMinimize,
          ),

          // Transfer Button
          _buildOptionButton(
            icon: 'call_made',
            label: 'Transfer',
            onTap: onTransfer,
          ),

          // Record Button
          _buildOptionButton(
            icon: isRecording ? 'stop' : 'fiber_manual_record',
            label: isRecording ? 'Stop Rec' : 'Record',
            onTap: onRecord,
            isActive: isRecording,
            activeColor: AppTheme.getErrorColor(true),
          ),

          // Conference Button
          _buildOptionButton(
            icon: 'group',
            label: 'Conference',
            onTap: onConference,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color? activeColor,
  }) {
    final Color buttonColor = isActive && activeColor != null
        ? activeColor
        : AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.2);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: buttonColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                size: 5.w,
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.8),
              fontSize: 9.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
