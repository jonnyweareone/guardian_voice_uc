library gv_core;

import 'dart:async';
import 'package:flutter/services.dart';

class GVIncoming {
  final String callId;
  final String fromDisplay;
  final String fromUri;
  GVIncoming(this.callId, this.fromDisplay, this.fromUri);
}

class GVCore {
  GVCore._();
  static final GVCore I = GVCore._();

  static const MethodChannel _m = MethodChannel('gv/core/methods');
  static const EventChannel _calls = EventChannel('gv/core/calls');

  Stream<GVIncoming> get onIncoming =>
      _calls.receiveBroadcastStream().map((e) => GVIncoming(
          e['callId'], e['fromDisplay'] ?? '', e['fromUri'] ?? ''));

  Future<void> initialize({required bool enablePush}) =>
      _m.invokeMethod('initialize', {'enablePush': enablePush});

  Future<void> registerPushToken({required String token, required String platform}) =>
      _m.invokeMethod('registerPushToken', {'token': token, 'platform': platform});

  Future<void> setAccount({
    required String username,
    required String domain,
    required String password,
    bool tls = true,
    int port = 6061,
    bool srtp = true,
    String? stun,
    String? turn,
  }) => _m.invokeMethod('setAccount', {
        'username': username, 'domain': domain, 'password': password,
        'tls': tls, 'port': port, 'srtp': srtp, 'stun': stun, 'turn': turn,
      });

  Future<void> placeCall(String sipUri) => _m.invokeMethod('placeCall', {'uri': sipUri});
  Future<void> answer(String callId) => _m.invokeMethod('answer', {'callId': callId});
  Future<void> hangup(String callId) => _m.invokeMethod('hangup', {'callId': callId});
  Future<void> mute(String callId, bool on) => _m.invokeMethod('mute', {'callId': callId, 'on': on});
  Future<void> hold(String callId, bool on) => _m.invokeMethod('hold', {'callId': callId, 'on': on});
}