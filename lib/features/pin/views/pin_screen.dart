import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/composed/pin_pad.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/services/session/session_service.dart';

/// Where the PIN screen was opened from — determines what happens on success.
enum PinContext {
  /// Login flow: unlock app → go to /home
  login,
  /// Session lock: app was locked → return to previous screen
  sessionLock,
  /// Confirm action: verify before transfer/settings → pop with result
  confirmAction,
}

/// Single unified PIN screen. Knows its context and navigates accordingly.
class PinScreen extends ConsumerStatefulWidget {
  final PinContext pinContext;
  final String? title;
  final String? subtitle;
  final String? successRoute;

  const PinScreen({
    super.key,
    required this.pinContext,
    this.title,
    this.subtitle,
    this.successRoute,
  });

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _pin = '';
  bool _hasError = false;
  String? _errorMessage;
  int _remainingAttempts = PinService.maxAttempts;
  bool _isLocked = false;
  int _lockSeconds = 0;
  bool _biometricAvailable = false;
  bool _isVerifying = false;
  bool _showUnlockTransition = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    // Only offer biometric if PIN is confirmed (set) on device
    final pinService = ref.read(pinServiceProvider);
    final hasPin = await pinService.hasPin();
    if (!hasPin) {
      if (mounted) setState(() => _biometricAvailable = false);
      return;
    }

    final bio = ref.read(biometricServiceProvider);
    final available = await bio.isAvailable();
    final enabled = await bio.isBiometricEnabled();
    if (mounted) setState(() => _biometricAvailable = available && enabled);
  }

  /// What happens after successful verification — depends on context.
  void _onSuccess() {
    switch (widget.pinContext) {
      case PinContext.login:
        // Unlock auth + session, show brief transition, navigate to home
        try { ref.read(authProvider.notifier).unlock(); } catch (_) {}
        try { ref.read(sessionServiceProvider.notifier).unlockSession(); } catch (_) {}
        if (mounted) _transitionThen(() => context.go(widget.successRoute ?? '/home'));

      case PinContext.sessionLock:
        // Unlock session, show brief transition, return to previous screen
        try { ref.read(authProvider.notifier).unlock(); } catch (_) {}
        try { ref.read(sessionServiceProvider.notifier).unlockSession(); } catch (_) {}
        if (mounted) {
          _transitionThen(() {
            if (widget.successRoute != null) {
              context.go(widget.successRoute!);
            } else {
              context.pop(true);
            }
          });
        }

      case PinContext.confirmAction:
        // Just pop with true — caller decides what to do
        if (mounted) context.pop(true);
    }
  }

  /// Brief unlock animation before navigating away
  void _transitionThen(VoidCallback navigate) {
    setState(() => _showUnlockTransition = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) navigate();
    });
  }

  Future<void> _verifyPin() async {
    if (_isVerifying) return;
    setState(() { _isVerifying = true; _errorMessage = null; });

    final pinService = ref.read(pinServiceProvider);
    final result = await pinService.verifyPinLocally(_pin);

    if (!mounted) return;

    if (result.success) {
      _onSuccess();
    } else {
      setState(() {
        _isVerifying = false;
        _hasError = true;
        _remainingAttempts = result.remainingAttempts ?? _remainingAttempts;
        _isLocked = result.isLocked;
        _lockSeconds = result.lockRemainingSeconds ?? 0;
        _errorMessage = result.message;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() { _pin = ''; _hasError = false; });
      });
    }
  }

  Future<void> _handleBiometric() async {
    final bio = ref.read(biometricServiceProvider);
    final result = await bio.authenticate(
      localizedReason: AppLocalizations.of(context)!.biometric_reason,
    );
    if (result.success && mounted) _onSuccess();
  }

  String get _title {
    if (widget.title != null) return widget.title!;
    final l10n = AppLocalizations.of(context)!;
    switch (widget.pinContext) {
      case PinContext.login: return l10n.login_enterPin;
      case PinContext.sessionLock: return l10n.login_enterPin;
      case PinContext.confirmAction: return l10n.login_enterPin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    if (_isLocked) return _buildLockedView(l10n, colors);

    // Unlock transition overlay
    if (_showUnlockTransition) {
      return Scaffold(
        backgroundColor: colors.canvas,
        body: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_open_rounded, size: 48, color: colors.gold),
                    const SizedBox(height: 16),
                    AppText(
                      'Déverrouillé',
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(_title, variant: AppTextVariant.headlineSmall, color: colors.textPrimary),
        backgroundColor: Colors.transparent, elevation: 0,
        // Only show back button for confirmAction context
        automaticallyImplyLeading: widget.pinContext == PinContext.confirmAction,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 1),
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: colors.container, shape: BoxShape.circle,
                          border: Border.all(color: colors.border),
                        ),
                        child: Icon(Icons.lock_outline, color: colors.gold, size: 40),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      if (widget.subtitle != null) ...[
                        AppText(widget.subtitle!, variant: AppTextVariant.bodyMedium,
                          color: colors.textSecondary, textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.xxxl),
                      ] else ...[
                        AppText(l10n.login_pinSubtitle, variant: AppTextVariant.bodyMedium,
                          color: colors.textSecondary, textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.xxxl),
                      ],

                      PinDots(length: 6, filled: _pin.length, error: _hasError),
                      const SizedBox(height: AppSpacing.md),

                      if (_remainingAttempts < PinService.maxAttempts)
                        AppText(l10n.login_attemptsRemaining(_remainingAttempts),
                          variant: AppTextVariant.bodyMedium, color: colors.warningText),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppText(_errorMessage!, variant: AppTextVariant.bodySmall,
                          color: colors.errorText, textAlign: TextAlign.center),
                      ],

                      const Spacer(flex: 1),

                      PinPad(
                        onDigitPressed: (digit) {
                          if (_pin.length >= 6) return;
                          setState(() { _pin += digit.toString(); _hasError = false; _errorMessage = null; });
                          if (_pin.length == 6) _verifyPin();
                        },
                        onDeletePressed: () {
                          if (_pin.isNotEmpty) {
                            setState(() { _pin = _pin.substring(0, _pin.length - 1); _hasError = false; });
                          }
                        },
                        showBiometric: _biometricAvailable,
                        onBiometricPressed: _biometricAvailable ? _handleBiometric : null,
                      ),

                      const SizedBox(height: AppSpacing.xxl),
                      TextButton(
                        onPressed: () => context.push('/pin/reset'),
                        child: AppText(l10n.login_forgotPin, variant: AppTextVariant.bodyMedium, color: colors.gold),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockedView(AppLocalizations l10n, ThemeColors colors) {
    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: colors.container, shape: BoxShape.circle, border: Border.all(color: colors.border)),
                  child: Icon(Icons.lock_clock, color: colors.error, size: 40),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppText(l10n.login_accountLocked, variant: AppTextVariant.headlineMedium, color: colors.textPrimary, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                AppText('${l10n.login_lockedMessage}\n${_lockSeconds > 0 ? '${(_lockSeconds / 60).ceil()} min' : ''}',
                  variant: AppTextVariant.bodyLarge, color: colors.textSecondary, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(label: l10n.common_ok, onPressed: () => context.go('/login'), variant: AppButtonVariant.primary, isFullWidth: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
