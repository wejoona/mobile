import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/core/orientation/orientation_helper.dart';
import 'package:usdc_wallet/design/animations/staggered_entrance.dart';
import 'package:usdc_wallet/design/components/composed/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/primitives/offline_banner.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/utils/responsive_layout.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/limits/providers/limits_provider.dart';
import 'package:usdc_wallet/features/limits/widgets/limit_warning_banner.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/currency/currency_provider.dart';
import 'package:usdc_wallet/state/index.dart';

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
  bool _isBalanceHidden = false;
  bool _isCreatingWallet = false;
  late AnimationController _balanceAnimationController;
  late Animation<double> _balanceAnimation;
  double _displayedBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalanceVisibilityPreference();
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
    // Fetch limits on init
    Future.microtask(() => ref.read(limitsProvider.notifier).fetchLimits());
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
    HapticFeedback.lightImpact();
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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final isLandscape = OrientationHelper.isLandscape(context);

    // Trigger transaction fetch once wallet is loaded
    if (walletState.status == WalletStatus.loaded &&
        walletState.walletId.isNotEmpty) {
      final txStatus = txState.status;
      if (txStatus == TransactionListStatus.initial) {
        Future.microtask(
          () => ref.read(transactionStateMachineProvider.notifier).fetch(),
        );
      }
    }

    // Trigger balance animation when loaded
    if (walletState.status == WalletStatus.loaded &&
        !_balanceAnimationController.isAnimating &&
        _balanceAnimationController.status != AnimationStatus.completed) {
      _displayedBalance = walletState.usdcBalance;
      _balanceAnimationController.forward(from: 0);
    } else if (walletState.status == WalletStatus.loaded &&
        _displayedBalance != walletState.usdcBalance) {
      _displayedBalance = walletState.usdcBalance;
      _balanceAnimationController.forward(from: 0);
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
                onRefresh: () async {
                  await ref.read(walletStateMachineProvider.notifier).refresh();
                  await ref
                      .read(transactionStateMachineProvider.notifier)
                      .refresh();
                },
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
          onPressed: () => context.push('/notifications'),
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
                style: TextStyle(
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
                size: UserAvatar.sizeMedium,
                showBorder: true,
                borderColor: colors.gold,
                onTap: () => context.push('/settings/profile'),
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
                    AppText(
                      greeting,
                      variant: AppTextVariant.bodyMedium,
                      color: colors.textSecondary,
                    ),
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
              tooltip: AppStrings.settings,
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
      return _buildLoadingCard(context, l10n, colors);
    }

    if (walletState.hasError) {
      return _buildErrorCard(
        context,
        walletState.error ?? l10n.error_failedToLoadBalance,
        l10n,
        colors,
        onRetry: () {
          ref.read(walletStateMachineProvider.notifier).refresh();
        },
      );
    }

    // Check if wallet exists
    final hasWallet = walletState.walletId.isNotEmpty;

    if (!hasWallet && !walletState.isLoading) {
      // Auto-create wallet — no manual button needed
      _autoCreateWallet(context, ref);
      return _buildWalletCreatingState(colors);
    }

    // Primary balance is USDC
    final primaryBalance = walletState.usdcBalance;

    // Get reference currency display if enabled
    final currencyState = ref.watch(currencyProvider);
    String? referenceAmount;
    if (currencyState.shouldShowReference && !walletState.isLoading) {
      referenceAmount = ref
          .read(currencyProvider.notifier)
          .getFormattedReference(primaryBalance);
    }

    final surfaceStart = colors.isDark
        ? Color.alphaBlend(colors.gold.withValues(alpha: 0.10), colors.surface)
        : Colors.white;
    final surfaceEnd = colors.isDark
        ? colors.container
        : Color.alphaBlend(
            colors.gold.withValues(alpha: 0.05),
            colors.container,
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surfaceStart, surfaceEnd],
        ),
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
            color: Colors.black.withValues(alpha: colors.isDark ? 0.26 : 0.07),
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
                AppSpacing.xxl,
              ),
              child: Column(
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
                          l10n.home_totalBalance,
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
                          'USDC',
                          variant: AppTextVariant.labelSmall,
                          color: colors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    height: 70,
                    child: Center(
                      child: walletState.isLoading
                          ? const AppSkeleton(width: 200, height: 48)
                          : _isBalanceHidden
                          ? _buildHiddenBalance(context, colors)
                          : AnimatedBuilder(
                              animation: _balanceAnimation,
                              builder: (context, child) {
                                final animatedValue =
                                    primaryBalance * _balanceAnimation.value;
                                final balanceText =
                                    '\$${_formatBalanceCompact(animatedValue)}';
                                return FadeTransition(
                                  opacity: _balanceAnimation,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: AppText(
                                      balanceText,
                                      style: AppTypography.displayMedium,
                                      color: colors.gold,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  if (!walletState.isLoading && !_isBalanceHidden) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        if (referenceAmount != null &&
                            referenceAmount.isNotEmpty)
                          _buildBalanceInfoPill(
                            context,
                            colors,
                            icon: Icons.currency_exchange_rounded,
                            label: '≈ $referenceAmount',
                            color: colors.gold,
                          ),
                        if (walletState.pendingBalance > 0)
                          _buildBalanceInfoPill(
                            context,
                            colors,
                            icon: Icons.schedule_rounded,
                            label:
                                '+\$${_formatBalance(walletState.pendingBalance)} pending',
                            color: colors.warningText,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfoPill(
    BuildContext context,
    ThemeColors colors, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: colors.isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.withValues(alpha: 0.82)),
          const SizedBox(width: AppSpacing.xs),
          AppText(
            label,
            variant: AppTextVariant.labelMedium,
            color: colors.isDark
                ? colors.textSecondary
                : colors.textPrimary.withValues(alpha: 0.78),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    WalletState walletState,
    TransactionListState txState,
    String userName,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    return Column(
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
            child: _CachedDataChip(lastUpdated: walletState.lastUpdated!),
          ),
        const SizedBox(height: AppSpacing.xxl),
        StaggeredEntrance(
          index: 2,
          child: _buildQuickActions(context, l10n, colors),
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
  }

  Widget _buildTabletLayout(
    BuildContext context,
    WidgetRef ref,
    WalletState walletState,
    TransactionListState txState,
    String userName,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    return Column(
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
                children: [_buildQuickActionsGrid(context, l10n, colors)],
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
  }

  /// Landscape layout: Horizontal split with balance/actions on left, transactions on right
  Widget _buildLandscapeLayout(
    BuildContext context,
    WidgetRef ref,
    WalletState walletState,
    TransactionListState txState,
    String userName,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    return Column(
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
                  _buildQuickActions(context, l10n, colors),
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
  }

  Widget _buildQuickActions(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.send_rounded,
            label: l10n.home_quickAction_send,
            onTap: () => context.push('/send'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.qr_code_2_rounded,
            label: l10n.home_quickAction_receive,
            onTap: () => context.push('/receive'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_circle_outline_rounded,
            label: l10n.home_quickAction_deposit,
            onTap: () => context.push('/deposit'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.history_rounded,
            label: l10n.home_quickAction_history,
            onTap: () => context.push('/transactions'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    final actions = [
      _QuickActionData(Icons.send_rounded, l10n.home_quickAction_send, '/send'),
      _QuickActionData(
        Icons.qr_code_2_rounded,
        l10n.home_quickAction_receive,
        '/receive',
      ),
      _QuickActionData(
        Icons.add_circle_outline_rounded,
        l10n.home_quickAction_deposit,
        '/deposit',
      ),
      _QuickActionData(
        Icons.history_rounded,
        l10n.home_quickAction_history,
        '/transactions',
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: actions[0].icon,
                label: actions[0].label,
                onTap: () => context.push(actions[0].route),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionButton(
                icon: actions[1].icon,
                label: actions[1].label,
                onTap: () => context.push(actions[1].route),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: actions[2].icon,
                label: actions[2].label,
                onTap: () => context.push(actions[2].route),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionButton(
                icon: actions[3].icon,
                label: actions[3].label,
                onTap: () => context.push(actions[3].route),
              ),
            ),
          ],
        ),
      ],
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
    if (kycStatus == KycStatus.verified || kycStatus == KycStatus.submitted) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () => context.push('/kyc'),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            margin: const EdgeInsets.only(bottom: AppSpacing.xxl),
            decoration: BoxDecoration(
              color: colors.warningBase.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: colors.warningBase.withValues(alpha: 0.3),
                width: 1,
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
      return _buildErrorCard(
        context,
        txState.error ?? l10n.error_failedToLoadTransactions,
        l10n,
        colors,
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
      onViewAllTap: () => context.push('/transactions'),
      transactions: txState.transactions.take(5).map((tx) {
        return TransactionRow(
          title: _getTransactionTitle(tx.type, tx.description),
          subtitle: tx.description ?? tx.type.name,
          amount: tx.amount,
          date: tx.createdAt,
          type: _mapTransactionType(tx.type),
          onTap: () => context.push('/transactions/${tx.id}', extra: tx),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyTransactions(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    return AppCard(
      variant: AppCardVariant.flat,
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
  }

  Widget _buildLoadingCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    return AppCard(
      variant: AppCardVariant.flat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.gold, strokeWidth: 2),
          const SizedBox(height: AppSpacing.md),
          AppText(
            l10n.wallet_loadingWallet,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Future<void> _autoCreateWallet(BuildContext context, WidgetRef ref) async {
    if (_isCreatingWallet) return;
    _isCreatingWallet = true;

    try {
      final dio = ref.read(dioProvider);
      await dio.post('/wallet/create');
      await ref.read(walletStateMachineProvider.notifier).fetch();
    } catch (e) {
      debugPrint('[WalletHome] Auto wallet creation failed: $e');
    } finally {
      _isCreatingWallet = false;
    }
  }

  Widget _buildWalletCreatingState(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.gold, colors.gold.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: colors.textInverse,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          CircularProgressIndicator(color: colors.gold, strokeWidth: 2),
          const SizedBox(height: AppSpacing.lg),
          AppText(
            AppStrings.settingUpWallet,
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            AppStrings.onlyTakeAMoment,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    String error,
    AppLocalizations l10n,
    ThemeColors colors, {
    VoidCallback? onRetry,
  }) {
    return AppCard(
      variant: AppCardVariant.flat,
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: colors.error, size: 48),
            const SizedBox(height: AppSpacing.md),
            AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.action_retry,
                onPressed: onRetry,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Format balance with commas
  String _formatBalance(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }

    return '${buffer.toString()}.$decPart';
  }

  /// Build stylish hidden balance indicator - same size as balance text
  Widget _buildHiddenBalance(BuildContext context, ThemeColors colors) {
    // Compact hidden indicator
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.visibility_off_rounded, size: 32, color: colors.gold),
        const SizedBox(width: AppSpacing.md),
        AppText('******', variant: AppTextVariant.balance, color: colors.gold),
      ],
    );
  }

  /// Format balance with K/M/B notation for large amounts
  String _formatBalanceCompact(double amount) {
    if (amount < 1000) {
      return amount.toStringAsFixed(2);
    } else if (amount < 1000000) {
      final kValue = amount / 1000;
      return '${kValue.toStringAsFixed(1)}K';
    } else if (amount < 1000000000) {
      final mValue = amount / 1000000;
      return '${mValue.toStringAsFixed(1)}M';
    } else {
      final bValue = amount / 1000000000;
      return '${bValue.toStringAsFixed(1)}B';
    }
  }

  String _getTransactionTitle(TransactionType type, String? description) {
    if (description != null && description.isNotEmpty) {
      return description;
    }
    switch (type) {
      case TransactionType.deposit:
        return AppStrings.depositLabel;
      case TransactionType.withdrawal:
        return AppStrings.withdrawalLabel;
      case TransactionType.transferInternal:
        return AppStrings.transferReceived;
      case TransactionType.transferExternal:
        return AppStrings.transferSent;
    }
  }

  TransactionDisplayType _mapTransactionType(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return TransactionDisplayType.deposit;
      case TransactionType.withdrawal:
        return TransactionDisplayType.withdrawal;
      case TransactionType.transferInternal:
        return TransactionDisplayType.transferIn;
      case TransactionType.transferExternal:
        return TransactionDisplayType.transferOut;
    }
  }
}

class _QuickActionData {
  final IconData icon;
  final String label;
  final String route;

  _QuickActionData(this.icon, this.label, this.route);
}

/// Quick action button component
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.colors.isDark;

    return AppCard(
      variant: AppCardVariant.flat,
      borderRadius: AppRadius.lg,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.xs,
      ),
      child: SizedBox(
        height: 84,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: colors.gold, size: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              label,
              variant: AppTextVariant.labelSmall,
              color: isDark ? colors.textSecondary : colors.textPrimary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small chip showing cached data age
class _CachedDataChip extends StatelessWidget {
  const _CachedDataChip({required this.lastUpdated});

  final DateTime lastUpdated;

  String _timeAgo() {
    final diff = DateTime.now().difference(lastUpdated);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colors.warningBase.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 14, color: colors.warningText),
            const SizedBox(width: AppSpacing.xs),
            AppText(
              'Cached · Updated ${_timeAgo()}',
              variant: AppTextVariant.labelSmall,
              color: colors.warningText,
            ),
          ],
        ),
      ),
    );
  }
}
