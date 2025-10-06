import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gv_core/gv_core.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/call_controls_widget.dart';
import './widgets/call_options_widget.dart';
import './widgets/call_status_widget.dart';
import './widgets/caller_info_widget.dart';

class InCallScreen extends StatefulWidget {
  const InCallScreen({Key? key}) : super(key: key);

  @override
  State<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends State<InCallScreen>
    with TickerProviderStateMixin {
  // Call state variables
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isOnHold = false;
  bool _isRecording = false;
  bool _showOptions = false;

  // Real call data from navigation arguments
  String? _callId;
  String? _sipUri;
  Map<String, dynamic>? _contact;
  bool _isIncoming = false;

  // Call timer
  late DateTime _callStartTime;
  String _callDuration = "00:00";

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _extractCallArguments();
    _initializeCall();
    _setupAnimations();
    _startCallTimer();
  }

  void _extractCallArguments() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _callId = args['callId'];
      _sipUri = args['sipUri'];
      _contact = args['contact'];
      _isIncoming = args['isIncoming'] ?? false;
    }
  }

  void _initializeCall() {
    _callStartTime = DateTime.now();

    // Set system UI overlay style for in-call screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Keep screen on during call
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          final duration = DateTime.now().difference(_callStartTime);
          final minutes = duration.inMinutes.toString().padLeft(2, '0');
          final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
          _callDuration = "$minutes:$seconds";
        });
        _startCallTimer();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    super.dispose();
  }

  Future<void> _handleMuteToggle() async {
    try {
      await GVCore.I.mute(_callId ?? '', !_isMuted);

      setState(() {
        _isMuted = !_isMuted;
      });

      HapticFeedback.lightImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isMuted ? 'Microphone muted' : 'Microphone unmuted'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('Mute toggle failed: $e');
    }
  }

  void _handleSpeakerToggle() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });

    HapticFeedback.lightImpact();

    // Real speaker toggle would be handled by native audio session management
    // in the gv_core plugin (iOS: GvAudio.speaker(), Android: AudioManager)

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSpeakerOn ? 'Speaker enabled' : 'Speaker disabled'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleHoldToggle() async {
    try {
      await GVCore.I.hold(_callId ?? '', !_isOnHold);

      setState(() {
        _isOnHold = !_isOnHold;
      });

      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isOnHold ? 'Call on hold' : 'Call resumed'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('Hold toggle failed: $e');
    }
  }

  void _handleAddCall() {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Call'),
            content: const Text(
              'This feature allows you to add another participant to the call.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to contacts or dialer
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _handleKeypadOpen() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/dtmf-keypad');
  }

  Future<void> _handleEndCall() async {
    HapticFeedback.heavyImpact();

    try {
      await GVCore.I.hangup(_callId ?? '');

      Navigator.pushReplacementNamed(context, '/main-dashboard');
    } catch (e) {
      print('End call failed: $e');
      // Still navigate back on error
      Navigator.pushReplacementNamed(context, '/main-dashboard');
    }
  }

  Future<void> _handleAnswerCall() async {
    if (!_isIncoming || _callId == null) return;

    try {
      await GVCore.I.answer(_callId!);

      setState(() {
        _isIncoming = false; // Mark as answered
      });

      HapticFeedback.lightImpact();
    } catch (e) {
      print('Answer call failed: $e');
    }
  }

  void _handleAudioDevicePicker() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/audio-device-picker');
  }

  void _handleMinimize() {
    HapticFeedback.lightImpact();

    // Minimize to picture-in-picture mode
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Call minimized to background'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pushReplacementNamed(context, '/main-dashboard');
  }

  void _handleTransfer() {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Transfer Call'),
            content: const Text(
              'Transfer this call to another number or contact.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to transfer interface
                },
                child: const Text('Transfer'),
              ),
            ],
          ),
    );
  }

  void _handleRecord() {
    setState(() {
      _isRecording = !_isRecording;
    });

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isRecording ? 'Call recording started' : 'Call recording stopped',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _isRecording ? AppTheme.getErrorColor(true) : null,
      ),
    );
  }

  void _handleConference() {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Conference Call'),
            content: const Text(
              'Start a conference call with multiple participants.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to conference interface
                },
                child: const Text('Start Conference'),
              ),
            ],
          ),
    );
  }

  void _toggleOptions() {
    setState(() {
      _showOptions = !_showOptions;
    });

    if (_showOptions) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update caller data to use real call information
    final Map<String, dynamic> callerData =
        _contact ??
        {
          "name": _isIncoming ? "Incoming Call" : "Outgoing Call",
          "number": _sipUri ?? "Unknown",
          "photo": null,
          "company": "",
          "isContact": _contact != null,
        };

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            // Handle swipe gestures
            if (details.delta.dy > 10) {
              _handleMinimize();
            } else if (details.delta.dy < -10) {
              _toggleOptions();
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.8), Colors.black],
              ),
            ),
            child: Column(
              children: [
                // Top section - Caller Info
                Expanded(
                  flex: 4,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isOnHold ? 0.95 : _pulseAnimation.value,
                        child: CallerInfoWidget(
                          callerData: callerData,
                          callDuration: _callDuration,
                        ),
                      );
                    },
                  ),
                ),

                // Middle section - Call Status
                Expanded(
                  flex: 1,
                  child: CallStatusWidget(callStatus: _callStatus),
                ),

                // Warning banner for poor connection
                if (_callStatus['connectionQuality'] == 'poor')
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 1.h,
                    ),
                    color: AppTheme.getWarningColor(
                      true,
                    ).withValues(alpha: 0.2),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'warning',
                          size: 4.w,
                          color: AppTheme.getWarningColor(true),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Poor connection quality',
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(color: AppTheme.getWarningColor(true)),
                        ),
                      ],
                    ),
                  ),

                // Bottom section - Call Controls
                Expanded(
                  flex: 3,
                  child: CallControlsWidget(
                    isMuted: _isMuted,
                    isSpeakerOn: _isSpeakerOn,
                    isOnHold: _isOnHold,
                    onMuteToggle: _handleMuteToggle,
                    onSpeakerToggle: _handleSpeakerToggle,
                    onHoldToggle: _handleHoldToggle,
                    onAddCall: _handleAddCall,
                    onKeypadOpen: _handleKeypadOpen,
                    onEndCall: _handleEndCall,
                    onAudioDevicePicker: _handleAudioDevicePicker,
                  ),
                ),

                // Additional options (slide up)
                SlideTransition(
                  position: _slideAnimation,
                  child: CallOptionsWidget(
                    onMinimize: _handleMinimize,
                    onTransfer: _handleTransfer,
                    onRecord: _handleRecord,
                    onConference: _handleConference,
                    isRecording: _isRecording,
                  ),
                ),

                // Swipe indicator
                Container(
                  width: 12.w,
                  height: 0.5.h,
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
