import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CallerInfoWidget extends StatelessWidget {
  final Map<String, dynamic> callerData;
  final String callDuration;

  const CallerInfoWidget({
    Key? key,
    required this.callerData,
    required this.callDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String callerName = callerData['name'] ?? 'Unknown';
    final String callerNumber = callerData['number'] ?? '';
    final String callerPhoto = callerData['photo'] ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Caller Photo
          Container(
            width: 35.w,
            height: 35.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: callerPhoto.isNotEmpty
                  ? CustomImageWidget(
                      imageUrl: callerPhoto,
                      width: 35.w,
                      height: 35.w,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.2),
                      child: CustomIconWidget(
                        iconName: 'person',
                        size: 15.w,
                        color: AppTheme.lightTheme.colorScheme.surface,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 3.h),

          // Caller Name
          Text(
            callerName,
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 1.h),

          // Caller Number
          if (callerNumber.isNotEmpty)
            Text(
              callerNumber,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.8),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),

          SizedBox(height: 2.h),

          // Call Duration
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              callDuration,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.surface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
