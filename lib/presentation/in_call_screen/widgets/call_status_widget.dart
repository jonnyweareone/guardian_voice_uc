import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CallStatusWidget extends StatelessWidget {
  final Map<String, dynamic> callStatus;

  const CallStatusWidget({
    Key? key,
    required this.callStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String connectionQuality = callStatus['connectionQuality'] ?? 'good';
    final bool isEncrypted = callStatus['isEncrypted'] ?? true;
    final String networkType = callStatus['networkType'] ?? 'WiFi';
    final String callState = callStatus['callState'] ?? 'connected';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Connection Quality
          _buildStatusItem(
            icon: _getConnectionIcon(connectionQuality),
            label: _getConnectionLabel(connectionQuality),
            color: _getConnectionColor(connectionQuality),
          ),

          // Encryption Status
          if (isEncrypted)
            _buildStatusItem(
              icon: 'lock',
              label: 'Encrypted',
              color: AppTheme.getSuccessColor(true),
            ),

          // Network Type
          _buildStatusItem(
            icon: _getNetworkIcon(networkType),
            label: networkType,
            color:
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: icon,
          size: 5.w,
          color: color,
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: color,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  String _getConnectionIcon(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return 'signal_cellular_4_bar';
      case 'good':
        return 'signal_cellular_3_bar';
      case 'fair':
        return 'signal_cellular_2_bar';
      case 'poor':
        return 'signal_cellular_1_bar';
      default:
        return 'signal_cellular_null';
    }
  }

  String _getConnectionLabel(String quality) {
    return quality.substring(0, 1).toUpperCase() + quality.substring(1);
  }

  Color _getConnectionColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
      case 'good':
        return AppTheme.getSuccessColor(true);
      case 'fair':
        return AppTheme.getWarningColor(true);
      case 'poor':
        return AppTheme.getErrorColor(true);
      default:
        return AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.6);
    }
  }

  String _getNetworkIcon(String networkType) {
    switch (networkType.toLowerCase()) {
      case 'wifi':
        return 'wifi';
      case '5g':
        return '5g';
      case '4g':
      case 'lte':
        return 'network_cell';
      case '3g':
        return 'network_cell';
      default:
        return 'signal_cellular_alt';
    }
  }
}
