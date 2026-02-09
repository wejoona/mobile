import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../design/tokens/index.dart';
import '../../design/components/primitives/index.dart';
import '../../l10n/app_localizations.dart';
import '../biometric/biometric_service.dart';
import '../pin/pin_service.dart';
import '../feature_flags/feature_flags_provider.dart';
import '../app_review/app_review_service.dart';
import 'session_service.dart';
import '../../utils/logger.dart';

/// Widget that manages session lifecycle and shows timeout warnings
class SessionManager extends ConsumerStatefulWidget {
  final Widget child;

  const SessionManager({super.key, required this.child});

  @override
  ConsumerState<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends ConsumerState<SessionManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize app review service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appReviewServiceProvider).initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final sessionService = ref.read(sessionServiceProvider.notifier);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        sessionService.onAppBackground();
        break;
      case AppLifecycleState.resumed:
        sessionService.onAppForeground();
        // Refresh feature flags on app resume
        ref.read(featureFlagsProvider.notifier).loadFlags();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _recordActivity() {
    // Delay provider modification to avoid modifying during build/layout
    Future.microtask(() {
      if (mounted) {
        ref.read(sessionServiceProvider.notifier).recordActivity();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionServiceProvider);

    // Listen for session state changes - delay handling to ensure Navigator is ready
    ref.listen<SessionState>(sessionServiceProvider, (previous, next) {
      // Only handle state changes, not initial state
      if (previous == null) return;

      if (next.status == SessionStatus.expired && previous.status != SessionStatus.expired) {
        _handleSessionExpired();
      } else if (next.status == SessionStatus.locked && previous.status != SessionStatus.locked) {
        _handleSessionLocked();
      }
    });

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _recordActivity,
      onPanDown: (_) => _recordActivity(),
      onScaleStart: (_) => _recordActivity(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            _recordActivity();
          }
          return false;
        },
        child: Stack(
          children: [
            widget.child,

            // Session expiring warning overlay
            if (sessionState.isExpiring)
              _SessionExpiringOverlay(
                remainingSeconds: sessionState.remainingSeconds ?? 0,
                onExtend: () {
                  ref.read(sessionServiceProvider.notifier).extendSession();
                },
                onLogout: () {
                  ref.read(sessionServiceProvider.notifier).endSession();
                  context.go('/login');
                },
              ),
          ],
        ),
      ),
    );
  }

  void _handleSessionExpired() {
    // Navigate to login - delay to ensure GoRouter is ready
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            final colors = context.colors;
            context.go('/login');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Session expired. Please log in again.'),
                backgroundColor: colors.warning,
              ),
            );
          } catch (e) {
            // GoRouter not ready yet, ignore - user will be redirected on next navigation
            AppLogger('SessionManager').warn('Could not navigate on session expiry', e);
          }
        }
      });
    }
  }

  void _handleSessionLocked() {
    // Navigate to lock screen or show PIN entry
    if (mounted) {
      // Delay to ensure Navigator is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showLockScreen();
        }
      });
    }
  }

  void _showLockScreen() {
    // Check if we have a valid Navigator context
    if (!mounted) return;

    try {
      final colors = context.colors;
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        backgroundColor: colors.canvas,
        builder: (context) => const _LockScreen(),
      );
    } catch (e) {
      // Navigator not ready yet, ignore
      AppLogger('Could not show lock screen').error('Could not show lock screen', e);
    }
  }
}

/// Overlay shown when session is about to expire
class _SessionExpiringOverlay extends StatelessWidget {
  final int remainingSeconds;
  final VoidCallback onExtend;
  final VoidCallback onLogout;

