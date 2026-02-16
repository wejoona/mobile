import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_provider.dart';
import 'package:usdc_wallet/services/app_review/app_review_service.dart';
import 'package:usdc_wallet/services/session/session_service.dart';
import 'package:usdc_wallet/utils/logger.dart';

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
      } else if (next.status == SessionStatus.locked && 
                 previous.status == SessionStatus.active) {
        // Only show lock screen if transitioning FROM active (not on initial restore)
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

            // Session expiring warning overlay (only on authenticated screens, not PIN/login)
            if (sessionState.isExpiring && _shouldShowExpiringOverlay(context))
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

  /// Check if we should show the expiring overlay based on current route
  bool _shouldShowExpiringOverlay(BuildContext context) {
    try {
      final location = GoRouterState.of(context).uri.path;
      // Don't show on auth-related screens
      const suppressedRoutes = [
        '/login',
        '/pin',
        '/register',
        '/onboarding',
        '/session-locked',
        '/verify',
      ];
      return !suppressedRoutes.any((r) => location.startsWith(r));
    } catch (_) {
      return true; // Show by default if route check fails
    }
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
      context.go('/session-locked');
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

