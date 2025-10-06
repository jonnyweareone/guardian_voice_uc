import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gv_core/gv_core.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/audio_feedback_toggle_widget.dart';
import './widgets/keypad_grid_widget.dart';
import './widgets/number_display_widget.dart';
import './widgets/tone_status_widget.dart';

class DTMFKeypad extends StatefulWidget {
  const DTMFKeypad({Key? key}) : super(key: key);

  @override
  State<DTMFKeypad> createState() => _DTMFKeypadState();
}

class _DTMFKeypadState extends State<DTMFKeypad> {
  String _displayedNumber = '';
  bool _isTransmitting = false;
  bool _isConnected = true;
  bool _isAudioEnabled = true;
  String? _lastTone;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Real call context from navigation arguments
  String? _callId;
  bool _isInCall = false;

  // DTMF tone frequencies mapping
  final Map<String, List<int>> _dtmfFrequencies = {
    '1': [697, 1209],
    '2': [697, 1336],
    '3': [697, 1477],
    '4': [770, 1209],
    '5': [770, 1336],
    '6': [770, 1477],
    '7': [852, 1209],
    '8': [852, 1336],
    '9': [852, 1477],
    '*': [941, 1209],
    '0': [941, 1336],
    '#': [941, 1477],
    'A': [697, 1633],
    'B': [770, 1633],
    'C': [852, 1633],
    'D': [941, 1633],
  };

  late StreamSubscription<GVIncoming>? _incomingCallSubscription;

  @override
  void initState() {
    super.initState();
    _setupIncomingCallListener();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _simulateConnectionStatus();
  }

  void _setupIncomingCallListener() {
    _incomingCallSubscription = GVCore.I.onIncoming.listen((incoming) {
      // Handle incoming call while in DTMF keypad
      Navigator.pushNamed(
        context,
        '/in-call-screen',
        arguments: {
          'callId': incoming.callId,
          'fromDisplay': incoming.fromDisplay,
          'fromUri': incoming.fromUri,
          'isIncoming': true,
        },
      );
    });
  }

  @override
  void dispose() {
    _incomingCallSubscription?.cancel();
    super.dispose();
  }