  const _SessionExpiringOverlay({
    required this.remainingSeconds,
    required this.onExtend,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.xxl),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: colors.container,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer,
                  color: colors.warning,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppText(
                l10n.session_expiring,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                l10n.session_expiringMessage(remainingSeconds),
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Countdown circle
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: remainingSeconds / 30, // Assuming 30s warning
                        strokeWidth: 6,
                        backgroundColor: colors.borderSubtle,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          remainingSeconds <= 10
                              ? colors.error
                              : colors.warning,
                        ),
                      ),
                    ),
                    AppText(
                      '$remainingSeconds',
                      variant: AppTextVariant.headlineSmall,
                      color: remainingSeconds <= 10
                          ? colors.error
                          : colors.warning,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.common_logout,
                      onPressed: onLogout,
                      variant: AppButtonVariant.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: l10n.session_stayLoggedIn,
                      onPressed: onExtend,
                      variant: AppButtonVariant.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lock screen requiring PIN/biometric to unlock
class _LockScreen extends ConsumerStatefulWidget {
  const _LockScreen();

  @override
  ConsumerState<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<_LockScreen> {
  String _enteredPin = '';
  String? _error;
  bool _isVerifying = false;
  bool _isLocked = false;
  int? _lockRemainingSeconds;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock,
                color: colors.gold,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppText(
              'Session Locked',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'Enter your PIN to continue',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                final hasError = _error != null;

                return Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isFilled
                        ? (hasError ? colors.error : colors.gold)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasError
                          ? colors.error
                          : (isFilled ? colors.gold : colors.borderSubtle),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            if (_error != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppText(
                _error!,
                variant: AppTextVariant.bodyMedium,
                color: colors.error,
              ),
            ],

            const Spacer(),

            // PIN pad
            _buildPinPad(colors),

            const SizedBox(height: AppSpacing.xxl),

            // Logout option
            TextButton(
              onPressed: () {
                ref.read(sessionServiceProvider.notifier).endSession();
                Navigator.of(context).pop();
                context.go('/login');
              },
              child: AppText(
                'Log out instead',
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinPad(ThemeColors colors) {
    return Column(
      children: [
        for (var row = 0; row < 4; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var col = 0; col < 3; col++)
                  _buildPinButton(row, col, colors),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPinButton(int row, int col, ThemeColors colors) {
    String? label;
    VoidCallback? onTap;
    IconData? icon;

    if (row < 3) {
      final number = row * 3 + col + 1;
      label = '$number';
      onTap = () => _onDigitPressed(number);
    } else {
      if (col == 0) {
        // Biometric button
        icon = Icons.fingerprint;
        onTap = _onBiometricPressed;
      } else if (col == 1) {
        label = '0';
        onTap = () => _onDigitPressed(0);
      } else {
        // Delete button
        icon = Icons.backspace_outlined;
        onTap = _onDeletePressed;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.container,
          shape: BoxShape.circle,
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: colors.textSecondary, size: 28)
              : AppText(
                  label ?? '',
                  variant: AppTextVariant.headlineSmall,
                  color: colors.textPrimary,
                ),
        ),
      ),
    );
  }

  void _onDigitPressed(int digit) {
    if (_enteredPin.length >= 4) return;

    setState(() {
      _error = null;
      _enteredPin += digit.toString();
    });

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isEmpty) return;

    setState(() {
      _error = null;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _onBiometricPressed() async {
    final biometricService = ref.read(biometricServiceProvider);

    // Check if biometric is enabled for this user
    final isEnabled = await biometricService.isBiometricEnabled();
    if (!isEnabled) {
      setState(() {
        _error = 'Biometric not enabled';
      });
      return;
    }

    // Authenticate with biometric
    final success = await biometricService.authenticate(
      reason: 'Unlock your JoonaPay wallet',
    );

    if (success) {
      _unlockSession();
    } else {
      setState(() {
        _error = 'Biometric authentication failed';
      });
    }
  }

  void _verifyPin() async {
    if (_isVerifying || _isLocked) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final pinService = ref.read(pinServiceProvider);
      final result = await pinService.verifyPinLocally(_enteredPin);

      if (result.success) {
        _unlockSession();
      } else {
        setState(() {
          _error = result.message ?? 'Incorrect PIN';
          _enteredPin = '';
          _isLocked = result.isLocked;
          _lockRemainingSeconds = result.lockRemainingSeconds;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _unlockSession() {
    ref.read(sessionServiceProvider.notifier).unlockSession();
    Navigator.of(context).pop();
  }
}
