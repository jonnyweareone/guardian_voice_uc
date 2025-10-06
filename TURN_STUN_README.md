# Guardian Voice UC - Mobile App with TURN/STUN Configuration

## 🚀 Quick Start

```bash
# Navigate to project
cd /Users/davidsmith/Documents/GitHub/guardian_voice_uc

# Clean and get dependencies
flutter clean
flutter pub get

# Build
./build.sh
```

## 📦 Project Structure

```
guardian_voice_uc/
├── android/               # Android native code
├── ios/                   # iOS native code
├── lib/                   # Flutter/Dart code
├── plugins/
│   └── gv_core/          # Linphone SDK integration
├── env.json              # TURN/STUN configuration
├── build.sh              # Build script
└── scripts/
    └── update_turn_password.sh  # TURN password updater
```

## 🔧 TURN/STUN Configuration

The app is configured to use TURN/STUN servers for NAT traversal. Configuration is in `env.json`:

```json
{
    "SIP_DOMAIN": "uc.guardianvoice.com",
    "SIP_PROXY": "sips://sbc.guardianvoice.com:5061",
    "STUN_SERVER": "stun:turn.guardianvoice.com:3478",
    "TURN_URL": "turn:turn.guardianvoice.com:3478",
    "TURN_USERNAME": "guardian",
    "TURN_PASSWORD": "WILL_BE_GENERATED_FROM_SERVER",
    "ICE_ENABLED": true,
    "SRTP_MODE": "required"
}
```

### Getting TURN Password

After server provisioning:

```bash
# Fetch TURN password from server
./scripts/update_turn_password.sh --fetch

# Or manually via SSH
ssh ubuntu@turn.guardianvoice.com
sudo grep -m1 '^user=guardian:' /etc/turnserver.conf | cut -d: -f2
```

## 🏗️ Build Instructions

### Prerequisites

1. **Flutter SDK**: Install from https://flutter.dev
2. **Xcode** (for iOS): Install from App Store
3. **Android Studio** (for Android): Install from https://developer.android.com

### Android Build

```bash
# Debug build
flutter build apk --debug

# Release build (requires signing)
flutter build apk --release

# Install on device
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### iOS Build

```bash
# Debug build
flutter build ios --debug --no-codesign

# Open in Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select your team for signing
# 2. Choose your device
# 3. Press Run
```

## 🔑 Key Features

- **ICE/STUN/TURN Support**: Full NAT traversal capability
- **Secure Media**: SRTP encryption mandatory
- **TLS Signaling**: Secure SIP over TLS (port 5061)
- **Push Notifications**: Firebase Cloud Messaging
- **Linphone SDK**: Version 5.3.50 for stability

## 📱 Testing VoIP Functionality

1. **Register SIP Account**:
   - Username: Your SIP username
   - Password: Your SIP password
   - Domain: uc.guardianvoice.com

2. **Test TURN Connectivity**:
   - Make a call while behind NAT
   - Check call statistics for "relay" candidate type
   - Verify audio works in both directions

3. **Monitor ICE Gathering**:
   - Watch logs for ICE candidate types
   - Should see: host, srflx (STUN), relay (TURN)

## 🐛 Troubleshooting

### Build Failures

1. **Plugin not found**:
   ```bash
   # Verify plugin structure
   ls -la plugins/gv_core/
   # Should see: pubspec.yaml, lib/, android/, ios/
   ```

2. **Dependency resolution**:
   ```bash
   flutter clean
   flutter pub cache clean
   flutter pub get
   ```

3. **Android build issues**:
   - Check Kotlin version: Should be 1.9.20
   - Check Gradle version: Should be 8.1.0
   - Verify google-services.json exists

### VoIP Issues

1. **No audio**:
   - Check TURN credentials are correct
   - Verify firewall allows UDP 3478, 10000-20000
   - Test TURN server connectivity

2. **Registration fails**:
   - Verify SIP credentials
   - Check TLS certificate trust
   - Confirm port 5061 is open

3. **One-way audio**:
   - Usually indicates NAT issues
   - Ensure TURN is enabled and working
   - Check symmetric RTP settings

## 🔒 Security Notes

- Always use TLS for SIP signaling
- Keep TURN credentials secure
- Rotate credentials regularly
- Monitor TURN usage for abuse

## 📊 Network Requirements

Open these ports:
- **3478 UDP/TCP**: STUN/TURN
- **5349 TCP**: TURNS (TLS)
- **5061 TCP**: SIP over TLS
- **10000-20000 UDP**: RTP media

## 🚦 Status Checks

```bash
# Check Flutter status
flutter doctor

# Verify plugin
ls plugins/gv_core/pubspec.yaml

# Check dependencies
flutter pub deps

# Run tests
flutter test
```

## 📝 Environment Variables

Key settings in `env.json`:

| Variable | Description | Example |
|----------|-------------|---------|
| SIP_DOMAIN | SIP domain | uc.guardianvoice.com |
| SIP_PROXY | Outbound proxy | sips://sbc.guardianvoice.com:5061 |
| TURN_URL | TURN server | turn:turn.guardianvoice.com:3478 |
| TURN_USERNAME | TURN username | guardian |
| TURN_PASSWORD | TURN password | (fetch from server) |
| ICE_ENABLED | Enable ICE | true |
| SRTP_MODE | Media encryption | required |

## 🎯 Next Steps

1. ✅ Verify project builds successfully
2. ✅ Update TURN password from server
3. ✅ Test on real device behind NAT
4. ✅ Verify TURN relay works
5. ✅ Configure production signing

## 📚 Documentation

- [Linphone SDK](https://wiki.linphone.org)
- [CoTURN](https://github.com/coturn/coturn)
- [Flutter](https://flutter.dev/docs)
- [ICE/STUN/TURN](https://webrtc.org/getting-started/turn-server)

## 🆘 Support

For issues:
1. Check logs: `flutter logs`
2. Verify TURN: `turnutils_uclient -u guardian -w <password> turn.guardianvoice.com`
3. Test with Linphone desktop app first
