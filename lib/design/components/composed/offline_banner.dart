import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/services/connectivity/connectivity_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Offline Banner Widget
/// Shows connection status and pending transfers count
/// Auto-dismissible but reappears on navigation when offline
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner>
    with SingleTickerProviderStateMixin {
  bool _isDismissed = false;
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final connectivityState = ref.watch(connectivityProvider);

    // Reset dismissal when going from online to offline
    ref.listen<ConnectivityState>(connectivityProvider, (previous, next) {
      if (previous?.isOnline == true && next.isOnline == false) {
        setState(() => _isDismissed = false);
      }
    });

    // Don't show if online or dismissed
    if (connectivityState.isOnline || _isDismissed) {
      return const SizedBox.shrink();
    }

    // Show banner with animation
    _controller.forward();

    return SizeTransition(
      sizeFactor: _heightAnimation,
      child: _buildBanner(context, l10n, connectivityState),
    );
  }

  Widget _buildBanner(
    BuildContext context,
    AppLocalizations l10n,
    ConnectivityState state,
  ) {
    final hasPending = state.pendingCount > 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.15),
        border: Border(
          bottom: BorderSide(
            color: AppColors.warning.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Icon(
            Icons.cloud_off_outlined,
            size: 18,
            color: AppColors.warning,
          ),
          SizedBox(width: AppSpacing.sm),

          // Text
          Expanded(
            child: AppText(
              hasPending
                  ? l10n.offline_youreOfflineWithPending(state.pendingCount)
                  : l10n.offline_youreOffline,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Dismiss button
          GestureDetector(
            onTap: () {
              _controller.reverse().then((_) {
                setState(() => _isDismissed = true);
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Icon(
                Icons.close,
                size: 16,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Offline Indicator
/// Shows offline status with cached data info
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(connectivityProvider);

    if (state.isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: AppColors.silver.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 14,
            color: AppColors.silver,
          ),
          SizedBox(width: AppSpacing.xs),
          AppText(
            l10n.offline_cacheData,
            style: AppTypography.caption.copyWith(
              color: AppColors.silver,
            ),
          ),
        ],
      ),
    );
  }
}

/// Syncing Indicator
/// Shows when processing offline queue
class SyncingIndicator extends ConsumerWidget {
  const SyncingIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(connectivityProvider);

    if (!state.isProcessingQueue) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold500.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: AppColors.gold500.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold500),
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          AppText(
            l10n.offline_syncing,
            style: AppTypography.caption.copyWith(
              color: AppColors.gold500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Last Sync Indicator
/// Shows time since last successful sync
class LastSyncIndicator extends ConsumerWidget {
  const LastSyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(connectivityProvider);

    if (state.lastSync == null) {
      return const SizedBox.shrink();
    }

    final timeAgo = timeago.format(state.lastSync!, locale: 'en_short');

    return AppText(
      l10n.offline_lastSynced(timeAgo),
      style: AppTypography.caption.copyWith(
        color: AppColors.silver,
      ),
    );
  }
}

/// Offline Status Badge
/// Small badge showing offline status with count
class OfflineStatusBadge extends ConsumerWidget {
  const OfflineStatusBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(connectivityProvider);

    if (state.isOnline || state.pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: AppText(
        '${state.pendingCount}',
        style: AppTypography.caption.copyWith(
          color: AppColors.obsidian,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
