import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/audio_device_list_widget.dart';

class AudioDevicePicker extends StatefulWidget {
  const AudioDevicePicker({Key? key}) : super(key: key);

  @override
  State<AudioDevicePicker> createState() => _AudioDevicePickerState();
}

class _AudioDevicePickerState extends State<AudioDevicePicker>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String? _selectedDeviceId;
  bool _isConnecting = false;

  // Mock audio devices data
  final List<Map<String, dynamic>> _audioDevices = [
    {
      "id": "earpiece_1",
      "name": "Phone Earpiece",
      "type": "earpiece",
      "isConnected": true,
      "isAvailable": true,
      "batteryLevel": null,
      "signalStrength": null,
    },
    {
      "id": "speaker_1",
      "name": "Speaker Phone",
      "type": "speaker",
      "isConnected": false,
      "isAvailable": true,
      "batteryLevel": null,
      "signalStrength": null,
    },
    {
      "id": "bluetooth_1",
      "name": "AirPods Pro",
      "type": "bluetooth",
      "isConnected": true,
      "isAvailable": true,
      "batteryLevel": 85,
      "signalStrength": 92,
    },
    {
      "id": "bluetooth_2",
      "name": "Sony WH-1000XM4",
      "type": "bluetooth",
      "isConnected": false,
      "isAvailable": true,
      "batteryLevel": 45,
      "signalStrength": 78,
    },
    {
      "id": "bluetooth_3",
      "name": "BMW X5 Audio",
      "type": "car",
      "isConnected": false,
      "isAvailable": false,
      "batteryLevel": null,
      "signalStrength": 0,
    },
    {
      "id": "bluetooth_4",
      "name": "Phonak Hearing Aid",
      "type": "hearing_aid",
      "isConnected": true,
      "isAvailable": true,
      "batteryLevel": 67,
      "signalStrength": 88,
    },
    {
      "id": "headphones_1",
      "name": "Wired Headphones",
      "type": "headphones",
      "isConnected": false,
      "isAvailable": false,
      "batteryLevel": null,
      "signalStrength": null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSelectedDevice();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  void _initializeSelectedDevice() {
    // Find currently connected device
    final connectedDevice = _audioDevices.firstWhere(
      (device) => device['isConnected'] == true,
      orElse: () => _audioDevices.first,
    );
    _selectedDeviceId = connectedDevice['id'] as String;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleDeviceSelection(Map<String, dynamic> device) async {
    if (_isConnecting) return;

    final deviceId = device['id'] as String;
    final deviceName = device['name'] as String;
    final isConnected = device['isConnected'] as bool;

    // Haptic feedback
    HapticFeedback.selectionClick();

    // Handle Bluetooth connection if needed
    if (device['type'] == 'bluetooth' && !isConnected) {
      setState(() {
        _isConnecting = true;
      });

      // Simulate connection process
      await Future.delayed(const Duration(milliseconds: 1500));

      // Update device connection status
      final deviceIndex = _audioDevices.indexWhere((d) => d['id'] == deviceId);
      if (deviceIndex != -1) {
        setState(() {
          _audioDevices[deviceIndex]['isConnected'] = true;
          _isConnecting = false;
        });
      }
    }

    // Update selected device
    setState(() {
      // Disconnect previous device
      for (var d in _audioDevices) {
        if (d['id'] != deviceId) {
          d['isConnected'] = false;
        }
      }

      // Connect selected device
      final selectedIndex =
          _audioDevices.indexWhere((d) => d['id'] == deviceId);
      if (selectedIndex != -1) {
        _audioDevices[selectedIndex]['isConnected'] = true;
      }

      _selectedDeviceId = deviceId;
    });

    // Show confirmation and close
    _showSelectionConfirmation(deviceName);

    // Auto-dismiss after selection
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showSelectionConfirmation(String deviceName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.getSuccessColor(true),
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Audio switched to $deviceName',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 600),
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _handleBackgroundTap() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: GestureDetector(
        onTap: _handleBackgroundTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Background overlay
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),

                  // Bottom sheet content
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Transform.translate(
                      offset: Offset(
                          0,
                          MediaQuery.of(context).size.height *
                              _slideAnimation.value),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: 80.h,
                          minHeight: 40.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Handle bar
                            Container(
                              margin: EdgeInsets.only(top: 2.h),
                              width: 12.w,
                              height: 0.5.h,
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.dividerColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),

                            // Header
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 3.h),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'speaker',
                                    color: AppTheme.lightTheme.primaryColor,
                                    size: 6.w,
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Audio Device',
                                          style: AppTheme
                                              .lightTheme.textTheme.titleLarge
                                              ?.copyWith(
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurface,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          'Choose where to route your call audio',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurface
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Container(
                                      padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        color: AppTheme
                                            .lightTheme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: CustomIconWidget(
                                        iconName: 'close',
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                        size: 5.w,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Device list
                            Flexible(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    AudioDeviceListWidget(
                                      devices: _audioDevices
                                          .where((device) =>
                                              device['isAvailable'] == true)
                                          .toList(),
                                      selectedDeviceId: _selectedDeviceId,
                                      onDeviceSelected: _handleDeviceSelection,
                                    ),

                                    // Loading indicator
                                    if (_isConnecting)
                                      Container(
                                        padding: EdgeInsets.all(4.w),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 5.w,
                                              height: 5.w,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  AppTheme
                                                      .lightTheme.primaryColor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 3.w),
                                            Text(
                                              'Connecting...',
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: AppTheme
                                                    .lightTheme.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Bottom padding for safe area
                                    SizedBox(
                                        height: MediaQuery.of(context)
                                                .padding
                                                .bottom +
                                            2.h),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
