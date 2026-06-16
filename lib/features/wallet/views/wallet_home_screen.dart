import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/core/orientation/orientation_helper.dart';
import 'package:usdc_wallet/design/animations/staggered_entrance.dart';
import 'package:usdc_wallet/design/components/composed/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/primitives/offline_banner.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/utils/responsive_layout.dart';
import 'package:usdc_wallet/domain/entities/limit.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/limits/providers/limits_provider.dart';
import 'package:usdc_wallet/features/limits/widgets/limit_warning_banner.dart';
import 'package:usdc_wallet/features/notifications/providers/notification_count_provider.dart';
import 'package:usdc_wallet/features/wallet/widgets/cached_data_chip.dart';
import 'package:usdc_wallet/features/wallet/widgets/wallet_home_actions.dart';
import 'package:usdc_wallet/features/wallet/widgets/wallet_home_status_widgets.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/currency/currency_provider.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/utils/context_extensions.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Enhanced Wallet Home Screen
///
/// Features:
/// - Time-based greeting (Good morning/afternoon/evening/night)
/// - Balance display with hide/show toggle
/// - 4 Quick actions (Send, Receive, Deposit, History)
/// - KYC verification banner (conditional)
/// - Recent transactions (3-5 items)
/// - Pull-to-refresh
/// - Balance count-up animation
/// - Settings and notification icons
class WalletHomeScreen extends ConsumerStatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  ConsumerState<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends ConsumerState<WalletHomeScreen>
    with SingleTickerProviderStateMixin {
  static const _logger = AppLogger('WalletHome');

  bool _isBalanceHidden = false;
  bool _isCreatingWallet = false;
  bool _walletFetchScheduled = false;
  late AnimationController _balanceAnimationController;
  late Animation<double> _balanceAnimation;
  double _displayedBalance = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadBalanceVisibilityPreference());
    _balanceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _balanceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _balanceAnimationController,
        curve: Curves.easeOut,
      ),
    );
    unawaited(
      Future<void>.microtask(() async {
        final wallet = ref.read(walletStateMachineProvider);
        if (wallet.status == WalletStatus.initial ||
            (wallet.status == WalletStatus.error && !wallet.hasBalanceData)) {
          await ref.read(walletStateMachineProvider.notifier).fetch();
        }
      }),
    );
    // Fetch limits on init
    unawaited(
      Future<void>.microtask(
        () => ref.read(limitsProvider.notifier).fetchLimits(),
      ),
    );
  }

  @override
  void dispose() {
    _balanceAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadBalanceVisibilityPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBalanceHidden = prefs.getBool('balance_hidden') ?? false;
    });
  }

  Future<void> _toggleBalanceVisibility() async {
    await HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBalanceHidden = !_isBalanceHidden;
    });
    await prefs.setBool('balance_hidden', _isBalanceHidden);
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return l10n.home_goodMorning;
    } else if (hour >= 12 && hour < 17) {
      return l10n.home_goodAfternoon;
    } else if (hour >= 17 && hour < 21) {
      return l10n.home_goodEvening;
    } else {
      return l10n.home_goodNight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletStateMachineProvider);
    final txState = ref.watch(transactionStateMachineProvider);
    final userName = ref.watch(userDisplayNameProvider);
    ref.watch(notificationPollingProvider);
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final isLandscape = OrientationHelper.isLandscape(context);

    _ensureWalletLoadScheduled(walletState);

    // Trigger transaction fetch once wallet is loaded
    if (walletState.status == WalletStatus.loaded &&
        walletState.walletId.isNotEmpty) {
      final txStatus = txState.status;
      if (txStatus == TransactionListStatus.initial) {
        unawaited(
          Future<void>.microtask(
            () => ref.read(transactionStateMachineProvider.notifier).fetch(),
          ),
        );
      }
    }

    // Trigger balance animation when loaded
    if (walletState.status == WalletStatus.loaded &&
        !_balanceAnimationController.isAnimating &&
        _balanceAnimationController.status != AnimationStatus.completed) {
      _displayedBalance = walletState.usdcBalance;
      unawaited(_balanceAnimationController.forward(from: 0));
    } else if (walletState.status == WalletStatus.loaded &&
        _displayedBalance != walletState.usdcBalance) {
      _displayedBalance = walletState.usdcBalance;
      unawaited(_balanceAnimationController.forward(from: 0));
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      body: Column(
        children: [
          // Offline/Sync Status Banner
          const OfflineStatusBanner(),

          Expanded(
            child: SafeArea(
              child: AppRefreshIndicator(
                onRefresh: _refreshHomeData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedContent(
                    child: Padding(
                      padding: OrientationHelper.padding(
                        context,
                        portrait: ResponsiveLayout.padding(
                          context,
                          mobile: const EdgeInsets.all(
                            AppSpacing.screenPadding,
                          ),
                          tablet: const EdgeInsets.all(AppSpacing.xl),
                        ),
                        landscape: ResponsiveLayout.padding(
                          context,
                          mobile: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.md,
                          ),
                          tablet: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                            vertical: AppSpacing.lg,
                          ),
                        ),
                      ),
                      child: isLandscape
                          ? _buildLandscapeLayout(
                              context,
                              ref,
                              walletState,
                              txState,
                              userName,
                              l10n,
                              colors,
                            )
                          : ResponsiveBuilder(
                              mobile: _buildMobileLayout(
                                context,
                                ref,
                                walletState,
                                txState,
                                userName,
                                l10n,
                                colors,
                              ),
                              tablet: _buildTabletLayout(
                                context,
                                ref,
                                walletState,
                                txState,
                                userName,
                                l10n,
                                colors,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(
    BuildContext context,
    WidgetRef ref,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    return Stack(
      children: [
        IconButton(
          onPressed: () => unawaited(context.push('/notifications')),
          icon: Icon(Icons.notifications_outlined, color: colors.textSecondary),
          tooltip: l10n.settings_notifications,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    String userName,
    ThemeColors colors,
  ) {
    final userState = ref.watch(userStateMachineProvider);

    // Show name if available, otherwise show phone number
    // Never hide the user's identity — phone is their identifier until they set a name
    final displayName = userName.isNotEmpty && userName != 'User'
        ? userName
        : null;
    final greeting = _getGreeting(l10n);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar and greeting
        Expanded(
          child: Row(
            children: [
              UserAvatar(
                imageUrl: userState.effectiveAvatarUrl,
                firstName: userState.firstName,
                lastName: userState.lastName,
                showBorder: true,
                borderColor: colors.gold,
                onTap: () => unawaited(context.push('/settings/profile')),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (displayName != null) ...[
                      AppText(
                        displayName,
                        variant: AppTextVariant.headlineSmall,
                        color: colors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                    ],
                    AppText(greeting, color: colors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Action icons
        Row(
          children: [
            _buildNotificationIcon(context, ref, colors, l10n),
            IconButton(
              onPressed: () => context.go('/settings'),
              icon: Icon(Icons.settings_outlined, color: colors.textSecondary),
              tooltip: l10n.navigation_settings,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    WidgetRef ref,
    WalletState walletState,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    // Handle null/empty wallet state
    if (walletState.status == WalletStatus.initial) {
      return WalletLoadingCard(
        colors: colors,
        label: l10n.wallet_loadingWallet,
      );
    }

    if (walletState.hasError && !walletState.hasBalanceData) {
      return WalletErrorCard(
        colors: colors,
        error: walletState.error ?? l10n.error_failedToLoadBalance,
        retryLabel: l10n.action_retry,
        onRetry: () =>
            unawaited(ref.read(walletStateMachineProvider.notifier).refresh()),
      );
    }

    // Check if wallet exists
    final hasWallet = walletState.walletId.isNotEmpty;

    if (!hasWallet && !walletState.isLoading) {
      // Auto-create wallet — no manual button needed
      unawaited(_autoCreateWallet(ref));
      return WalletCreatingState(colors: colors);
    }

    final primaryBalance = walletState.usdcBalance;
    final pendingBalance = walletState.pendingBalance;
    final totalBalance = primaryBalance + pendingBalance;
    final showInitialBalanceLoading =
        walletState.isLoading && !walletState.hasBalanceData;

    final currencyState = ref.watch(currencyProvider);
    final currencyService = ref.read(currencyServiceProvider);
    final referenceCurrency = currencyState.shouldShowReference
        ? currencyState.referenceCurrency
        : null;
    final referenceAmount = referenceCurrency == null
        ? null
        : currencyService.formatReferenceAmount(
            currencyService.convertToReference(
              primaryBalance,
              referenceCurrency,
            ),
            referenceCurrency,
          );

    final balanceHasActivity =
        primaryBalance > 0 || pendingBalance > 0 || totalBalance > 0;
    final surfaceStart = colors.isDark
        ? Color.alphaBlend(colors.gold.withValues(alpha: 0.07), colors.surface)
        : Color.alphaBlend(
            colors.gold.withValues(alpha: 0.055),
            colors.surface,
          );
    final surfaceColor = Color.alphaBlend(
      colors.gold.withValues(alpha: colors.isDark ? 0.035 : 0.025),
      surfaceStart,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: colors.gold.withValues(alpha: colors.isDark ? 0.24 : 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.gold.withValues(alpha: colors.isDark ? 0.10 : 0.14),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: colors.isDark
                ? Colors.black.withValues(alpha: 0.26)
                : const Color(0x245A431B),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: AppSpacing.xxl,
              right: AppSpacing.xxl,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      colors.gold.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: colors.gold.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: colors.gold,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppText(
                          l10n.wallet_availableBalance,
                          variant: AppTextVariant.labelLarge,
                          color: colors.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            colors.gold.withValues(
                              alpha: colors.isDark ? 0.12 : 0.08,
                            ),
                            colors.surface,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: colors.gold.withValues(alpha: 0.18),
                          ),
                        ),
                        child: IconButton(
                          onPressed: _toggleBalanceVisibility,
                          icon: Icon(
                            _isBalanceHidden
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: colors.textSecondary.withValues(alpha: 0.82),
                            size: 18,
                          ),
                          tooltip: _isBalanceHidden
                              ? l10n.home_showBalance
                              : l10n.home_hideBalance,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.expand(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (walletState.isRefreshing) ...[
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors.gold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.gold.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: colors.gold.withValues(alpha: 0.18),
                          ),
                        ),
                        child: AppText(
                          l10n.wallet_usdcBalance,
                          variant: AppTextVariant.labelSmall,
                          color: colors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (showInitialBalanceLoading)
                    const AppSkeleton(width: 210, height: 52)
                  else if (_isBalanceHidden)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: WalletHiddenBalance(colors: colors),
                    )
                  else
                    primaryBalance == 0
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: AmountText(
                              amount: primaryBalance,
                              size: AmountTextSize.display,
                              color: colors.textPrimary,
                            ),
                          )
                        : AnimatedBuilder(
                            animation: _balanceAnimation,
                            builder: (context, child) {
                              final animatedValue =
                                  primaryBalance * _balanceAnimation.value;
                              return FadeTransition(
                                opacity: _balanceAnimation,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: AmountText(
                                    amount: animatedValue,
                                    size: AmountTextSize.display,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              );
                            },
                          ),
                  const SizedBox(height: AppSpacing.xs),
                  if (!showInitialBalanceLoading &&
                      (_isBalanceHidden || referenceAmount != null))
                    AppText(
                      _isBalanceHidden
                          ? l10n.wallet_balanceHidden
                          : '≈ $referenceAmount',
                      color: colors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (!showInitialBalanceLoading && !_isBalanceHidden) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: colors.gold.withValues(alpha: 0.14),
                          ),
                          bottom: BorderSide(
                            color: colors.gold.withValues(alpha: 0.10),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildBalanceMetric(
                              label: l10n.wallet_availableToSend,
                              amount: primaryBalance,
                              colors: colors,
                            ),
                          ),
                          _buildBalanceDivider(colors),
                          Expanded(
                            child: _buildBalanceMetric(
                              label: l10n.wallet_pendingBalance,
                              amount: pendingBalance,
                              colors: colors,
                              valueColor: pendingBalance > 0
                                  ? colors.warningText
                                  : null,
                            ),
                          ),
                          _buildBalanceDivider(colors),
                          Expanded(
                            child: _buildBalanceMetric(
                              label: l10n.wallet_totalBalance,
                              amount: totalBalance,
                              colors: colors,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!showInitialBalanceLoading) ...[
                    SizedBox(
                      height: balanceHasActivity
                          ? AppSpacing.md
                          : AppSpacing.lg,
                    ),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _buildBalanceStatusItem(
                          colors: colors,
                          icon: Icons.verified_user_outlined,
                          label: l10n.wallet_securedWallet,
                        ),
                        _buildBalanceStatusItem(
                          colors: colors,
                          icon: walletState.isDegraded || walletState.isStale
                              ? Icons.cloud_off_rounded
                              : walletState.isRefreshing
                              ? Icons.sync_rounded
                              : Icons.verified_rounded,
                          label: _balanceSyncLabel(walletState, l10n),
                          color: walletState.isDegraded || walletState.isStale
                              ? colors.warningText
                              : null,
                        ),
                      ],
                    ),
                    if (_shouldShowBalanceWarning(walletState)) ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildBalanceWarning(walletState, colors, l10n),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceDivider(ThemeColors colors) => SizedBox(
    height: 38,
    child: VerticalDivider(
      width: AppSpacing.md,
      thickness: 1,
      color: colors.gold.withValues(alpha: 0.12),
    ),
  );

  Widget _buildBalanceMetric({
    required String label,
    required double amount,
    required ThemeColors colors,
    Color? valueColor,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText(
        label,
        variant: AppTextVariant.labelSmall,
        color: colors.textSecondary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: AppSpacing.xs),
      AmountText(
        amount: amount,
        size: AmountTextSize.small,
        color: valueColor ?? colors.textPrimary,
      ),
    ],
  );

  Widget _buildBalanceStatusItem({
    required ThemeColors colors,
    required IconData icon,
    required String label,
    Color? color,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: color ?? colors.gold.withValues(alpha: 0.82)),
      const SizedBox(width: AppSpacing.xs),
      AppText(
        label,
        variant: AppTextVariant.labelSmall,
        color: color ?? colors.textSecondary,
      ),
    ],
  );

  bool _shouldShowBalanceWarning(WalletState walletState) {
    final warning = walletState.balanceWarning?.trim();
    return walletState.isDegraded ||
        walletState.isStale ||
        (warning != null && warning.isNotEmpty);
  }

  Widget _buildBalanceWarning(
    WalletState walletState,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.warning.withValues(alpha: colors.isDark ? 0.16 : 0.10),
          colors.surface,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.warning.withValues(alpha: colors.isDark ? 0.28 : 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colors.warningText, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              _balanceWarningMessage(walletState, l10n),
              variant: AppTextVariant.bodySmall,
              color: colors.warningText,
            ),
          ),
        ],
      ),
    );
  }

  String _balanceWarningMessage(
    WalletState walletState,
    AppLocalizations l10n,
  ) {
    final warning = walletState.balanceWarning?.trim();
    if (warning != null && warning.isNotEmpty) {
      return warning;
    }
    return l10n.wallet_liveSyncDelayedMessage;
  }

  String _balanceSyncLabel(WalletState walletState, AppLocalizations l10n) {
    if (walletState.isRefreshing) {
      return l10n.wallet_refreshingBalance;
    }

    if (walletState.isDegraded || walletState.isStale) {
      return l10n.wallet_syncDelayed;
    }

    final status = walletState.balanceReadStatus;
    if (status == 'degraded' ||
        status == 'cached_degraded' ||
        status == 'local_mirror') {
      return l10n.wallet_syncDelayed;
    }

    final warning = walletState.balanceWarning;
    if (warning != null && warning.trim().isNotEmpty) {
      return l10n.wallet_syncDelayed;
    }

    if (walletState.balanceReadStatus == 'fresh' ||
        walletState.balanceSourceOfTruth == 'blnk') {
      return l10n.wallet_liveBalance;
    }

    if (walletState.walletId.isNotEmpty) {
      return l10n.wallet_active;
    }

    return l10n.wallet_balanceReady;
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    WalletState walletState,
    TransactionListState txState,
    String userName,
    AppLocalizations l10n,
    ThemeColors colors,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      StaggeredEntrance(
        index: 0,
        child: _buildHeader(context, l10n, userName, colors),
      ),
      const SizedBox(height: AppSpacing.xxl),
      StaggeredEntrance(
        index: 1,
        child: _buildBalanceCard(context, ref, walletState, l10n, colors),
      ),
      if (walletState.isCached && walletState.lastUpdated != null)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: CachedDataChip(lastUpdated: walletState.lastUpdated!),
        ),
      const SizedBox(height: AppSpacing.xxl),
      StaggeredEntrance(
        index: 2,
        child: _buildQuickActions(context, ref, l10n),
      ),
      const SizedBox(height: AppSpacing.xxl),
      StaggeredEntrance(
        index: 3,
        child: _buildKycBanner(context, ref, l10n, colors),
      ),
      _buildLimitsWarningBanner(context, ref, l10n),
      StaggeredEntrance(
        index: 4,
        child: _buildTransactionList(context, txState, l10n, colors),
      ),
      const SizedBox(height: AppSpacing.xxl),
    ],
  );

  Widget _buildTabletLayout(
    BuildContext context,
    WidgetRef ref,
    WalletState walletState,
    TransactionListState txState,
    String userName,
    AppLocalizations l10n,
    ThemeColors colors,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildHeader(context, l10n, userName, colors),
      const SizedBox(height: AppSpacing.xxl),

      // Two-column layout: Balance + Quick Actions
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildBalanceCard(context, ref, walletState, l10n, colors),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            flex: 2,
            child: Column(
              children: [_buildQuickActionsGrid(context, ref, l10n)],
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.xxl),

      _buildKycBanner(context, ref, l10n, colors),
      _buildLimitsWarningBanner(context, ref, l10n),

      // Full-width transactions on tablet
      _buildTransactionList(context, txState, l10n, colors),
      const SizedBox(height: AppSpacing.xxl),
    ],
  );

  /// Landscape layout: Horizontal split with balance/actions on left, transactions on right
  Widget _buildLandscapeLayout(
    BuildContext context,
    WidgetRef ref,
    WalletState walletState,
    TransactionListState txState,
    String userName,
    AppLocalizations l10n,
    ThemeColors colors,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildHeader(context, l10n, userName, colors),
      const SizedBox(height: AppSpacing.lg),

      // Two-column landscape layout
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Balance + Quick Actions + Banners
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(context, ref, walletState, l10n, colors),
                const SizedBox(height: AppSpacing.lg),
                _buildQuickActions(context, ref, l10n),
                const SizedBox(height: AppSpacing.lg),
                _buildKycBanner(context, ref, l10n, colors),
                _buildLimitsWarningBanner(context, ref, l10n),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),

          // Right column: Transactions
          Expanded(
            flex: 3,
            child: _buildTransactionList(context, txState, l10n, colors),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
    ],
  );

  Widget _buildQuickActions(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) => WalletQuickActionsRow(actions: _quickActions(context, ref, l10n));

  Widget _buildQuickActionsGrid(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) => WalletQuickActionsGrid(actions: _quickActions(context, ref, l10n));

  List<WalletQuickActionData> _quickActions(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) => [
    WalletQuickActionData(
      icon: Icons.send_rounded,
      label: l10n.home_quickAction_send,
      route: '/send',
      onTap: () => _openMoneyFlow(
        context,
        ref,
        l10n,
        operation: TransactionLimitOperation.send,
        route: '/send',
      ),
    ),
    WalletQuickActionData(
      icon: Icons.qr_code_2_rounded,
      label: l10n.home_quickAction_receive,
      route: '/receive',
    ),
    WalletQuickActionData(
      icon: Icons.add_circle_outline_rounded,
      label: l10n.home_quickAction_deposit,
      route: '/deposit',
      onTap: () => _openMoneyFlow(
        context,
        ref,
        l10n,
        operation: TransactionLimitOperation.deposit,
        route: '/deposit',
      ),
    ),
    WalletQuickActionData(
      icon: Icons.history_rounded,
      label: l10n.home_quickAction_history,
      route: '/transactions',
    ),
  ];

  void _openMoneyFlow(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n, {
    required TransactionLimitOperation operation,
    required String route,
  }) {
    final limits = ref.read(limitsProvider).limits;
    final permissions = limits?.permissions;

    if (permissions == null || permissions.can(operation)) {
      unawaited(context.push(route));
      return;
    }

    final reason = permissions.blockReason?.trim();
    final message = reason != null && reason.isNotEmpty
        ? reason
        : permissions.reviewRequired
        ? l10n.moneyFlow_reviewRequiredMessage
        : l10n.moneyFlow_verificationRequiredMessage;

    context.showSnack(
      message,
      tone: permissions.reviewRequired
          ? AppSnackTone.info
          : AppSnackTone.warning,
      duration: const Duration(seconds: 4),
      action: permissions.reviewRequired
          ? null
          : SnackBarAction(
              label: l10n.auth_verify,
              onPressed: () => unawaited(context.push('/kyc')),
            ),
    );
  }

  Widget _buildKycBanner(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    final userState = ref.watch(userStateMachineProvider);

    // Only show if user is authenticated and KYC is not verified
    if (!userState.isAuthenticated) {
      return const SizedBox.shrink();
    }

    final kycStatus = userState.kycStatus;

    // Don't show banner if verified or already submitted (in review)
    if (kycStatus == KycStatus.verified || kycStatus.isInReview) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () => unawaited(context.push('/kyc')),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            margin: const EdgeInsets.only(bottom: AppSpacing.xxl),
            decoration: BoxDecoration(
              color: colors.warningBase.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: colors.warningBase.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: colors.warningBase,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        l10n.home_kycBanner_title,
                        variant: AppTextVariant.labelLarge,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        l10n.home_kycBanner_action,
                        variant: AppTextVariant.bodySmall,
                        color: colors.warningBase,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: colors.warningBase,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitsWarningBanner(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final limitsState = ref.watch(limitsProvider);

    // Don't show if loading or no data
    if (limitsState.isLoading || limitsState.limits == null) {
      return const SizedBox.shrink();
    }

    final limits = limitsState.limits!;

    // Only show if approaching or at limit
    if (!limits.isDailyNearLimit &&
        !limits.isDailyAtLimit &&
        !limits.isMonthlyNearLimit &&
        !limits.isMonthlyAtLimit) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: LimitWarningBanner(limits: limits),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    TransactionListState txState,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    if (txState.status == TransactionListStatus.error) {
      return WalletErrorCard(
        colors: colors,
        error: txState.error ?? l10n.error_failedToLoadTransactions,
        retryLabel: l10n.action_retry,
        onRetry: () => unawaited(
          ref
              .read(transactionStateMachineProvider.notifier)
              .refresh(refreshWallet: false),
        ),
      );
    }

    if (txState.isLoading && txState.transactions.isEmpty) {
      return const TransactionList(transactions: [], isLoading: true);
    }

    if (txState.transactions.isEmpty) {
      return _buildEmptyTransactions(context, l10n, colors);
    }

    // Show only 3-5 recent transactions
    return TransactionList(
      title: l10n.home_recentActivity,
      onViewAllTap: () => unawaited(context.push('/transactions')),
      transactions: txState.transactions
          .take(5)
          .map(
            (tx) => TransactionRow(
              title: _getTransactionTitle(l10n, tx),
              subtitle: _getTransactionSubtitle(l10n, tx),
              amount: tx.amount,
              currencyCode: tx.currency,
              date: tx.createdAt,
              type: _mapTransactionType(tx),
              onTap: () =>
                  unawaited(context.push('/transactions/${tx.id}', extra: tx)),
            ),
          )
          .toList(),
    );
  }

  Widget _buildEmptyTransactions(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) => AppCard(
    borderRadius: AppRadius.lg,
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.textTertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: colors.textTertiary,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppText(
            l10n.home_noTransactionsYet,
            variant: AppTextVariant.titleMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            l10n.home_transactionsWillAppear,
            variant: AppTextVariant.bodySmall,
            color: colors.textTertiary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Future<void> _autoCreateWallet(WidgetRef ref) async {
    if (_isCreatingWallet) {
      return;
    }
    _isCreatingWallet = true;

    try {
      await ref.read(walletStateMachineProvider.notifier).createWallet();
    } on Object catch (error, stackTrace) {
      _logger.error('Auto wallet creation failed', error, stackTrace);
    } finally {
      _isCreatingWallet = false;
    }
  }

  Future<void> _refreshHomeData() async {
    await Future.wait<void>([
      _refreshWalletForHome(),
      _refreshTransactionsForHome(),
    ]).timeout(
      const Duration(seconds: 17),
      onTimeout: () {
        _logger.warn('Home refresh timed out before every source completed');
        return const <void>[];
      },
    );
  }

  Future<void> _refreshWalletForHome() async {
    try {
      await ref
          .read(walletStateMachineProvider.notifier)
          .refresh()
          .timeout(const Duration(seconds: 15));
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Wallet refresh did not complete cleanly',
        error,
        stackTrace,
      );
    }

    final wallet = ref.read(walletStateMachineProvider);
    if (wallet.status == WalletStatus.initial ||
        (wallet.status == WalletStatus.refreshing && !wallet.hasBalanceData) ||
        (wallet.status == WalletStatus.error && !wallet.hasBalanceData)) {
      try {
        await ref
            .read(walletStateMachineProvider.notifier)
            .fetch(force: true)
            .timeout(const Duration(seconds: 7));
      } on Object catch (error, stackTrace) {
        _logger.error(
          'Home refresh recovery fetch timed out or failed',
          error,
          stackTrace,
        );
      }
    }
  }

  Future<void> _refreshTransactionsForHome() async {
    try {
      await ref
          .read(transactionStateMachineProvider.notifier)
          .refresh(refreshWallet: false)
          .timeout(const Duration(seconds: 11));
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Home transaction refresh did not complete cleanly',
        error,
        stackTrace,
      );
    }
  }

  void _ensureWalletLoadScheduled(WalletState walletState) {
    if (_walletFetchScheduled ||
        walletState.status == WalletStatus.loading ||
        walletState.status == WalletStatus.refreshing ||
        (walletState.status == WalletStatus.loaded && walletState.hasWallet)) {
      return;
    }

    if (walletState.status != WalletStatus.initial &&
        !(walletState.status == WalletStatus.error &&
            !walletState.hasBalanceData)) {
      return;
    }

    _walletFetchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _walletFetchScheduled = false;
      if (!mounted) {
        return;
      }

      final current = ref.read(walletStateMachineProvider);
      if (current.status == WalletStatus.initial ||
          (current.status == WalletStatus.error && !current.hasBalanceData)) {
        unawaited(
          ref
              .read(walletStateMachineProvider.notifier)
              .fetch(force: current.status == WalletStatus.error),
        );
      }
    });
  }

  String _getTransactionTitle(AppLocalizations l10n, Transaction transaction) {
    final description = transaction.description?.trim();
    final typeLabel = _getTransactionTypeLabel(l10n, transaction.type);

    if (description != null &&
        description.isNotEmpty &&
        description.toLowerCase() != typeLabel.toLowerCase()) {
      return description;
    }

    return typeLabel;
  }

  String _getTransactionSubtitle(
    AppLocalizations l10n,
    Transaction transaction,
  ) {
    switch (transaction.type) {
      case TransactionType.deposit:
        return l10n.transactions_mobileMoneyDeposit;
      case TransactionType.withdrawal:
        return l10n.transactions_mobileMoneyWithdrawal;
      case TransactionType.transferInternal:
        return transaction.isCredit
            ? l10n.transactions_fromKoridoUser
            : l10n.transactions_transferSent;
      case TransactionType.transferExternal:
        return l10n.transactions_externalWallet;
    }
  }

  String _getTransactionTypeLabel(AppLocalizations l10n, TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return l10n.transactions_deposit;
      case TransactionType.withdrawal:
        return l10n.transactions_withdrawal;
      case TransactionType.transferInternal:
        return l10n.transactions_transferReceived;
      case TransactionType.transferExternal:
        return l10n.transactions_transferSent;
    }
  }

  TransactionDisplayType _mapTransactionType(Transaction transaction) {
    switch (transaction.type) {
      case TransactionType.deposit:
        return TransactionDisplayType.deposit;
      case TransactionType.withdrawal:
        return TransactionDisplayType.withdrawal;
      case TransactionType.transferInternal:
        return transaction.isCredit
            ? TransactionDisplayType.transferIn
            : TransactionDisplayType.transferOut;
      case TransactionType.transferExternal:
        return TransactionDisplayType.transferOut;
    }
  }
}
