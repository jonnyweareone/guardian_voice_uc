import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MicrophoneLevelWidget extends StatefulWidget {
  final double gain;
  final ValueChanged<double> onGainChanged;

  const MicrophoneLevelWidget({
    Key? key,
    required this.gain,
    required this.onGainChanged,
  }) : super(key: key);

  @override
  State<MicrophoneLevelWidget> createState() => _MicrophoneLevelWidgetState();
}

class _MicrophoneLevelWidgetState extends State<MicrophoneLevelWidget>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  double _currentLevel = 0.0;
  late AnimationController _animationController;
  late Animation<double> _levelAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _levelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _stopRecording();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: 'temp_recording.m4a',
        );
        setState(() {
          _isRecording = true;
        });
        _simulateLevelUpdates();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (_isRecording) {
        await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
          _currentLevel = 0.0;
        });
        _animationController.reset();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _simulateLevelUpdates() {
    if (!_isRecording) return;

    // Simulate microphone level changes
    Future.delayed(Duration(milliseconds: 100), () {
      if (_isRecording && mounted) {
        setState(() {
          _currentLevel = (0.1 + (0.9 * widget.gain)) *
              (0.3 +
                  0.7 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000);
        });
        _animationController.animateTo(_currentLevel);
        _simulateLevelUpdates();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'mic',
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Microphone Gain',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Text(
                '${(widget.gain * 100).round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Gain Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              trackHeight: 4.0,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
            ),
            child: Slider(
              value: widget.gain,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              onChanged: widget.onGainChanged,
            ),
          ),

          SizedBox(height: 1.h),

          // Level Meter
          Row(
            children: [
              Text(
                'Level Test:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: AnimatedBuilder(
                    animation: _levelAnimation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _levelAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _currentLevel > 0.8
                                ? Colors.red
                                : _currentLevel > 0.6
                                    ? Colors.orange
                                    : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? Colors.red.withValues(alpha: 0.1)
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CustomIconWidget(
                    iconName: _isRecording ? 'stop' : 'play_arrow',
                    color: _isRecording
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}