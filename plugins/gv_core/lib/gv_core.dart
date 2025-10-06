import 'package:flutter/services.dart';

class GVCore {
  static const MethodChannel _channel = MethodChannel('gv_core');
  
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      print('Failed to initialize GVCore: ${e.message}');
      rethrow;
    }
  }
  
  Future<void> setProxy({
    required String domain,
    required int port,
    required String transport,
  }) async {
    try {
      await _channel.invokeMethod('setProxy', {
        'domain': domain,
        'port': port,
        'transport': transport,
      });
    } on PlatformException catch (e) {
      print('Failed to set proxy: ${e.message}');
      rethrow;
    }
  }
  
  Future<void> setStunServer(String server) async {
    try {
      await _channel.invokeMethod('setStunServer', {'server': server});
    } on PlatformException catch (e) {
      print('Failed to set STUN server: ${e.message}');
      rethrow;
    }
  }
  
  Future<void> enableEchoCancellation(bool enable) async {
    try {
      await _channel.invokeMethod('enableEchoCancellation', {'enable': enable});
    } on PlatformException catch (e) {
      print('Failed to set echo cancellation: ${e.message}');
      rethrow;
    }
  }
  
  Future<void> setAudioCodecs(List<String> codecs) async {
    try {
      await _channel.invokeMethod('setAudioCodecs', {'codecs': codecs});
    } on PlatformException catch (e) {
      print('Failed to set audio codecs: ${e.message}');
      rethrow;
    }
  }
  
  Future<bool> register({
    required String username,
    required String password,
    required String domain,
  }) async {
    try {
      final result = await _channel.invokeMethod('register', {
        'username': username,
        'password': password,
        'domain': domain,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to register: ${e.message}');
      return false;
    }
  }
  
  Future<void> unregister() async {
    try {
      await _channel.invokeMethod('unregister');
    } on PlatformException catch (e) {
      print('Failed to unregister: ${e.message}');
      rethrow;
    }
  }
  
  Future<bool> makeCall(String number) async {
    try {
      final result = await _channel.invokeMethod('makeCall', {'number': number});
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to make call: ${e.message}');
      return false;
    }
  }
  
  Future<void> answerCall() async {
    try {
      await _channel.invokeMethod('answerCall');
    } on PlatformException catch (e) {
      print('Failed to answer call: ${e.message}');
      rethrow;
    }
  }
  
  Future<void> endCall() async {
    try {
      await _channel.invokeMethod('endCall');
    } on PlatformException catch (e) {
      print('Failed to end call: ${e.message}');
      rethrow;
    }
  }
  
  Future<void> toggleMute() async {
    try {
      await _channel.invokeMethod('toggleMute');
    } on PlatformException catch (e) {
      print('Failed to toggle mute: ${e.message}');
      rethrow;
    }
  }
  
  Future<void> toggleSpeaker() async {
    try {
      await _channel.invokeMethod('toggleSpeaker');
    } on PlatformException catch (e) {
      print('Failed to toggle speaker: ${e.message}');
      rethrow;
    }
  }
  
  Future<void> sendDTMF(String digit) async {
    try {
      await _channel.invokeMethod('sendDTMF', {'digit': digit});
    } on PlatformException catch (e) {
      print('Failed to send DTMF: ${e.message}');
      rethrow;
    }
  }
  
  void dispose() {
    // Cleanup resources if needed
  }
}
