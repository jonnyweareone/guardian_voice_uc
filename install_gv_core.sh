#!/usr/bin/env bash
set -euo pipefail

BASE="plugins/gv_core"
echo "Creating $BASE ..."
mkdir -p "$BASE"/{lib,android/src/main/kotlin/com/guardianvoice/uc/core/{lin,telecom,push},ios/Classes}

# pubspec.yaml
cat > "$BASE/pubspec.yaml" <<'YAML'
name: gv_core
description: Guardian Voice UC native glue (Push + Call UI + SIP/media via liblinphone)
version: 0.1.0
environment:
  sdk: ">=3.4.0 <4.0.0"
  flutter: ">=3.22.0"

flutter:
  plugin:
    platforms:
      android:
        package: com.guardianvoice.uc.core
        pluginClass: GvCorePlugin
      ios:
        pluginClass: GvCorePlugin

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_lints: ^4.0.0
YAML

# README
cat > "$BASE/README.md" <<'MD'
# gv_core — Guardian Voice UC native plugin

Native SIP/media via **liblinphone**, OS-level call UI (ConnectionService/CallKit), and push-to-ring (FCM/APNs VoIP).
See INTEGRATION.md for setup.
MD

# INTEGRATION
cat > "$BASE/INTEGRATION.md" <<'MD'
# Integration guide — gv_core

## 1) Add dependency (in your Flutter app pubspec.yaml)
```yaml
dependencies:
  gv_core:
    path: ../../plugins/gv_core
```

Then `flutter pub get`.

## 2) Android project config

Project `build.gradle` (or settings.gradle repos):

```gradle
buildscript {
  repositories {
    google()
    mavenCentral()
    maven { url "https://linphone.org/snapshots/maven_repository" }
  }
  dependencies {
    classpath 'com.google.gms:google-services:4.4.2'
  }
}
allprojects {
  repositories {
    google()
    mavenCentral()
    maven { url "https://linphone.org/snapshots/maven_repository" }
  }
}
```

App `android/app/build.gradle`:

```gradle
plugins { id "com.google.gms.google-services" }
dependencies {
  implementation platform('com.google.firebase:firebase-bom:33.1.2')
  implementation 'com.google.firebase:firebase-messaging'
}
```

Place `google-services.json` in `android/app/`.

## 3) iOS project config

`ios/Podfile`:

```ruby
platform :ios, '13.0'
use_frameworks!
use_modular_headers!
```

Xcode (Runner target):

* Background Modes: **Audio**, **Voice over IP**, **Processing**
* Capabilities: **Push Notifications**
* Entitlements: `aps-environment` + `com.apple.developer.pushkit.unrestricted-voip`

Then:

```
cd ios && pod install
```

## 4) Flutter usage

```dart
import 'package:gv_core/gv_core.dart';

await GVCore.I.initialize(enablePush: true);
await GVCore.I.setAccount(
  username: '1001',
  domain: 'guardianvoice.com',
  password: 'SECRET',
  tls: true, port: 6061, srtp: true, stun: 'turn.guardianvoice.com',
);

GVCore.I.onIncoming.listen((inc) { /* update UI */ });

await GVCore.I.placeCall('sip:1002@guardianvoice.com');
```

## 5) Push payloads

**Android FCM (data):**

```json
{ "message": {
  "token":"<DEVICE_FCM_TOKEN>",
  "data": { "type":"incoming_call", "call_id":"abc123", "from_display":"Test", "from_uri":"sip:1001@domain" }
}}
```

**iOS APNs VoIP (HTTP/2, `apns-push-type: voip`):**

```json
{ "call_id":"abc123", "from_display":"Test", "from_uri":"sip:1001@domain" }
```

MD

# Dart API

cat > "$BASE/lib/gv_core.dart" <<'DART'
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
DART

# ANDROID

cat > "$BASE/android/build.gradle" <<'GRADLE'
plugins {
    id 'com.android.library'
    id 'org.jetbrains.kotlin.android'
}
android {
    namespace "com.guardianvoice.uc.core"
    compileSdk 34
    defaultConfig { minSdk 24 }
}
dependencies {
    implementation "org.linphone:linphone-sdk-android:5.3+"
    implementation 'com.google.firebase:firebase-messaging:24.0.0'
}
GRADLE