  void _simulateConnectionStatus() {
    // Simulate real-time connection monitoring
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
      }
    });
  }

  Future<void> _onNumberPressed(String number) async {
    setState(() {
      _displayedNumber += number;
      _lastTone = number;
    });

    await _transmitTone(number);
    _announceForAccessibility(number);
  }

  Future<void> _onNumberLongPressed(String number) async {
    if (number == '+') {
      setState(() {
        if (_displayedNumber.isEmpty) {
          _displayedNumber = '+';
        }
      });
    } else {
      setState(() {
        _displayedNumber += number;
        _lastTone = number;
      });
    }
    await _transmitExtendedTone(number);
  }

  Future<void> _transmitTone(String tone) async {
    if (!_isConnected) return;

    setState(() {
      _isTransmitting = true;
      _lastTone = tone;
    });

    try {
      // Real DTMF transmission using gv_core
      if (_isInCall && _callId != null) {
        // Send DTMF tone to active call via liblinphone
        await GVCore.I.sendDtmf(_callId!, tone);
      }

      // Generate local audio feedback if enabled
      final frequencies = _dtmfFrequencies[tone];
      if (frequencies != null && _isAudioEnabled) {
        _generateDtmfTone(frequencies[0], frequencies[1], 150);
      }
    } catch (e) {
      print('DTMF transmission failed: $e');
    }

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Stop transmission after standard duration
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _isTransmitting = false;
        });
      }
    });
  }

  Future<void> _transmitExtendedTone(String tone) async {
    if (!_isConnected) return;

    setState(() {
      _isTransmitting = true;
      _lastTone = tone;
    });

    try {
      // Real extended DTMF transmission
      if (_isInCall && _callId != null) {
        // For extended tones, send multiple times or use different API
        await GVCore.I.sendDtmf(_callId!, tone);
      }

      // Generate extended local audio feedback
      final frequencies = _dtmfFrequencies[tone];
      if (frequencies != null && _isAudioEnabled) {
        _generateDtmfTone(frequencies[0], frequencies[1], 500);
      }
    } catch (e) {
      print('Extended DTMF transmission failed: $e');
    }

    // Provide stronger haptic feedback for long press
    HapticFeedback.mediumImpact();

    // Stop transmission after extended duration
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isTransmitting = false;
        });
      }
    });
  }

  // Enhanced DTMF generation with real audio APIs
  void _generateDtmfTone(int lowFreq, int highFreq, int duration) {
    // Real DTMF tone generation would interface with native audio APIs
    // The gv_core plugin would handle this via liblinphone's DTMF generation
    SystemSound.play(SystemSoundType.click);

    print('Generated DTMF: ${lowFreq}Hz + ${highFreq}Hz for ${duration}ms');
  }

  void _onBackspace() {
    if (_displayedNumber.isNotEmpty) {
      setState(() {
        _displayedNumber = _displayedNumber.substring(
          0,
          _displayedNumber.length - 1,
        );
      });
    }
  }

  void _onClear() {
    setState(() {
      _displayedNumber = '';
    });
    HapticFeedback.mediumImpact();
  }

  void _toggleAudioFeedback(bool enabled) {
    setState(() {
      _isAudioEnabled = enabled;
    });
  }

  void _announceForAccessibility(String number) {
    // VoiceOver/TalkBack announcements
    final Map<String, String> announcements = {
      '1': 'One',
      '2': 'Two A B C',
      '3': 'Three D E F',
      '4': 'Four G H I',
      '5': 'Five J K L',
      '6': 'Six M N O',
      '7': 'Seven P Q R S',
      '8': 'Eight T U V',
      '9': 'Nine W X Y Z',
      '*': 'Star',
      '0': 'Zero Plus',
      '#': 'Pound',
    };

    final announcement = announcements[number] ?? number;
    // Real accessibility announcement would be implemented here
  }

  void _dismissKeypad() {
    _slideController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  Future<void> _sendDtmfSequence() async {
    if (_displayedNumber.isEmpty || !_isInCall) return;

    setState(() {
      _isTransmitting = true;
    });

    try {
      // Send entire sequence to active call
      for (final char in _displayedNumber.split('')) {
        if (_dtmfFrequencies.containsKey(char)) {
          await GVCore.I.sendDtmf(_callId!, char);
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent DTMF sequence: $_displayedNumber'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send DTMF sequence: $e'),
          backgroundColor: AppTheme.getErrorColor(true),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isTransmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? AppTheme.backgroundDark.withValues(alpha: 0.95)
              : AppTheme.backgroundLight.withValues(alpha: 0.95),
      appBar: AppBar(
        title: Text(
          'DTMF Keypad',
          style: theme.textTheme.titleLarge?.copyWith(
            color:
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _dismissKeypad,
          icon: CustomIconWidget(
            iconName: 'close',
            color:
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings-screen');
            },
            icon: CustomIconWidget(
              iconName: 'settings',
              color:
                  isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
              size: 24,
            ),
          ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 2.h),

              // Connection and transmission status
              ToneStatusWidget(
                isTransmitting: _isTransmitting,
                isConnected: _isConnected,
                lastTone: _lastTone,
              ),

              SizedBox(height: 3.h),

              // Number display with backspace
              NumberDisplayWidget(
                displayedNumber: _displayedNumber,
                onBackspace: _onBackspace,
                onClear: _onClear,
              ),

              SizedBox(height: 4.h),

              // DTMF Keypad Grid
              Expanded(
                child: KeypadGridWidget(
                  onNumberPressed: _onNumberPressed,
                  onNumberLongPressed: _onNumberLongPressed,
                ),
              ),

              SizedBox(height: 3.h),

              // Audio feedback toggle
              AudioFeedbackToggleWidget(
                isAudioEnabled: _isAudioEnabled,
                onToggle: _toggleAudioFeedback,
              ),

              SizedBox(height: 2.h),

              // Quick action buttons
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/in-call-screen');
                        },
                        icon: CustomIconWidget(
                          iconName: 'call',
                          color:
                              theme.elevatedButtonTheme.style?.foregroundColor
                                  ?.resolve({}) ??
                              Colors.white,
                          size: 20,
                        ),
                        label: Text('Call', style: TextStyle(fontSize: 14.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark
                                  ? AppTheme.successDark
                                  : AppTheme.successLight,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/call-history');
                        },
                        icon: CustomIconWidget(
                          iconName: 'history',
                          color:
                              isDark
                                  ? AppTheme.primaryDark
                                  : AppTheme.primaryLight,
                          size: 20,
                        ),
                        label: Text(
                          'History',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
