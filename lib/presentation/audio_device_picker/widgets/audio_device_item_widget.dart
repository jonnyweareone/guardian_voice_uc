import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AudioDeviceItemWidget extends StatelessWidget {
  final Map<String, dynamic> device;
  final bool isSelected;
  final VoidCallback onTap;

  const AudioDeviceItemWidget({
    Key? key,
    required this.device,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = device['type'] as String;
    final deviceName = device['name'] as String;
    final isConnected = device['isConnected'] as bool;
    final batteryLevel = device['batteryLevel'] as int?;
    final signalStrength = device['signalStrength'] as int?;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppTheme.lightTheme.primaryColor
              : AppTheme.lightTheme.dividerColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                // Device Icon
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.2)
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _getDeviceIcon(deviceType),
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      size: 6.w,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),

                // Device Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceName,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          // Connection Status
                          Container(
                            width: 2.w,
                            height: 2.w,
                            decoration: BoxDecoration(
                              color: isConnected
                                  ? AppTheme.getSuccessColor(true)
                                  : AppTheme.getErrorColor(true),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            isConnected ? 'Connected' : 'Disconnected',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: isConnected
                                  ? AppTheme.getSuccessColor(true)
                                  : AppTheme.getErrorColor(true),
                            ),
                          ),

                          // Battery Level for Bluetooth devices
                          if (deviceType == 'bluetooth' &&
                              batteryLevel != null) ...[
                            SizedBox(width: 3.w),
                            CustomIconWidget(
                              iconName: _getBatteryIcon(batteryLevel),
                              color: _getBatteryColor(batteryLevel),
                              size: 4.w,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${batteryLevel}%',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: _getBatteryColor(batteryLevel),
                              ),
                            ),
                          ],

                          // Signal Strength for Bluetooth devices
                          if (deviceType == 'bluetooth' &&
                              signalStrength != null) ...[
                            SizedBox(width: 3.w),
                            CustomIconWidget(
                              iconName: _getSignalIcon(signalStrength),
                              color: _getSignalColor(signalStrength),
                              size: 4.w,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Selection Indicator or Connect Button
                if (isSelected)
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 6.w,
                  )
                else if (deviceType == 'bluetooth' && !isConnected)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Connect',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDeviceIcon(String deviceType) {
    switch (deviceType) {
      case 'earpiece':
        return 'phone';
      case 'speaker':
        return 'volume_up';
      case 'bluetooth':
        return 'bluetooth';
      case 'headphones':
        return 'headphones';
      case 'car':
        return 'directions_car';
      case 'hearing_aid':
        return 'hearing';
      default:
        return 'speaker';
    }
  }

  String _getBatteryIcon(int? batteryLevel) {
    if (batteryLevel == null) return 'battery_unknown';
    if (batteryLevel > 80) return 'battery_full';
    if (batteryLevel > 60) return 'battery_6_bar';
    if (batteryLevel > 40) return 'battery_4_bar';
    if (batteryLevel > 20) return 'battery_2_bar';
    return 'battery_1_bar';
  }

  Color _getBatteryColor(int? batteryLevel) {
    if (batteryLevel == null) return AppTheme.lightTheme.colorScheme.onSurface;
    if (batteryLevel > 20) return AppTheme.getSuccessColor(true);
    return AppTheme.getErrorColor(true);
  }

  String _getSignalIcon(int? signalStrength) {
    if (signalStrength == null) return 'signal_cellular_0_bar';
    if (signalStrength > 80) return 'signal_cellular_4_bar';
    if (signalStrength > 60) return 'signal_cellular_3_bar';
    if (signalStrength > 40) return 'signal_cellular_2_bar';
    return 'signal_cellular_1_bar';
  }

  Color _getSignalColor(int? signalStrength) {
    if (signalStrength == null)
      return AppTheme.lightTheme.colorScheme.onSurface;
    if (signalStrength > 40) return AppTheme.getSuccessColor(true);
    if (signalStrength > 20) return AppTheme.getWarningColor(true);
    return AppTheme.getErrorColor(true);
  }
}
