import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:guardian_voice_uc/plugins/gv_core/gv_core.dart';

class SipService {
  static const platform = MethodChannel('com.guardian_voice_uc/sip');
  late GVCore _core;
  Map<String, dynamic>? _config;
  
  Future<void> initialize() async {
    try {
      // Load configuration
      await _loadConfig();
      
      // Initialize GV Core (Linphone wrapper)
      _core = GVCore();
      await _core.initialize();
      
      // Configure SIP settings
      await _configureSip();
    } catch (e) {
      print('Failed to initialize SIP Service: $e');
    }
  }
  
  Future<void> _loadConfig() async {
    try {
      final configFile = File('env.json');
      if (await configFile.exists()) {
        final contents = await configFile.readAsString();
        _config = json.decode(contents);
      }
    } catch (e) {
      print('Failed to load config: $e');
    }
  }
  
  Future<void> _configureSip() async {
    if (_config == null) return;
    
    try {
      // Set SIP proxy
      await _core.setProxy(
        domain: _config!['SIP_DOMAIN'] ?? 'sip.guardianvoice.co.uk',
        port: int.parse(_config!['SIP_PORT'] ?? '5060'),
        transport: _config!['SIP_TRANSPORT'] ?? 'UDP',
      );
      
      // Set STUN server
      await _core.setStunServer(_config!['STUN_SERVER'] ?? 'stun.guardianvoice.co.uk:3478');
      
      // Enable echo cancellation
      await _core.enableEchoCancellation(true);
      
      // Set audio codecs
      await _core.setAudioCodecs(['OPUS', 'PCMU', 'PCMA']);
    } catch (e) {
      print('Failed to configure SIP: $e');
    }
  }
  
  Future<bool> register(String username, String password, String domain) async {
    try {
      return await _core.register(
        username: username,
        password: password,
        domain: domain,
      );
    } catch (e) {
      print('Registration failed: $e');
      return false;
    }
  }
  
  Future<void> unregister() async {
    try {
      await _core.unregister();
    } catch (e) {
      print('Unregistration failed: $e');
    }
  }
  
  Future<bool> makeCall(String number) async {
    try {
      return await _core.makeCall(number);
    } catch (e) {
      print('Failed to make call: $e');
      return false;
    }
  }
  
  Future<void> answerCall() async {
    try {
      await _core.answerCall();
    } catch (e) {
      print('Failed to answer call: $e');
    }
  }
  
  Future<void> endCall() async {
    try {
      await _core.endCall();
    } catch (e) {
      print('Failed to end call: $e');
    }
  }
  
  Future<void> toggleMute() async {
    try {
      await _core.toggleMute();
    } catch (e) {
      print('Failed to toggle mute: $e');
    }
  }
  
  Future<void> toggleSpeaker() async {
    try {
      await _core.toggleSpeaker();
    } catch (e) {
      print('Failed to toggle speaker: $e');
    }
  }
  
  Future<void> sendDTMF(String digit) async {
    try {
      await _core.sendDTMF(digit);
    } catch (e) {
      print('Failed to send DTMF: $e');
    }
  }
  
  void dispose() {
    _core.dispose();
  }
}
