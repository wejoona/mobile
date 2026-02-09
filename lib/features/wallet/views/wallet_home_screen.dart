import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/components/composed/index.dart';
import '../../../design/utils/responsive_layout.dart';
import '../../../core/orientation/orientation_helper.dart';
import '../../../domain/enums/index.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/index.dart';
import '../../../services/currency/currency_provider.dart';
import '../../../services/api/api_client.dart';
import '../../limits/providers/limits_provider.dart';
import '../../limits/widgets/limit_warning_banner.dart';
import '../../../design/components/primitives/offline_banner.dart';

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

    // Debug: log wallet state on build
    print('[WalletHomeScreen] BUILD: status=${walletState.status}, walletId="${walletState.walletId}", isLoading=${walletState.isLoading}, usdcBalance=${walletState.usdcBalance}');

    // Trigger balance animation when loaded
    if (walletState.status == WalletStatus.loaded &&
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
            await ref.read(transactionStateMachineProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedContent(
              child: Padding(
                padding: OrientationHelper.padding(
                  context,
                  portrait: ResponsiveLayout.padding(
                    context,
                    mobile: const EdgeInsets.all(AppSpacing.screenPadding),
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
                    ? _buildLandscapeLayout(context, ref, walletState, txState, userName, l10n, colors)
                    : ResponsiveBuilder(
                        mobile: _buildMobileLayout(context, ref, walletState, txState, userName, l10n, colors),
                        tablet: _buildTabletLayout(context, ref, walletState, txState, userName, l10n, colors),
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

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    String userName,
    ThemeColors colors,
  ) {
    final userState = ref.watch(userStateMachineProvider);

    // Format display name - if it's a phone number, just show greeting
    final isPhoneNumber = userName.startsWith('+') ||
                          RegExp(r'^\d+$').hasMatch(userName);
    final displayName = isPhoneNumber ? null : userName;
    final greeting = _getGreeting(l10n);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar and greeting
        Expanded(
          child: Row(
            children: [
              UserAvatar(
                imageUrl: null, // TODO: Add profile image URL when available
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
                    AppText(
                      greeting,
                      variant: AppTextVariant.bodyMedium,
                      color: colors.textSecondary,
                    ),
                    if (displayName != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        displayName,
                        variant: AppTextVariant.headlineSmall,
                        color: colors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Action icons
        Row(
          children: [
            IconButton(
              onPressed: () => context.push('/notifications'),
              icon: Icon(
                Icons.notifications_outlined,
                color: colors.textSecondary,
              ),
              tooltip: l10n.settings_notifications,
            ),
            IconButton(
              onPressed: () => context.go('/settings'),
              icon: Icon(
                Icons.settings_outlined,
                color: colors.textSecondary,
              ),
              tooltip: 'Settings',
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
      return _buildCreateWalletCard(context, ref, l10n, colors);
    }

    // Primary balance is USDC
    final primaryBalance = walletState.usdcBalance;

    // Get reference currency display if enabled
    final currencyState = ref.watch(currencyProvider);
    String? referenceAmount;
    if (currencyState.shouldShowReference && !walletState.isLoading) {
      referenceAmount = ref.read(currencyProvider.notifier).getFormattedReference(
        primaryBalance,
      );
    }

    // Get theme-aware gradient
    final cardGradient = context.colors.isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2A2520), // Dark gold-brown
              const Color(0xFF1F1D1A), // Darker gold-brown
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFF9E6), // Light cream-gold
              const Color(0xFFFFF3D6), // Slightly darker cream-gold
            ],
          );

    // Get theme-aware shadow
    final cardShadow = context.colors.isDark
        ? [
            BoxShadow(
              color: colors.gold.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ]
        : [
            BoxShadow(
              color: colors.gold.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.borderGold.withValues(alpha: context.colors.isDark ? 0.4 : 0.5),
          width: 1.5,
        ),
        boxShadow: cardShadow,
      ),
      child: Stack(
        children: [
          // Decorative pattern overlay (subtle)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: CustomPaint(
                painter: _CardPatternPainter(
                  isDark: context.colors.isDark,
                  color: colors.gold.withValues(alpha: context.colors.isDark ? 0.03 : 0.04),
                ),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
            child: Column(
          children: [
            // Header with label and hide/show toggle
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: colors.gold,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                AppText(
                  l10n.home_totalBalance,
                  variant: AppTextVariant.bodyMedium,
                  color: context.colors.isDark
                      ? colors.textSecondary
                      : colors.textSecondary.withValues(alpha: 0.9),
                ),
                const Spacer(),
                // Hide/Show balance toggle
                IconButton(
                  onPressed: _toggleBalanceVisibility,
                  icon: Icon(
                    _isBalanceHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: context.colors.isDark
                        ? colors.textTertiary
                        : colors.textSecondary,
                    size: 20,
                  ),
                  tooltip: _isBalanceHidden
                      ? l10n.home_showBalance
                      : l10n.home_hideBalance,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: AppSpacing.xs),
                // Subtle USDC badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.isDark
                        ? colors.gold.withValues(alpha: 0.2)
                        : colors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: AppText(
                    'USDC',
                    variant: AppTextVariant.labelSmall,
                    color: context.colors.isDark
                        ? colors.gold
                        : AppColorsLight.gold700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Primary Balance - CENTERED, ANIMATED
            if (walletState.isLoading)
              const SizedBox(
                height: 56,
                child: Center(
                  child: AppSkeleton(
                    width: 200,
                    height: 48,
                  ),
                ),
              )
            else ...[
              Center(
                child: _isBalanceHidden
                    ? _buildHiddenBalance(context, colors)
                    : AnimatedBuilder(
                        animation: _balanceAnimation,
                        builder: (context, child) {
                          final animatedValue = primaryBalance * _balanceAnimation.value;
                          final balanceText = '\$${_formatBalanceCompact(animatedValue)}';
                          final isDark = context.colors.isDark;

                          // Same widget for both modes, just different gradient colors
                          final gradientColors = isDark
                              ? [AppColors.gold300, AppColors.gold500, AppColors.gold400]
                              : [AppColorsLight.gold600, AppColorsLight.gold700, AppColorsLight.gold600];

                          return FadeTransition(
                            opacity: _balanceAnimation,
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradientColors,
                              ).createShader(bounds),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: AppText(
                                  balanceText,
                                  variant: AppTextVariant.displayLarge,
                                  color: AppColors.white, // Required for ShaderMask
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Reference currency (informative only)
              if (!_isBalanceHidden &&
                  referenceAmount != null &&
                  referenceAmount.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: (context.colors.isDark
                              ? colors.gold
                              : AppColorsLight.gold600)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: (context.colors.isDark
                                ? colors.gold
                                : AppColorsLight.gold600)
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.currency_exchange_rounded,
                          size: 14,
                          color: context.colors.isDark
                              ? colors.gold.withValues(alpha: 0.7)
                              : AppColorsLight.gold700,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        AppText(
                          '\u2248 $referenceAmount',
                          variant: AppTextVariant.labelMedium,
                          color: context.colors.isDark
                              ? colors.textSecondary
                              : colors.textPrimary.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              // Pending balance indicator
              if (!_isBalanceHidden && walletState.pendingBalance > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: colors.warningText,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      AppText(
                        '+\$${_formatBalance(walletState.pendingBalance)} pending',
                        variant: AppTextVariant.bodySmall,
                        color: colors.warningText,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
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
        _buildHeader(context, l10n, userName, colors),
        const SizedBox(height: AppSpacing.xxl),
        _buildBalanceCard(context, ref, walletState, l10n, colors),
        const SizedBox(height: AppSpacing.xxl),
        _buildQuickActions(context, l10n, colors),
        const SizedBox(height: AppSpacing.xxl),
        _buildKycBanner(context, ref, l10n, colors),
        _buildLimitsWarningBanner(context, ref, l10n),
        _buildTransactionList(context, txState, l10n, colors),
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
                children: [
                  _buildQuickActionsGrid(context, l10n, colors),
                ],
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
      _QuickActionData(Icons.qr_code_2_rounded, l10n.home_quickAction_receive, '/receive'),
      _QuickActionData(Icons.add_circle_outline_rounded, l10n.home_quickAction_deposit, '/deposit'),
      _QuickActionData(Icons.history_rounded, l10n.home_quickAction_history, '/transactions'),
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

    // Don't show banner if already verified
    if (kycStatus == KycStatus.verified) {
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
    if (!limits.isDailyNearLimit && !limits.isDailyAtLimit &&
        !limits.isMonthlyNearLimit && !limits.isMonthlyAtLimit) {
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
      return const TransactionList(
        transactions: [],
        isLoading: true,
      );
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
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.borderSubtle),
        ),
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
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colors.gold,
            strokeWidth: 2,
          ),
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

  Widget _buildCreateWalletCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.gold,
                  colors.gold.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: colors.textInverse,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppText(
            l10n.wallet_activateTitle,
            variant: AppTextVariant.titleLarge,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            l10n.wallet_activateDescription,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.wallet_activateButton,
            onPressed: () => _activateWallet(context, ref, l10n, colors),
            variant: AppButtonVariant.primary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Future<void> _activateWallet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeColors colors,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.container,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: colors.gold,
              strokeWidth: 2,
            ),
            const SizedBox(width: AppSpacing.lg),
            Flexible(
              child: AppText(
                l10n.wallet_activating,
                variant: AppTextVariant.bodyMedium,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // Call wallet creation endpoint
      final dio = ref.read(dioProvider);
      await dio.post('/wallet/create');

      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      // Refresh wallet state
      await ref.read(walletStateMachineProvider.notifier).fetch();
    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(
              l10n.wallet_activateFailed,
              color: AppColors.textInverse,
            ),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  Widget _buildErrorCard(
    BuildContext context,
    String error,
    AppLocalizations l10n,
    ThemeColors colors, {
    VoidCallback? onRetry,
  }) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: colors.error,
              size: 48,
            ),
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
    final isDark = context.colors.isDark;

    // Use same gradient as the balance for consistency
    final gradientColors = isDark
        ? [AppColors.gold300, AppColors.gold500, AppColors.gold400]
        : [AppColorsLight.gold600, AppColorsLight.gold700, AppColorsLight.gold600];

    // Compact hidden indicator
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ).createShader(bounds),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_off_rounded,
            size: 40,
            color: AppColors.white,
          ),
          const SizedBox(width: AppSpacing.md),
          AppText(
            '******',
            variant: AppTextVariant.displayLarge,
            color: AppColors.white,
          ),
        ],
      ),
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
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.transferInternal:
        return 'Transfer Received';
      case TransactionType.transferExternal:
        return 'Transfer Sent';
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark
                ? colors.borderSubtle
                : AppColorsLight.gold600.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.1)
                  : AppColorsLight.gold700.withValues(alpha: 0.08),
              blurRadius: isDark ? 10 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          colors.gold.withValues(alpha: 0.25),
                          colors.gold.withValues(alpha: 0.15),
                        ]
                      : [
                          colors.gold.withValues(alpha: 0.15),
                          colors.gold.withValues(alpha: 0.08),
                        ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: colors.gold.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isDark ? colors.gold : AppColorsLight.gold700,
                size: 24,
              ),
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

/// Custom painter for the decorative pattern on the balance card
class _CardPatternPainter extends CustomPainter {
  final bool isDark;
  final Color color;

  _CardPatternPainter({
    required this.isDark,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw subtle geometric pattern
    final spacing = 40.0;
    final offset = isDark ? 20.0 : 15.0;

    // Diagonal lines from top-right
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Add circular elements in corners
    final circlePaint = Paint()
      ..color = color.withValues(alpha: color.a * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Top-right corner circles
    canvas.drawCircle(
      Offset(size.width - offset, offset),
      30,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width - offset, offset),
      50,
      circlePaint.copyWith(alpha: color.a * 0.3),
    );

    // Bottom-left corner circles
    canvas.drawCircle(
      Offset(offset, size.height - offset),
      25,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(offset, size.height - offset),
      45,
      circlePaint.copyWith(alpha: color.a * 0.3),
    );
  }

  @override
  bool shouldRepaint(_CardPatternPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.color != color;
  }
}

extension _PaintCopyWith on Paint {
  Paint copyWith({double? alpha}) {
    return Paint()
      ..color = alpha != null ? color.withValues(alpha: alpha) : color
      ..style = style
      ..strokeWidth = strokeWidth;
  }
}