cat > "$BASE/android/src/main/AndroidManifest.xml" <<'XML'
<manifest package="com.guardianvoice.uc.core" xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <service
            android:name="com.guardianvoice.uc.core.telecom.GvConnectionService"
            android:label="Guardian Voice UC"
            android:permission="android.permission.BIND_TELECOM_CONNECTION_SERVICE">
            <intent-filter><action android:name="android.telecom.ConnectionService"/></intent-filter>
        </service>
        <service
            android:name="com.guardianvoice.uc.core.push.GvFcmService"
            android:exported="false">
            <intent-filter><action android:name="com.google.firebase.MESSAGING_EVENT"/></intent-filter>
        </service>
    </application>
</manifest>
XML

cat > "$BASE/android/src/main/kotlin/com/guardianvoice/uc/core/GvCorePlugin.kt" <<'KOT'
package com.guardianvoice.uc.core

import android.content.Context
import android.content.ComponentName
import android.telecom.PhoneAccount
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.guardianvoice.uc.core.lin.Engine
import com.guardianvoice.uc.core.telecom.TelecomBus

class GvCorePlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var ctx: Context
    private lateinit var m: MethodChannel
    private lateinit var callsEvt: EventChannel
    private var callsSink: EventChannel.EventSink? = null

    companion object {
        var methodChannel: MethodChannel? = null
        fun emitIncomingToDart(callId: String, from: String, uri: String) {
            methodChannel?.invokeMethod("nativeIncoming", mapOf("callId" to callId, "fromDisplay" to from, "fromUri" to uri))
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        ctx = binding.applicationContext
        m = MethodChannel(binding.binaryMessenger, "gv/core/methods")
        callsEvt = EventChannel(binding.binaryMessenger, "gv/core/calls")
        m.setMethodCallHandler(this)
        methodChannel = m
        callsEvt.setStreamHandler(object: EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink?) { callsSink = sink }
            override fun onCancel(args: Any?) { callsSink = null }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) { methodChannel = null }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> { Engine.init(ctx); registerPhoneAccount(); result.success(null) }
            "registerPushToken" -> { /* POST token to backend */ result.success(null) }
            "setAccount" -> {
                val a = call.arguments as Map<*,*>
                Engine.setAccount(
                    a["username"] as String, a["domain"] as String, a["password"] as String,
                    (a["tls"] as? Boolean) ?: true, (a["port"] as? Int) ?: 6061,
                    (a["srtp"] as? Boolean) ?: true, a["stun"] as? String, a["turn"] as? String
                )
                result.success(null)
            }
            "placeCall" -> { Engine.call(call.argument<String>("uri")!!); result.success(null) }
            "answer" -> { Engine.answer(); result.success(null) }
            "hangup" -> { Engine.hangup(); result.success(null) }
            "hold" -> { Engine.hold(call.argument<Boolean>("on")==true); result.success(null) }
            "mute" -> { Engine.mute(call.argument<Boolean>("on")==true); result.success(null) }
            "nativeIncoming" -> { callsSink?.success(call.arguments); result.success(null) }
            else -> result.notImplemented()
        }
    }

    private fun registerPhoneAccount() {
        val tm = ctx.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
        val handle = PhoneAccountHandle(
            ComponentName(ctx, "com.guardianvoice.uc.core.telecom.GvConnectionService"),
            "GuardianVoiceUC"
        )
        val pa = PhoneAccount.builder(handle, "Guardian Voice UC")
            .setCapabilities(PhoneAccount.CAPABILITY_CALL_PROVIDER or PhoneAccount.CAPABILITY_CONNECTION_MANAGER)
            .build()
        tm.registerPhoneAccount(pa)
    }
}
KOT

cat > "$BASE/android/src/main/kotlin/com/guardianvoice/uc/core/lin/Engine.kt" <<'KOT'
package com.guardianvoice.uc.core.lin

import android.content.Context
import org.linphone.core.*

object Engine {
    lateinit var core: Core
    private var listener: CoreListenerStub? = null
    @Volatile private var running = false

