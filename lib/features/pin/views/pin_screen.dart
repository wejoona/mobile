import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/composed/pin_pad.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/auth/providers/login_provider.dart';
import 'package:usdc_wallet/features/auth/widgets/auth_screen_chrome.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/services/session/session_service.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/state/transaction_state_machine.dart';
import 'package:usdc_wallet/state/fsm/index.dart' hide AuthState, SessionState;

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

class _PinScreenState extends ConsumerState<PinScreen>
    with WidgetsBindingObserver {
  String _pin = '';
  bool _hasError = false;
  String? _errorMessage;
  int _remainingAttempts = PinService.maxAttempts;
  bool _isLocked = false;
  int _lockSeconds = 0;
  bool _biometricEnabled = false;
  BiometricType _biometricType = BiometricType.none;
  bool _isVerifying = false;
  bool _showUnlockTransition = false;
  bool _hasCompletedSuccess = false;
  bool _queuedUnlockedRedirect = false;
  int _biometricAttempt = 0;
  ProviderSubscription<AuthState>? _authSubscription;
  ProviderSubscription<SessionState>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authSubscription = ref.listenManual<AuthState>(
      authProvider,
      (_, _) => _dismissIfAlreadyUnlocked(),
    );
    _sessionSubscription = ref.listenManual<SessionState>(
      sessionServiceProvider,
      (_, _) => _dismissIfAlreadyUnlocked(),
    );
    unawaited(_checkBiometric());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dismissIfAlreadyUnlocked();
      }
    });
  }

  @override
  void dispose() {
    _biometricAttempt++;
    _authSubscription?.close();
    _sessionSubscription?.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Returning from the OS biometric sheet or a device unlock can change
    // biometric availability. Re-check on resume so the unlock button
    // reappears without forcing the user to close and reopen the app.
    if (state == AppLifecycleState.resumed && !_showUnlockTransition) {
      unawaited(_checkBiometric());
      _recoverInterruptedBiometric();
    }
  }

  Future<void> _checkBiometric() async {
    // Only offer biometric if PIN is confirmed (set) on device
    final pinService = ref.read(pinServiceProvider);
    final hasPin = await pinService.hasPin();
    if (!hasPin) {
      if (mounted) {
        setState(() {
          _biometricEnabled = false;
        });
      }
      return;
    }

    final bio = ref.read(biometricServiceProvider);
    final userId = await _currentBiometricUserId();
    final enabled =
        userId != null && await bio.isBiometricEnabled(userId: userId);
    final available = await bio.isAvailable();
    final type = await bio.getAvailableType();
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
        _biometricType = available ? type : BiometricType.none;
      });
    }
  }

  /// What happens after successful verification — depends on context.
  ///
  /// IMPORTANT: the unlock state mutations (which flip the FSM/auth state and
  /// trigger a router refresh) are deferred until *after* the transition,
  /// alongside the navigation call. Doing them up-front rebuilds the
  /// `/session-locked` page mid-animation, disposing this State and dropping
  /// the pending navigation — leaving the unlock overlay stuck on screen.
  void _onSuccess() {
    switch (widget.pinContext) {
      case PinContext.login:
        // Show brief transition, then unlock + navigate to home together.
        if (mounted) {
          _transitionThen(() async {
            final unlocked = await _applyUnlock();
            if (!unlocked) {
              if (mounted) {
                _showUnlockFailure();
              }
              return;
            }
            if (!mounted) {
              return;
            }
            context.enterAuthenticatedApp(
              route: widget.successRoute ?? '/home',
            );
          });
        }

      case PinContext.sessionLock:
        // Show brief transition, then unlock + navigate together.
        if (mounted) {
          _transitionThen(() async {
            final unlocked = _applySessionUnlock();
            if (!unlocked) {
              _showUnlockFailure();
              return;
            }
            // Refresh wallet and transactions in the background after unlock.
            unawaited(
              Future.microtask(() {
                try {
                  unawaited(
                    ref.read(walletStateMachineProvider.notifier).refresh(),
                  );
                  unawaited(
                    ref
                        .read(transactionStateMachineProvider.notifier)
                        .refresh(),
                  );
                } on Object {}
              }),
            );
            context.enterAuthenticatedApp(
              route: widget.successRoute ?? '/home',
            );
          });
        }

      case PinContext.confirmAction:
        // Just pop with true — caller decides what to do
        if (mounted) context.pop(true);
    }
  }

  /// Unlock auth + session state. Kept separate so callers can run it in the
  /// same frame as navigation (see [_onSuccess]).
  Future<bool> _applyUnlock() async {
    if (widget.pinContext == PinContext.login) {
      final loginState = ref.read(loginProvider);
      final accessToken = loginState.sessionToken;
      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }
      return ref
          .read(authProvider.notifier)
          .completePinLogin(
            accessToken: accessToken,
            refreshToken: loginState.refreshToken,
            user: loginState.user,
            phone: loginState.phoneNumber,
            countryCode: loginState.countryCode,
            kycStatus: loginState.kycStatus,
            expiresIn: loginState.sessionExpiresIn,
          );
    }

    return _applySessionUnlock();
  }

  bool _applySessionUnlock() {
    try {
      ref.read(authProvider.notifier).unlock();
    } catch (_) {}
    try {
      ref.read(sessionServiceProvider.notifier).unlockSession();
    } catch (_) {}
    try {
      ref.read(appFsmProvider.notifier).unlockSession();
    } catch (_) {}
    return true;
  }

  /// Brief unlock animation before navigating away
  void _transitionThen(FutureOr<void> Function() navigate) {
    if (_hasCompletedSuccess) {
      return;
    }
    _hasCompletedSuccess = true;

    var didRun = false;
    Future<void> runOnce() async {
      if (didRun) return;
      didRun = true;
      await navigate();
    }

    setState(() => _showUnlockTransition = true);
    unawaited(
      Future.delayed(const Duration(milliseconds: 220), () {
        unawaited(runOnce());
      }),
    );
    unawaited(
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted && _showUnlockTransition) {
          unawaited(runOnce());
        }
      }),
    );
    unawaited(
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted || !_showUnlockTransition) return;
        _returnToPinEntry(
          message: 'Unlock is taking longer than expected. Please try again.',
        );
      }),
    );
  }

  void _showUnlockFailure() {
    setState(() {
      _hasCompletedSuccess = false;
      _queuedUnlockedRedirect = false;
      _showUnlockTransition = false;
      _isVerifying = false;
      _pin = '';
      _hasError = true;
      _errorMessage = 'Unable to unlock this session. Please sign in again.';
    });
  }

  void _returnToPinEntry({String? message}) {
    setState(() {
      _hasCompletedSuccess = false;
      _queuedUnlockedRedirect = false;
      _showUnlockTransition = false;
      _isVerifying = false;
      _pin = '';
      _hasError = false;
      _errorMessage = message;
    });
    unawaited(_checkBiometric());
  }

  void _recoverInterruptedBiometric() {
    final attempt = _biometricAttempt;
    unawaited(
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted ||
            !_isVerifying ||
            _showUnlockTransition ||
            attempt != _biometricAttempt) {
          return;
        }
        setState(() {
          _isVerifying = false;
          _pin = '';
          _hasError = false;
          _errorMessage = 'Biometric unlock was interrupted. Please try again.';
        });
        unawaited(_checkBiometric());
      }),
    );
  }

  Future<void> _verifyPin() async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

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
        if (mounted)
          setState(() {
            _pin = '';
            _hasError = false;
          });
      });
    }
  }

  Future<void> _handleBiometric() async {
    if (_isVerifying) return;
    final l10n = AppLocalizations.of(context)!;
    final attempt = ++_biometricAttempt;
    final userId = await _currentBiometricUserId();
    final bio = ref.read(biometricServiceProvider);
    if (userId == null || !await bio.isBiometricEnabled(userId: userId)) {
      if (mounted) {
        setState(() {
          _biometricEnabled = false;
          _isVerifying = false;
          _errorMessage =
              'Biometric unlock is unavailable. Please use your PIN.';
        });
      }
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });
    unawaited(
      Future.delayed(const Duration(seconds: 12), () {
        if (!mounted ||
            !_isVerifying ||
            _showUnlockTransition ||
            attempt != _biometricAttempt) {
          return;
        }
        setState(() {
          _isVerifying = false;
          _pin = '';
          _hasError = false;
          _errorMessage = 'Biometric unlock timed out. Please try again.';
        });
        unawaited(_checkBiometric());
      }),
    );

    try {
      final result = await bio.authenticate(
        localizedReason: l10n.biometric_reason,
      );
      if (attempt != _biometricAttempt) {
        return;
      }
      if (result.success && mounted) {
        _onSuccess();
        return;
      }

      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage = result.errorMessage;
        });
        await _checkBiometric();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage =
              'Biometric unlock is unavailable. Please use your PIN.';
        });
        await _checkBiometric();
      }
    }
  }

  Future<String?> _currentBiometricUserId() async {
    final authUserId = ref.read(authProvider).user?.id.trim();
    if (authUserId != null && authUserId.isNotEmpty) {
      return authUserId;
    }
    final storedUserId = await ref
        .read(secureStorageProvider)
        .read(key: StorageKeys.userId);
    final normalized = storedUserId?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  void _dismissIfAlreadyUnlocked() {
    if (_queuedUnlockedRedirect ||
        widget.pinContext == PinContext.confirmAction) {
      return;
    }

    final authState = ref.read(authProvider);
    final sessionState = ref.read(sessionServiceProvider);
    final shouldDismiss = switch (widget.pinContext) {
      PinContext.login => authState.isAuthenticated,
      PinContext.sessionLock =>
        authState.isAuthenticated &&
            !authState.isLocked &&
            !sessionState.isLocked,
      PinContext.confirmAction => false,
    };

    if (!shouldDismiss) {
      return;
    }

    _queuedUnlockedRedirect = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.pinContext == PinContext.login && !authState.isAuthenticated) {
        context.go('/login');
        return;
      }
      context.enterAuthenticatedApp(route: widget.successRoute ?? '/home');
    });
  }

  String get _title {
    if (widget.title != null) return widget.title!;
    final l10n = AppLocalizations.of(context)!;
    switch (widget.pinContext) {
      case PinContext.login:
        return l10n.login_enterPin;
      case PinContext.sessionLock:
        return l10n.session_enterPinToUnlock;
      case PinContext.confirmAction:
        return l10n.login_enterPin;
    }
  }

  String _subtitle(AppLocalizations l10n) {
    if (widget.subtitle != null) return widget.subtitle!;
    switch (widget.pinContext) {
      case PinContext.sessionLock:
        return l10n.session_lockedMessage;
      case PinContext.login:
      case PinContext.confirmAction:
        return l10n.login_pinSubtitle;
    }
  }

  Future<void> _handleLogout() async {
    try {
      await ref.read(authProvider.notifier).logout();
    } on Object {
      await ref.read(authProvider.notifier).clearLocalSession();
    }
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    if (_queuedUnlockedRedirect) {
      return Scaffold(backgroundColor: colors.canvas);
    }

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
                      l10n.pin_unlocked,
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: l10n.biometric_usePinInstead,
                      icon: Icons.pin_rounded,
                      onPressed: _returnToPinEntry,
                      variant: AppButtonVariant.secondary,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      _buildTopActionRow(colors, l10n),
                      const SizedBox(height: AppSpacing.xl),
                      _buildLogo(colors, size: 64),
                      const SizedBox(height: AppSpacing.xl),
                      AppText(
                        l10n.appName,
                        variant: AppTextVariant.headlineLarge,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppText(
                        _title,
                        variant: AppTextVariant.titleLarge,
                        color: colors.textPrimary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: AppText(
                          _subtitle(l10n),
                          variant: AppTextVariant.bodyMedium,
                          color: colors.textSecondary,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),

                      PinDots(length: 6, filled: _pin.length, error: _hasError),
                      const SizedBox(height: AppSpacing.md),

                      if (_remainingAttempts < PinService.maxAttempts)
                        AppText(
                          l10n.login_attemptsRemaining(_remainingAttempts),
                          variant: AppTextVariant.bodyMedium,
                          color: colors.warningText,
                        ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppText(
                          _errorMessage!,
                          variant: AppTextVariant.bodySmall,
                          color: colors.errorText,
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const Spacer(flex: 1),

                      if (_shouldShowBiometricUnlock) ...[
                        AppButton(
                          label: _biometricButtonLabel(l10n),
                          icon: _biometricIcon,
                          onPressed: _handleBiometric,
                          variant: AppButtonVariant.secondary,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      PinPad(
                        onDigitPressed: (digit) {
                          if (_pin.length >= 6) return;
                          setState(() {
                            _pin += digit.toString();
                            _hasError = false;
                            _errorMessage = null;
                          });
                          if (_pin.length == 6) {
                            unawaited(_verifyPin());
                          }
                        },
                        onDeletePressed: () {
                          if (_pin.isNotEmpty) {
                            setState(() {
                              _pin = _pin.substring(0, _pin.length - 1);
                              _hasError = false;
                            });
                          }
                        },
                        showBiometric: _shouldShowBiometricUnlock,
                        biometricIcon: _biometricIcon,
                        onBiometricPressed: _shouldShowBiometricUnlock
                            ? _handleBiometric
                            : null,
                      ),

                      const SizedBox(height: AppSpacing.xxl),
                      TextButton(
                        onPressed: () => context.push('/pin/reset'),
                        child: AppText(
                          l10n.login_forgotPin,
                          variant: AppTextVariant.bodyMedium,
                          color: colors.gold,
                        ),
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

  Widget _buildTopActionRow(ThemeColors colors, AppLocalizations l10n) {
    if (widget.pinContext == PinContext.confirmAction) {
      return Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(false),
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _handleLogout,
        child: AppText(
          l10n.common_logout,
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeColors colors, {required double size}) {
    return KoridoMark(size: size);
  }

  bool get _shouldShowBiometricUnlock => _biometricEnabled && !_isVerifying;

  String _biometricButtonLabel(AppLocalizations l10n) {
    switch (_biometricType) {
      case BiometricType.faceId:
        return l10n.biometric_type_face_id;
      case BiometricType.fingerprint:
        return l10n.biometric_type_fingerprint;
      case BiometricType.iris:
        return l10n.biometric_type_iris;
      case BiometricType.none:
        return l10n.security_biometricLogin;
    }
  }

  IconData get _biometricIcon {
    switch (_biometricType) {
      case BiometricType.faceId:
        return Icons.face_rounded;
      case BiometricType.fingerprint:
      case BiometricType.iris:
      case BiometricType.none:
        return Icons.fingerprint_rounded;
    }
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors.container,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.border),
                  ),
                  child: Icon(Icons.lock_clock, color: colors.error, size: 40),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppText(
                  l10n.login_accountLocked,
                  variant: AppTextVariant.headlineMedium,
                  color: colors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                AppText(
                  '${l10n.login_lockedMessage}\n${_lockSeconds > 0 ? '${(_lockSeconds / 60).ceil()} min' : ''}',
                  variant: AppTextVariant.bodyLarge,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: l10n.common_ok,
                  onPressed: () => context.go('/login'),
                  variant: AppButtonVariant.primary,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
