import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:guardian_voice_uc/app.dart';
import 'package:guardian_voice_uc/services/sip_service.dart';
import 'package:guardian_voice_uc/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize SIP Service
  final sipService = SipService();
  await sipService.initialize();
  
  // Initialize Push Notifications
  final pushService = PushNotificationService();
  await pushService.initialize();
  
  runApp(const GuardianVoiceUCApp());
}