    fun init(ctx: Context) {
        if (this::core.isInitialized) return
        val f = Factory.instance()
        core = f.createCore(null, null, ctx)
        listener = object: CoreListenerStub() {
            override fun onRegistrationStateChanged(c: Core, cfg: ProxyConfig, s: RegistrationState, msg: String) {}
            override fun onCallStateChanged(c: Core, call: Call, state: Call.State?, message: String?) {}
        }
        core.addListener(listener)
        core.enableEchoCancellation(true)
        running = true
        Thread { while(running) { core.iterate(); Thread.sleep(20) } }.start()
    }

    fun setAccount(u:String, d:String, pw:String, tls:Boolean, port:Int, srtp:Boolean, stun:String?, turn:String?) {
        val f = Factory.instance()
        val id = "sip:$u@$d"
        val addr = f.createAddress(id)
        val params = core.createAccountParams()
        params.identityAddress = addr
        params.serverAddress = f.createAddress((if (tls) "sips:" else "sip:") + "$d:$port")
        params.isRegisterEnabled = true
        params.transport = if (tls) TransportType.Tls else TransportType.Tcp
        core.mediaEncryption = if (srtp) MediaEncryption.SRtp else MediaEncryption.None
        val auth = f.createAuthInfo(u, null, pw, null, null, d)
        core.addAuthInfo(auth)
        stun?.let { core.stunServer = it }
        core.defaultAccount?.let { core.removeAccount(it) }
        val acc = core.createAccount(params)
        core.addAccount(acc)
        core.defaultAccount = acc
    }

    fun call(uri:String) { core.invite(uri) }
    fun answer() { core.currentCall?.accept() }
    fun hangup() { core.currentCall?.terminate() }
    fun hold(on:Boolean) { core.currentCall?.let { if (on) it.pause() else it.resume() } }
    fun mute(on:Boolean) { core.isMicEnabled = !on }
    fun dtmf(digits:String) { digits.forEach { core.currentCall?.sendDtmf(it) } }
}
KOT

cat > "$BASE/android/src/main/kotlin/com/guardianvoice/uc/core/telecom/TelecomBus.kt" <<'KOT'
package com.guardianvoice.uc.core.telecom

import android.telecom.Connection
import java.util.concurrent.ConcurrentHashMap

object TelecomBus {
    private val calls = ConcurrentHashMap<String, Connection>()
    fun put(id: String, c: Connection) { calls[id]=c }
    fun remove(id: String) { calls.remove(id) }
    fun answer(id: String) { calls[id]?.onAnswer() }
    fun hangup(id: String) { calls[id]?.onDisconnect() }
}
KOT

cat > "$BASE/android/src/main/kotlin/com/guardianvoice/uc/core/telecom/GvConnectionService.kt" <<'KOT'
package com.guardianvoice.uc.core.telecom

import android.telecom.*
import com.guardianvoice.uc.core.lin.Engine

class GvConnectionService: ConnectionService() {
    override fun onCreateIncomingConnection(cm: PhoneAccountHandle, req: ConnectionRequest): Connection {
        val callId = req.extras.getString("gv_call_id") ?: System.currentTimeMillis().toString()
        val conn = object: Connection() {
            init {
                TelecomBus.put(callId, this)
                connectionProperties = PROPERTY_SELF_MANAGED
                address = req.address
                setCallerDisplayName(req.extras.getString("gv_from_display") ?: "Unknown", TelecomManager.PRESENTATION_ALLOWED)
                setInitializing(); setRinging()
            }
            override fun onAnswer() { setActive(); Engine.answer() }
            override fun onDisconnect() { Engine.hangup(); setDisconnected(DisconnectCause(DisconnectCause.LOCAL)); destroy(); TelecomBus.remove(callId) }
            override fun onPlayDtmfTone(c: Char) { Engine.dtmf("$c") }
            override fun onStopDtmfTone() {}
        }
        return conn
    }
}
KOT

cat > "$BASE/android/src/main/kotlin/com/guardianvoice/uc/core/push/GvFcmService.kt" <<'KOT'
package com.guardianvoice.uc.core.push

import android.content.ComponentName
import android.content.Context
import android.os.Bundle
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import android.net.Uri
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.guardianvoice.uc.core.lin.Engine

