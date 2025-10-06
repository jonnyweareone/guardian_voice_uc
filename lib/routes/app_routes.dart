import 'package:flutter/material.dart';
import '../presentation/audio_device_picker/audio_device_picker.dart';
import '../presentation/in_call_screen/in_call_screen.dart';
import '../presentation/main_dashboard/main_dashboard.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/dtmf_keypad/dtmf_keypad.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/call_history/call_history.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String audioDevicePicker = '/audio-device-picker';
  static const String inCall = '/in-call-screen';
  static const String mainDashboard = '/main-dashboard';
  static const String splash = '/splash-screen';
  static const String settings = '/settings-screen';
  static const String dtmfKeypad = '/dtmf-keypad';
  static const String login = '/login-screen';
  static const String callHistory = '/call-history';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    audioDevicePicker: (context) => const AudioDevicePicker(),
    inCall: (context) => const InCallScreen(),
    mainDashboard: (context) => const MainDashboard(),
    splash: (context) => const SplashScreen(),
    settings: (context) => const SettingsScreen(),
    dtmfKeypad: (context) => const DtmfKeypad(),
    login: (context) => const LoginScreen(),
    callHistory: (context) => const CallHistory(),
    // TODO: Add your other routes here
  };
}
