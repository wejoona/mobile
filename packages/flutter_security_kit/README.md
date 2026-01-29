# Flutter Security Kit

Security utilities for Flutter applications including device security checks, device attestation, and screenshot protection.

## Features

- **Device Security** - Detect rooted/jailbroken devices, debuggers, emulators
- **Device Attestation** - Verify device integrity using Play Integrity (Android) and App Attest (iOS)
- **Screenshot Protection** - Prevent screenshots and screen recording on sensitive screens
- **Configurable Policies** - Block, warn, or monitor compromised devices

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_security_kit:
    path: packages/flutter_security_kit
```

Or if published:

```yaml
dependencies:
  flutter_security_kit: ^1.0.0
```

## Quick Start

```dart
import 'package:flutter_security_kit/flutter_security_kit.dart';

// Check device security
final security = DeviceSecurity();
final result = await security.checkSecurity();
if (!result.isSecure) {
  print('Threats detected: ${result.threats}');
}

// Device attestation
final attestation = DeviceAttestation();
final attestResult = await attestation.attestDevice();
if (attestResult.isValid) {
  // Send token to backend for verification
  await api.verifyAttestation(attestResult.token!);
}

// Screenshot protection
await ScreenshotProtection().enable();
```

## Device Security

Detects security threats on the device including:
- Rooted Android devices (su binary, Magisk, SuperSU)
- Jailbroken iOS devices (Cydia, Sileo, sandbox escape)
- Attached debuggers
- Emulators/simulators
- Hooking frameworks (Frida, Cycript)

### Basic Usage

```dart
final security = DeviceSecurity();

// Full security check
final result = await security.checkSecurity();
if (result.isSecure) {
  print('Device is secure');
} else {
  print('Threats: ${result.threats}');
}

// Quick check using cached result
if (security.isCompromised) {
  showSecurityWarning();
}
```

### Policy Enforcement

```dart
final canProceed = await security.enforcePolicy(
  policy: CompromisedDevicePolicy.block,
  onCompromised: (result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Security Issue Detected'),
        content: Text(result.message),
      ),
    );
  },
);

if (!canProceed) {
  return; // Don't allow app to continue
}
```

### Threat Information

```dart
final result = await security.checkSecurity();

// Check for critical threats
if (result.hasCriticalThreats) {
  // Block financial operations
}

// Get threats by severity
final criticalThreats = result.threatsBySeverity(ThreatSeverity.critical);
final highThreats = result.threatsBySeverity(ThreatSeverity.high);

// Iterate threats
for (final threat in result.threats) {
  print('${threat.id}: ${threat.description} [${threat.severity}]');
}
```

### Configuration

```dart
// Skip checks in debug mode (default: true)
SecurityConfig.skipInDebugMode = true;

// Set default policy
SecurityConfig.defaultPolicy = CompromisedDevicePolicy.block;

// Allow emulators in development
SecurityConfig.allowEmulator = true;

// Custom threat handler for analytics
SecurityConfig.onThreatsDetected = (threats) {
  analytics.logSecurityEvent('threats_detected', {'threats': threats});
};
```

## Device Attestation

Verifies the app is running on a genuine, unmodified device using platform-specific APIs.

### Android: Play Integrity API

Returns an integrity token that can be verified on your backend:

```dart
final attestation = DeviceAttestation();
final result = await attestation.attestDevice(
  nonce: serverGeneratedNonce, // For replay protection
);

if (result.isValid) {
  // Send token to backend
  await api.verifyIntegrity(result.token!);

  // Check verdict
  print('Verdict: ${result.verdict?.name}'); // strong, basic, weak, failed
}
```

### iOS: App Attest

```dart
final result = await attestation.attestDevice();
if (result.isValid) {
  // Attestation object for backend verification
  final keyId = result.metadata?['keyId'];
  await api.verifyAppAttest(result.token!, keyId);
}
```

### Operation Guards

```dart
// Verify before sensitive operation
final canProceed = await attestation.verifyForOperation(
  policy: AttestationPolicy.required,
  serverNonce: await api.getAttestationNonce(),
);

if (!canProceed) {
  showError('Device verification failed');
  return;
}

// Proceed with sensitive operation
await api.transferFunds(amount);
```

### Native Setup Required

Device attestation requires native platform code. Add to your Android/iOS projects:

**Android (MainActivity.kt):**
```kotlin
class MainActivity : FlutterActivity() {
    private val CHANNEL = "flutter_security_kit/attestation"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestIntegrityToken" -> requestIntegrityToken(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun requestIntegrityToken(call: MethodCall, result: MethodChannel.Result) {
        val nonce = call.argument<String>("nonce")
        // Implement Play Integrity API call
        // Return token and verdict
    }
}
```

**iOS (AppDelegate.swift):**
```swift
@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "flutter_security_kit/attestation",
            binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "requestAppAttest":
                self.requestAppAttest(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func requestAppAttest(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Implement App Attest call
    }
}
```

## Screenshot Protection

Prevents screenshots and screen recording on sensitive screens.

### Basic Usage

```dart
// Enable protection
await ScreenshotProtection().enable();