class GvFcmService: FirebaseMessagingService() {
    override fun onMessageReceived(msg: RemoteMessage) {
        val d = msg.data
        if (d["type"] == "incoming_call") {
            val callId = d["call_id"] ?: System.currentTimeMillis().toString()
            val fromDisp = d["from_display"] ?: "Unknown"
            val fromUri = d["from_uri"] ?: "sip:unknown@guardianvoice.com"
            Engine.init(applicationContext)
            Engine.core.refreshRegisters()
            presentIncomingCall(this, callId, fromDisp, fromUri)
        }
    }
    override fun onNewToken(token: String) {
        // Forward token to backend via Flutter if needed
    }
    private fun presentIncomingCall(ctx: Context, callId: String, fromDisp: String, fromUri: String) {
        val tm = ctx.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
        val extras = Bundle().apply {
            putString("gv_call_id", callId)
            putString("gv_from_display", fromDisp)
            putParcelable(TelecomManager.EXTRA_INCOMING_CALL_ADDRESS, Uri.parse("tel:$fromDisp"))
        }
        val handle = PhoneAccountHandle(ComponentName(ctx, "com.guardianvoice.uc.core.telecom.GvConnectionService"), "GuardianVoiceUC")
        tm.addNewIncomingCall(handle, extras)
    }
}
KOT

# iOS

cat > "$BASE/ios/gv_core.podspec" <<'POD'
Pod::Spec.new do |s|
  s.name         = 'gv_core'
  s.version      = '0.1.0'
  s.summary      = 'Guardian Voice UC native glue'
  s.source       = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'linphone-sdk', '~> 5.3'
  s.ios.deployment_target = '13.0'
end
POD

cat > "$BASE/ios/Classes/LinEngine.swift" <<'SWIFT'
import Foundation
import linphonesw

class LinEngine {
    static let shared = LinEngine()
    var core: Core?

    func initCore() {
        if core != nil { return }
        do {
            core = try Factory.Instance.createCore(configPath: nil, factoryConfigPath: nil, systemContext: nil)
            try core?.start()
            core?.enableEchoCancellation = true
        } catch { print("Lin init error: \(error)") }
    }

    func setAccount(username: String, domain: String, password: String, tls: Bool, port: Int32, srtp: Bool, stun: String?) {
        guard let core = core else { return }
        do {
            let id = try Factory.Instance.createAddress(addr: "sip:\(username)@\(domain)")
            let params = try core.createAccountParams()
            try params.setIdentityAddress(newValue: id)
            let server = try Factory.Instance.createAddress(addr: "\(tls ? "sips" : "sip"):\(domain):\(port)")
            try params.setServerAddress(newValue: server)
            try params.setRegisterEnabled(newValue: true)
            try params.setTransport(transport: tls ? .Tls : .Tcp)
            core.mediaEncryption = srtp ? .SRTP : .None
            let auth = try Factory.Instance.createAuthInfo(username: username, userid: nil, passwd: password, ha1: nil, realm: nil, domain: domain)
            core.addAuthInfo(info: auth)
            if let stun = stun { core.stunServer = stun }
            if let cur = core.defaultAccount { core.removeAccount(account: cur) }
            let acc = try core.createAccount(params: params)
            try core.addAccount(account: acc)
            core.defaultAccount = acc
        } catch { print("setAccount error: \(error)") }
    }

    func call(uri: String){ do { let a = try Factory.Instance.createAddress(addr: uri); _ = core?.inviteAddress(addr: a) } catch { print(error) } }
    func answer(){ core?.currentCall?.accept() }
    func hangup(){ core?.currentCall?.terminate() }
    func hold(_ on: Bool){ if on { core?.currentCall?.pause() } else { core?.currentCall?.resume() } }
    func mute(_ on: Bool){ core?.micEnabled = !on }
    func dtmf(_ digits: String){ digits.forEach{ core?.currentCall?.sendDtmf(dtmf: $0) } }
}
SWIFT

cat > "$BASE/ios/Classes/GvAudio.swift" <<'SWIFT'
import AVFoundation
import UIKit

