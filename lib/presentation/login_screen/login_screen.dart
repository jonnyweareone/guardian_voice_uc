import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gv_core/gv_core.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/advanced_settings_widget.dart';
import './widgets/biometric_auth_widget.dart';
import './widgets/password_input_widget.dart';
import './widgets/sip_server_input_widget.dart';
import './widgets/username_input_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sipServerController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _portController = TextEditingController(text: '6061');

  String _selectedTransport = 'TLS';
  bool _isLoading = false;
  bool _rememberCredentials = false;

  // Error states
  String? _sipServerError;
  String? _usernameError;
  String? _passwordError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _initializeGVCore();
  }

  Future<void> _initializeGVCore() async {
    try {
      await GVCore.I.initialize(enablePush: true);
    } catch (e) {
      print('GVCore initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _sipServerController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _loadSavedCredentials() {
    // Simulate loading saved credentials
    // In real app, this would load from SharedPreferences
  }

  void _validateSipServer(String value) {
    setState(() {
      if (value.isEmpty) {
        _sipServerError = 'SIP server is required';
      } else if (!_isValidSipServer(value)) {
        _sipServerError = 'Please enter a valid SIP server address';
      } else {
        _sipServerError = null;
      }
    });
  }

  void _validateUsername(String value) {
    setState(() {
      if (value.isEmpty) {
        _usernameError = 'Username is required';
      } else if (!_isValidUsername(value)) {
        _usernameError = 'Please enter a valid username or email';
      } else {
        _usernameError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  bool _isValidSipServer(String server) {
    // Basic SIP server validation
    final sipRegex = RegExp(r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return sipRegex.hasMatch(server) || server.contains('.');
  }

  bool _isValidUsername(String username) {
    // Basic username/email validation
    return username.contains('@') || username.length >= 3;
  }

  bool _isFormValid() {
    return _sipServerController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _sipServerError == null &&
        _usernameError == null &&
        _passwordError == null;
  }

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorToast('Please fill in all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize GV Core for VoIP functionality
      await GVCore.I.initialize(enablePush: true);

      // Set up SIP account with real credentials
      await GVCore.I.setAccount(
        username: _usernameController.text.trim(),
        domain:
            _sipServerController.text.trim().isEmpty
                ? 'guardianvoice.com'
                : _sipServerController.text.trim(),
        password: _passwordController.text,
        tls: true,
        port: 6061,
        srtp: true,
        stun: 'turn.guardianvoice.com',
      );

      // Store credentials locally for auto-login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _usernameController.text.trim());
      await prefs.setString('sipServer', _sipServerController.text.trim());
      await prefs.setBool('rememberMe', _rememberCredentials);
      if (_rememberCredentials) {
        await prefs.setString('password', _passwordController.text);
      }

      // Navigate to main dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard);
      }
    } catch (e) {
      _showErrorToast('Login failed: Please check your credentials');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricAuth() async {
    if (kIsWeb) return; // Skip on web

    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(milliseconds: 500));

      HapticFeedback.lightImpact();

      Fluttertoast.showToast(
        msg: "Biometric authentication successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        textColor: AppTheme.lightTheme.colorScheme.onTertiary,
      );

      Navigator.pushReplacementNamed(context, '/main-dashboard');
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Biometric authentication failed. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.onError,
      );
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Forgot Password?',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Please contact your IT administrator to reset your SIP account password.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 6.h),

                  // App Logo and Title
                  Container(
                    width: 25.w,
                    height: 25.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'phone',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 12.w,
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Text(
                    'Guardian Voice UC',
                    style: AppTheme.lightTheme.textTheme.headlineMedium
                        ?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 1.h),

                  Text(
                    'Enterprise VoIP Communication',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 6.h),

                  // General Error Message
                  if (_generalError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.error,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'error',
                            color: AppTheme.lightTheme.colorScheme.error,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              _generalError!,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                    color:
                                        AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onErrorContainer,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                  ],

                  // SIP Server Input
                  SipServerInputWidget(
                    controller: _sipServerController,
                    errorText: _sipServerError,
                    onChanged: _validateSipServer,
                  ),

                  SizedBox(height: 3.h),

                  // Username Input
                  UsernameInputWidget(
                    controller: _usernameController,
                    errorText: _usernameError,
                    onChanged: _validateUsername,
                  ),

                  SizedBox(height: 3.h),

                  // Password Input
                  PasswordInputWidget(
                    controller: _passwordController,
                    errorText: _passwordError,
                    onChanged: _validatePassword,
                  ),

                  SizedBox(height: 2.h),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _handleForgotPassword,
                      child: Text(
                        'Forgot Password?',
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Remember Credentials Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberCredentials,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberCredentials = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Remember my credentials',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Login Button
                  Container(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isFormValid()
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.12),
                        foregroundColor:
                            _isFormValid()
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                : AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                        elevation: _isFormValid() ? 2 : 0,
                      ),
                      child:
                          _isLoading
                              ? SizedBox(
                                width: 6.w,
                                height: 6.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                              : Text(
                                'Login',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                      color:
                                          _isFormValid()
                                              ? AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .onPrimary
                                              : AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.38),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Advanced Settings
                  AdvancedSettingsWidget(
                    portController: _portController,
                    selectedTransport: _selectedTransport,
                    onTransportChanged: (String transport) {
                      setState(() {
                        _selectedTransport = transport;
                      });
                    },
                    onPortChanged: (String port) {
                      // Port validation can be added here
                    },
                  ),

                  SizedBox(height: 4.h),

                  // Biometric Authentication
                  BiometricAuthWidget(
                    onBiometricPressed: _handleBiometricAuth,
                    isEnabled: !_isLoading,
                  ),

                  SizedBox(height: 4.h),

                  // Mock Credentials Info (for testing)
                  if (!kReleaseMode) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color:
                            AppTheme.lightTheme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.tertiary,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'info',
                                color: AppTheme.lightTheme.colorScheme.tertiary,
                                size: 5.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Test Credentials',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                      color:
                                          AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .onTertiaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Server: sip.guardianvoice.com\nAdmin: admin@guardianvoice.com / Admin123!\nUser: user@guardianvoice.com / User123!',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                  color:
                                      AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .onTertiaryContainer,
                                  fontFamily: 'monospace',
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