// Do sensitive operations...

// Disable protection
await ScreenshotProtection().disable();
```

### Widget Lifecycle

```dart
class _TransferScreenState extends State<TransferScreen> {
  @override
  void initState() {
    super.initState();
    ScreenshotProtection().enable();
  }

  @override
  void dispose() {
    ScreenshotProtection().disable();
    super.dispose();
  }
}
```

### Using Mixin

```dart
class _PinEntryScreenState extends State<PinEntryScreen>
    with ScreenshotProtectedState {

  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
}
```

### Widget Wrapper

```dart
ScreenshotProtectedWidget(
  child: SensitiveContent(),
)
```

### Route-Based Protection

```dart
MaterialApp(
  navigatorObservers: [
    ScreenshotProtectionRouteObserver(
      protectedRoutes: [
        '/pin',
        '/transfer',
        '/settings/security',
        '/wallet/*',  // Wildcard: all wallet routes
      ],
    ),
  ],
)
```

### Native Setup Required

Screenshot protection requires native platform code:

**Android (MainActivity.kt):**
```kotlin
class MainActivity : FlutterActivity() {
    private val CHANNEL = "flutter_security_kit/screenshot_protection"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableSecureFlag" -> {
                        window.setFlags(
                            WindowManager.LayoutParams.FLAG_SECURE,
                            WindowManager.LayoutParams.FLAG_SECURE
                        )
                        result.success(true)
                    }
                    "disableSecureFlag" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
```

**iOS (AppDelegate.swift):**
```swift
// iOS uses a hidden overlay technique
private func enableScreenProtection() {
    // Add a secure text field that triggers iOS protection
    let field = UITextField()
    field.isSecureTextEntry = true
    field.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    window?.addSubview(field)
}
```

## Configuration Reference

### SecurityConfig

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `skipInDebugMode` | `bool` | `true` | Skip checks in debug builds |
| `defaultPolicy` | `CompromisedDevicePolicy` | `block` | Default policy for compromised devices |
| `allowEmulator` | `bool` | `kDebugMode` | Allow emulators/simulators |
| `allowDebugger` | `bool` | `kDebugMode` | Allow attached debuggers |
| `attestationValidityDuration` | `Duration` | 1 hour | How long to cache attestation |
| `enableLogging` | `bool` | `kDebugMode` | Log security events |
| `onThreatsDetected` | `Function?` | `null` | Callback for detected threats |

### Policies

**CompromisedDevicePolicy:**
- `block` - Prevent app usage
- `warn` - Show warning but allow usage
- `monitor` - Log only, no user impact

**AttestationPolicy:**
- `required` - Must pass attestation
- `preferred` - Warn on failure
- `none` - Skip attestation

### Threat Severities

- `critical` - Immediate security risk (root, jailbreak)
- `high` - Significant risk (debugger, hooking)
- `medium` - Potential risk (emulator)
- `low` - Informational

## Best Practices

### 1. Defense in Depth

```dart
// Check multiple layers
Future<bool> isDeviceSecure() async {
  final security = await DeviceSecurity().checkSecurity();
  if (!security.isSecure) return false;

  final attestation = await DeviceAttestation().attestDevice();
  if (!attestation.isValid) return false;

  return true;
}
```

### 2. Gradual Rollout

```dart
// Start with monitoring, then enforce
SecurityConfig.defaultPolicy = isNewUser
    ? CompromisedDevicePolicy.block    // Strict for new users
    : CompromisedDevicePolicy.monitor; // Monitor existing users
```

### 3. Backend Verification

```dart
// Always verify attestation on backend
final result = await attestation.attestDevice(
  nonce: await api.getAttestationNonce(), // Server-generated nonce
);

if (result.isValid) {
  // Backend verifies the token
  final verified = await api.verifyAttestation(result.token!);
  if (!verified) {
    // Token verification failed on backend
    showError('Device verification failed');
  }
}
```

### 4. Analytics Integration

```dart
SecurityConfig.onThreatsDetected = (threats) {
  analytics.logEvent('security_threats', {
    'threats': threats,
    'timestamp': DateTime.now().toIso8601String(),
  });
};
```

## License

MIT License - see LICENSE file for details.