class GvAudio {
    static func startCall() {
        let s = AVAudioSession.sharedInstance()
        try? s.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth,.duckOthers])
        try? s.setActive(true)
        UIDevice.current.isProximityMonitoringEnabled = true
    }
    static func endCall() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        UIDevice.current.isProximityMonitoringEnabled = false
    }
    static func speaker(_ on: Bool) {
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(on ? .speaker : .none)
    }
}
SWIFT

cat > "$BASE/ios/Classes/GvCorePlugin.swift" <<'SWIFT'
import Flutter
import UIKit
import PushKit
import CallKit

public class GvCorePlugin: NSObject, FlutterPlugin, PKPushRegistryDelegate, CXProviderDelegate, FlutterStreamHandler {
    var method: FlutterMethodChannel!
    var calls: FlutterEventChannel!
    var callsSink: FlutterEventSink?

    let provider: CXProvider = {
        let cfg = CXProviderConfiguration(localizedName: "Guardian Voice UC")
        cfg.includesCallsInRecents = true
        cfg.supportsVideo = true
        return CXProvider(configuration: cfg)
    }()
    let callController = CXCallController()

    override init() { super.init(); provider.setDelegate(self, queue: nil) }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let i = GvCorePlugin()
        i.method = FlutterMethodChannel(name: "gv/core/methods", binaryMessenger: registrar.messenger()); registrar.addMethodCallDelegate(i, channel: i.method)
        i.calls = FlutterEventChannel(name: "gv/core/calls", binaryMessenger: registrar.messenger()); i.calls.setStreamHandler(i)

        let pk = PKPushRegistry(queue: DispatchQueue.main)
        pk.desiredPushTypes = [.voIP]; pk.delegate = i
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? { callsSink = events; return nil }
    public func onCancel(withArguments arguments: Any?) -> FlutterError? { callsSink = nil; return nil }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize": LinEngine.shared.initCore(); result(nil)
        case "registerPushToken": result(nil)
        case "setAccount":
            if let a = call.arguments as? [String:Any] {
                LinEngine.shared.setAccount(
                    username: a["username"] as! String,
                    domain: a["domain"] as! String,
                    password: a["password"] as! String,
                    tls: (a["tls"] as? Bool) ?? true,
                    port: Int32((a["port"] as? Int) ?? 6061),
                    srtp: (a["srtp"] as? Bool) ?? true,
                    stun: a["stun"] as? String
                )
            }; result(nil)
        case "placeCall": LinEngine.shared.call(uri: (call.arguments as! [String:Any])["uri"] as! String); result(nil)
        case "answer": LinEngine.shared.answer(); result(nil)
        case "hangup": LinEngine.shared.hangup(); result(nil)
        case "hold": LinEngine.shared.hold(((call.arguments as! [String:Any])["on"] as? Bool) ?? false); result(nil)
        case "mute": LinEngine.shared.mute(((call.arguments as! [String:Any])["on"] as? Bool) ?? false); result(nil)
        default: result(FlutterMethodNotImplemented)
        }
    }

    public func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        // TODO: send token to backend
    }

    public func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        LinEngine.shared.initCore()
        LinEngine.shared.core?.refreshRegisters()
        let d = payload.dictionaryPayload
        let callId = (d["call_id"] as? String) ?? UUID().uuidString
        let fromDisp = (d["from_display"] as? String) ?? "Unknown"
        let fromUri = (d["from_uri"] as? String) ?? "sip:unknown@guardianvoice.com"
        presentIncoming(callId: callId, fromDisplay: fromDisp, fromUri: fromUri)
        callsSink?(["callId":callId, "fromDisplay":fromDisp, "fromUri":fromUri])
        completion()
    }

    private func presentIncoming(callId: String, fromDisplay: String, fromUri: String) {
        let uuid = UUID(uuidString: callId) ?? UUID()
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: fromDisplay)
        provider.reportNewIncomingCall(with: uuid, update: update) { err in if let e = err { print("CallKit error: \(e)") } }
    }

    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) { GvAudio.startCall(); LinEngine.shared.answer(); action.fulfill() }
    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) { LinEngine.shared.hangup(); GvAudio.endCall(); action.fulfill() }
}
SWIFT

echo "gv_core created."