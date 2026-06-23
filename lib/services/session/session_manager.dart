import 'dart:async';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/router/app_router.dart';
import 'package:usdc_wallet/services/app_review/app_review_service.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_provider.dart';
import 'package:usdc_wallet/services/session/session_service.dart';
import 'package:usdc_wallet/utils/context_extensions.dart';
import 'package:usdc_wallet/utils/logger.dart';

enum _SessionWarningAction { extend, logout }

/// Widget that manages session lifecycle and shows timeout warnings
class SessionManager extends ConsumerStatefulWidget {
  final Widget child;

  const SessionManager({super.key, required this.child});

  @override
  ConsumerState<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends ConsumerState<SessionManager>
    with WidgetsBindingObserver {
  _SessionWarningAction? _sessionWarningAction;

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
        if (ref.read(authProvider).isAuthenticated) {
          ref.read(featureFlagsProvider.notifier).loadFlags();
        }
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
        final session = ref.read(sessionServiceProvider);
        if (!session.isExpiring) {
          ref.read(sessionServiceProvider.notifier).recordActivity();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionServiceProvider);
    final authState = ref.watch(authProvider);
    if (!sessionState.isExpiring && _sessionWarningAction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !ref.read(sessionServiceProvider).isExpiring) {
          setState(() => _sessionWarningAction = null);
        }
      });
    }

    // Listen for session state changes - delay handling to ensure Navigator is ready
    ref.listen<SessionState>(sessionServiceProvider, (previous, next) {
      // Only handle state changes, not initial state
      if (previous == null) return;

      if (next.status == SessionStatus.expired &&
          previous.status != SessionStatus.expired) {
        _handleSessionExpired();
      } else if (next.status == SessionStatus.locked &&
          previous.status != SessionStatus.locked) {
        // Route to lock screen for every fresh lock transition, including
        // active -> locked and expiring -> locked after the warning countdown.
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
            if (authState.isAuthenticated &&
                sessionState.isExpiring &&
                _shouldShowExpiringOverlay(context))
              _SessionExpiringOverlay(
                remainingSeconds: sessionState.remainingSeconds ?? 0,
                resolvingAction: _sessionWarningAction,
                onExtend: () {
                  setState(
                    () => _sessionWarningAction = _SessionWarningAction.extend,
                  );
                  unawaited(_extendFromSessionWarning());
                },
                onLogout: () {
                  setState(
                    () => _sessionWarningAction = _SessionWarningAction.logout,
                  );
                  unawaited(_logoutFromSessionWarning());
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
      final router = ref.read(routerProvider);
      final location = router.routeInformationProvider.value.uri.path;
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

  Future<void> _extendFromSessionWarning() async {
    try {
      ref.read(sessionServiceProvider.notifier).extendSession();
    } on Object catch (e) {
      const AppLogger(
        'SessionManager',
      ).warn('Could not extend session warning', e);
    } finally {
      if (mounted) {
        setState(() => _sessionWarningAction = null);
      }
    }
  }

  Future<void> _logoutFromSessionWarning() async {
    var didClearSession = false;
    try {
      await ref.read(authProvider.notifier).logout();
      didClearSession = true;
    } catch (e) {
      AppLogger('SessionManager').warn('Could not log out from warning', e);
    }

    if (!didClearSession) {
      try {
        await ref.read(authProvider.notifier).clearLocalSession();
      } catch (e) {
        AppLogger(
          'SessionManager',
        ).warn('Could not clear local session from warning', e);
      }
    }

    if (!mounted) {
      return;
    }
    _go('/login');
  }

  void _handleSessionExpired() {
    // Schedule logout after the state change so navigation and providers are ready.
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_expireSession());
        }
      });
    }
  }

  Future<void> _expireSession() async {
    var didClearSession = false;
    try {
      await ref.read(authProvider.notifier).logout();
      didClearSession = true;
    } catch (e) {
      AppLogger('SessionManager').warn('Could not handle session expiry', e);
    }

    if (!didClearSession) {
      try {
        await ref.read(authProvider.notifier).clearLocalSession();
      } catch (e) {
        AppLogger(
          'SessionManager',
        ).warn('Could not clear local session after expiry', e);
      }
    }

    if (!mounted) return;

    context.showSnack(
      'Session expired. Please log in again.',
      tone: AppSnackTone.error,
    );
    _go('/login');
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
    final session = ref.read(sessionServiceProvider);
    if (!session.isLocked) {
      return;
    }

    final returnTo = _currentRouteForLock();
    final encodedReturnTo = Uri.encodeComponent(returnTo);
    const lockRoute = '/session-locked';
    _go('$lockRoute?returnTo=$encodedReturnTo');
  }

  String _currentRouteForLock() {
    try {
      final router = ref.read(routerProvider);
      final uri = router.routeInformationProvider.value.uri;
      final location = uri.toString();
      if (location.isNotEmpty && !location.startsWith('/session-locked')) {
        return location;
      }
    } catch (error) {
      AppLogger(
        'SessionManager',
      ).warning('Could not resolve current route for session lock', error);
    }
    return '/home';
  }

  void _go(String location) {
    try {
      context.fsmGo(location);
    } on Object catch (fallbackError) {
      AppLogger(
        'SessionManager',
      ).error('Could not navigate to $location', fallbackError);
    }
  }
}

/// Overlay shown when session is about to expire
class _SessionExpiringOverlay extends StatelessWidget {
  final int remainingSeconds;
  final _SessionWarningAction? resolvingAction;
  final VoidCallback onExtend;
  final VoidCallback onLogout;

  const _SessionExpiringOverlay({
    required this.remainingSeconds,
    required this.resolvingAction,
    required this.onExtend,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final isUrgent = remainingSeconds <= 10;
    final timerColor = isUrgent ? colors.error : colors.gold;
    final timerBackground = isUrgent ? colors.errorBg : colors.goldSubtle;
    final isResolving = resolvingAction != null;
    final borderColor = isUrgent
        ? colors.error.withValues(alpha: colors.isDark ? 0.42 : 0.28)
        : colors.borderGold;

    return Material(
      color: Colors.black.withValues(alpha: colors.isDark ? 0.70 : 0.52),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colors.container,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: colors.isDark ? 0.42 : 0.16,
                  ),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: timerBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(
                    isUrgent ? Icons.lock_clock_rounded : Icons.shield_rounded,
                    color: timerColor,
                    size: 34,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppText(
                  l10n.session_expiring,
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppText(
                  l10n.session_expiringMessage(remainingSeconds),
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: (remainingSeconds / 60).clamp(0.0, 1.0),
                          strokeWidth: 5,
                          strokeCap: StrokeCap.round,
                          backgroundColor: colors.borderSubtle,
                          valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                        ),
                      ),
                      AppText(
                        '$remainingSeconds',
                        variant: AppTextVariant.titleLarge,
                        color: timerColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      label: l10n.session_stayLoggedIn,
                      icon: Icons.verified_user_rounded,
                      onPressed: isResolving ? null : onExtend,
                      variant: AppButtonVariant.primary,
                      isLoading:
                          resolvingAction == _SessionWarningAction.extend,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: l10n.common_logout,
                      icon: Icons.logout_rounded,
                      onPressed: isResolving ? null : onLogout,
                      variant: AppButtonVariant.secondary,
                      isLoading:
                          resolvingAction == _SessionWarningAction.logout,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
