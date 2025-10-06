import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CallControlsWidget extends StatelessWidget {
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isOnHold;
  final VoidCallback onMuteToggle;
  final VoidCallback onSpeakerToggle;
  final VoidCallback onHoldToggle;
  final VoidCallback onAddCall;
  final VoidCallback onKeypadOpen;
  final VoidCallback onEndCall;
  final VoidCallback onAudioDevicePicker;

  const CallControlsWidget({
    Key? key,
    required this.isMuted,
    required this.isSpeakerOn,
    required this.isOnHold,
    required this.onMuteToggle,
    required this.onSpeakerToggle,
    required this.onHoldToggle,
    required this.onAddCall,
    required this.onKeypadOpen,
    required this.onEndCall,
    required this.onAudioDevicePicker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      child: Column(
        children: [
          // Top Row Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mute Button
              _buildControlButton(
                icon: isMuted ? 'mic_off' : 'mic',
                isActive: isMuted,
                onTap: onMuteToggle,
                backgroundColor: isMuted
                    ? AppTheme.getErrorColor(true)
                    : AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.2),
              ),

              // Speaker Button
              GestureDetector(
                onTap: onSpeakerToggle,
                onLongPress: onAudioDevicePicker,
                child: _buildControlButton(
                  icon: isSpeakerOn ? 'volume_up' : 'volume_down',
                  isActive: isSpeakerOn,
                  onTap: onSpeakerToggle,
                  backgroundColor: isSpeakerOn
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.2),
                ),
              ),

              // Add Call Button
              _buildControlButton(
                icon: 'person_add',
                isActive: false,
                onTap: onAddCall,
                backgroundColor: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.2),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Bottom Row Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Hold Button
              _buildControlButton(
                icon: isOnHold ? 'play_arrow' : 'pause',
                isActive: isOnHold,
                onTap: onHoldToggle,
                backgroundColor: isOnHold
                    ? AppTheme.getWarningColor(true)
                    : AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.2),
              ),

              // Keypad Button
              _buildControlButton(
                icon: 'dialpad',
                isActive: false,
                onTap: onKeypadOpen,
                backgroundColor: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.2),
              ),

              // End Call Button (Larger)
              _buildEndCallButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required bool isActive,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 16.w,
        height: 16.w,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            size: 7.w,
            color: isActive &&
                    backgroundColor !=
                        AppTheme.lightTheme.colorScheme.surface
                            .withValues(alpha: 0.2)
                ? AppTheme.lightTheme.colorScheme.surface
                : AppTheme.lightTheme.colorScheme.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: onEndCall,
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: AppTheme.getErrorColor(true),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.getErrorColor(true).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'call_end',
            size: 9.w,
            color: AppTheme.lightTheme.colorScheme.surface,
          ),
        ),
      ),
    );
  }
}
