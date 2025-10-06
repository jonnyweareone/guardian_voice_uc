# Integration guide — gv_core

## 1) Add dependency (in your Flutter app pubspec.yaml)
```yaml
dependencies:
  gv_core:
    path: ./plugins/gv_core
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