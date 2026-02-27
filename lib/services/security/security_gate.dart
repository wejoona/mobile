import 'package:flutter/material.dart';
import 'package:safe_device/safe_device.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
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

    // Also check via safe_device for a second opinion
    bool jailbreakDetected = false;
    try {
      jailbreakDetected = await SafeDevice.isJailBroken;
    } catch (e) {
      AppLogger('Debug').debug('safe_device jailbreak check failed: $e');
    }

    final combinedSecure = result.isSecure && !jailbreakDetected;
    final combinedResult = DeviceSecurityResult(
      isSecure: combinedSecure,
      threats: [
        ...result.threats,
        if (jailbreakDetected) 'Root/jailbreak detected (safe_device)',
      ],
      message: combinedSecure
          ? result.message
          : 'Device compromised: ${result.threats.join(', ')}${jailbreakDetected ? ', jailbreak detected' : ''}',
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSecure = combinedSecure;
        _result = combinedResult;
      });

      if (!combinedSecure) {
        AppLogger('Debug').debug('SECURITY ALERT: Device compromised - ${combinedResult.threats}');
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
              backgroundColor: AppColors.graphite,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF00D4AA),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Verifying device security...',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
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
        backgroundColor: AppColors.graphite,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.errorBase.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: AppColors.errorBase,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  'Security Alert',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Korido cannot run on this device because security issues have been detected.',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.errorBase.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: AppColors.errorBase.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detected issues:',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.errorBase,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...(_result?.threats ?? []).map((threat) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.errorBase,
                                  size: 16,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    threat,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  'For your financial security, this app requires an unmodified device.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'If you believe this is an error, please contact support.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.5),
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
