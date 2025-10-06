import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _progressAnimation;

  Timer? _splashTimer;
  Timer? _timeoutTimer;

  String _statusText = 'Initializing Guardian Voice UC...';
  bool _showRetryButton = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSplashSequence();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress animation controller
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo opacity animation
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start logo animation
    _logoAnimationController.forward();
  }

  void _startSplashSequence() {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppTheme.lightTheme.primaryColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Start progress animation after logo appears
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _progressAnimationController.forward();
      }
    });

    // Start initialization process
    _initializeApp();

    // Set timeout timer
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isInitializing) {
        _handleTimeout();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate SIP registration initialization
      await _updateStatus('Checking network connectivity...');
      await Future.delayed(const Duration(milliseconds: 600));

      await _updateStatus('Initializing VoIP engine...');
      await Future.delayed(const Duration(milliseconds: 800));

      await _updateStatus('Checking SIP credentials...');
      await Future.delayed(const Duration(milliseconds: 700));

      await _updateStatus('Preparing push notifications...');
      await Future.delayed(const Duration(milliseconds: 500));

      await _updateStatus('Ready to connect...');
      await Future.delayed(const Duration(milliseconds: 400));

      // Simulate authentication check
      final bool isAuthenticated = await _checkAuthenticationStatus();

      if (mounted) {
        _isInitializing = false;
        _navigateToNextScreen(isAuthenticated);
      }
    } catch (e) {
      if (mounted) {
        _handleInitializationError();
      }
    }
  }

  Future<void> _updateStatus(String status) async {
    if (mounted) {
      setState(() {
        _statusText = status;
      });
    }
  }

  Future<bool> _checkAuthenticationStatus() async {
    // Simulate checking stored credentials
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock authentication logic - in real app, check stored SIP credentials
    // For demo purposes, randomly determine authentication state
    return DateTime.now().millisecondsSinceEpoch % 3 == 0;
  }

  void _handleTimeout() {
    setState(() {
      _statusText = 'Connection timeout. Please check your network.';
      _showRetryButton = true;
      _isInitializing = false;
    });
  }

  void _handleInitializationError() {
    setState(() {
      _statusText = 'Initialization failed. Please try again.';
      _showRetryButton = true;
      _isInitializing = false;
    });
  }

  void _retryInitialization() {
    setState(() {
      _statusText = 'Retrying initialization...';
      _showRetryButton = false;
      _isInitializing = true;
    });

    // Reset progress animation
    _progressAnimationController.reset();
    _progressAnimationController.forward();

    // Cancel existing timers
    _timeoutTimer?.cancel();

    // Restart initialization
    _initializeApp();

    // Reset timeout timer
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isInitializing) {
        _handleTimeout();
      }
    });
  }

  void _navigateToNextScreen(bool isAuthenticated) {
    // Cancel timers
    _splashTimer?.cancel();
    _timeoutTimer?.cancel();

    // Smooth fade transition
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        if (isAuthenticated) {
          Navigator.pushReplacementNamed(context, '/main-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/login-screen');
        }
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _progressAnimationController.dispose();
    _splashTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.primaryColor,
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
              AppTheme.lightTheme.colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top spacer
              SizedBox(height: 15.h),

              // Logo section
              Expanded(
                flex: 3,
                child: AnimatedBuilder(
                  animation: _logoAnimationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo container
                            Container(
                              width: 25.w,
                              height: 25.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.w),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomIconWidget(
                                  iconName: 'phone',
                                  size: 12.w,
                                  color: AppTheme.lightTheme.primaryColor,
                                ),
                              ),
                            ),

                            SizedBox(height: 4.h),

                            // App name
                            Text(
                              'Guardian Voice UC',
                              style: AppTheme
                                  .lightTheme.textTheme.headlineMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 1.h),

                            // Tagline
                            Text(
                              'Enterprise VoIP Communication',
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Status and progress section
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status text
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        _statusText,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Progress indicator or retry button
                    _showRetryButton
                        ? _buildRetryButton()
                        : _buildProgressIndicator(),
                  ],
                ),
              ),

              // Bottom section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Version info
                    Text(
                      'Version 1.0.0',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11.sp,
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Copyright
                    Text(
                      '© 2024 Guardian Voice UC',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10.sp,
                      ),
                    ),

                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        // Circular progress indicator
        SizedBox(
          width: 8.w,
          height: 8.w,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2.0,
          ),
        ),

        SizedBox(height: 2.h),

        // Linear progress bar
        Container(
          width: 60.w,
          height: 0.5.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1.w),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton(
      onPressed: _retryInitialization,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.lightTheme.primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'refresh',
            size: 5.w,
            color: AppTheme.lightTheme.primaryColor,
          ),
          SizedBox(width: 2.w),
          Text(
            'Retry',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
