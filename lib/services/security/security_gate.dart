import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:usdc_wallet/services/security/device_security.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Security Gate Widget
/// SECURITY: Blocks app usage on compromised devices
/// Wrap your app's root widget with this to enforce device security
class SecurityGate extends StatefulWidget {
  final Widget child;
  final CompromisedDevicePolicy policy;
  final Widget? blockedScreen;
  final Widget? loadingWidget;

  const SecurityGate({
    super.key,
    required this.child,
    this.policy = CompromisedDevicePolicy.block,
    this.blockedScreen,
    this.loadingWidget,
  });

  @override
  State<SecurityGate> createState() => _SecurityGateState();
}

class _SecurityGateState extends State<SecurityGate> {
  bool _isLoading = true;
  bool _isSecure = true;
  DeviceSecurityResult? _result;

  @override
  void initState() {
    super.initState();
    _checkSecurity();
  }

  Future<void> _checkSecurity() async {
    final security = DeviceSecurity();
    final result = await security.checkSecurity();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSecure = result.isSecure;
        _result = result;
      });

      // Log security events (would send to analytics in production)
      if (!result.isSecure) {
        AppLogger('Debug').debug('SECURITY ALERT: Device compromised - ${result.threats}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: const Color(0xFF111115),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF00D4AA),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Verifying device security...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
    }

    if (!_isSecure && widget.policy == CompromisedDevicePolicy.block) {
      return widget.blockedScreen ?? _buildDefaultBlockedScreen();
    }

    // For warn policy, show a dialog and continue
    if (!_isSecure && widget.policy == CompromisedDevicePolicy.warn) {
      // The warning would be shown once on first load
      // For now, just continue with the app
    }

    return widget.child;
  }

  Widget _buildDefaultBlockedScreen() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF111115),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Security Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Korido cannot run on this device because security issues have been detected.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detected issues:',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_result?.threats ?? []).map((threat) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    threat,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'For your financial security, this app requires an unmodified device.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'If you believe this is an error, please contact support.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
