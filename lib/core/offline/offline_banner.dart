import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/services/connectivity/connectivity_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Offline Banner Widget
/// Shows connectivity status at the top of the screen
/// Displays:
/// - Offline indicator when no connection
/// - Syncing indicator when processing pending operations
/// - Success message when reconnected
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // ignore: unused_field
  late Animation<double> _animation;
  bool _wasOffline = false;
  bool _showReconnectedMessage = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
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
    final colors = context.colors;
    final state = ref.watch(connectivityProvider);

    // Track offline -> online transition
    if (_wasOffline && state.isOnline && !_showReconnectedMessage) {
      _showReconnectedMessage = true;
      _controller.forward();

      // Hide success message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showReconnectedMessage = false;
          });
          _controller.reverse();
        }
      });
    }
    _wasOffline = !state.isOnline;

    // Show banner if offline, processing, or showing reconnected message
    final shouldShow = !state.isOnline ||
                       state.isProcessingQueue ||
                       _showReconnectedMessage;

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    final bannerColor = _getBannerColor(colors, state, _showReconnectedMessage);
    final onBanner = _bannerForeground(colors);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bannerColor,
          boxShadow: [
            BoxShadow(
              color: colors.scrim.withValues(alpha: colors.isDark ? 0.35 : 0.18),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              _buildIcon(state, _showReconnectedMessage, onBanner),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildContent(
                  l10n,
                  state,
                  _showReconnectedMessage,
                  onBanner,
                ),
              ),
              if (state.pendingCount > 0 && !state.isProcessingQueue)
                _buildPendingBadge(state.pendingCount, onBanner),
            ],
          ),
        ),
      ),
    );
  }

  /// Get banner background color based on state
  Color _getBannerColor(
    ThemeColors colors,
    ConnectivityState state,
    bool showReconnected,
  ) {
    if (showReconnected) {
      return colors.success;
    } else if (state.isProcessingQueue) {
      return colors.info;
    } else {
      return colors.warning;
    }
  }

  Color _bannerForeground(ThemeColors colors) => colors.textInverse;

  /// Build status icon
  Widget _buildIcon(
    ConnectivityState state,
    bool showReconnected,
    Color foreground,
  ) {
    IconData icon;

    if (showReconnected) {
      icon = Icons.check_circle;
    } else if (state.isProcessingQueue) {
      icon = Icons.sync;
    } else {
      icon = Icons.cloud_off;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Icon(
        icon,
        key: ValueKey(icon),
        color: foreground,
        size: 20,
      ),
    );
  }

  /// Build banner content
  Widget _buildContent(
    AppLocalizations l10n,
    ConnectivityState state,
    bool showReconnected,
    Color foreground,
  ) {
    if (showReconnected) {
      return _buildReconnectedContent(l10n, state, foreground);
    } else if (state.isProcessingQueue) {
      return _buildSyncingContent(l10n, state, foreground);
    } else {
      return _buildOfflineContent(l10n, state, foreground);
    }
  }

  /// Build offline content
  Widget _buildOfflineContent(
    AppLocalizations l10n,
    ConnectivityState state,
    Color foreground,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.offline_banner_title,
          style: TextStyle(
            color: foreground,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        if (state.lastSync != null) ...[
          SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.offline_banner_last_sync(
              timeago.format(state.lastSync!, locale: 'en_short'),
            ),
            style: TextStyle(
              color: foreground.withValues(alpha: 0.9),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  /// Build syncing content
  Widget _buildSyncingContent(
    AppLocalizations l10n,
    ConnectivityState state,
    Color foreground,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.offline_banner_syncing,
          style: TextStyle(
            color: foreground,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        SizedBox(
          height: 2,
          child: LinearProgressIndicator(
            backgroundColor: foreground.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(foreground),
          ),
        ),
      ],
    );
  }

  /// Build reconnected content
  Widget _buildReconnectedContent(
    AppLocalizations l10n,
    ConnectivityState state,
    Color foreground,
  ) {
    return Text(
      l10n.offline_banner_reconnected,
      style: TextStyle(
        color: foreground,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
    );
  }

  /// Build pending operations badge
  Widget _buildPendingBadge(int count, Color foreground) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Minimal Offline Indicator (for compact layouts)
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isOnline = ref.watch(isOnlineProvider);

    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.warningBg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: colors.warning,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 12,
            color: colors.warningText,
          ),
          SizedBox(width: AppSpacing.xxs),
          Text(
            'Offline',
            style: TextStyle(
              color: colors.warningText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Offline Badge (for cards and list items)
class OfflineBadge extends StatelessWidget {
  const OfflineBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.warningBg,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 10,
            color: colors.warningText,
          ),
          SizedBox(width: AppSpacing.xxs),
          Text(
            'Queued',
            style: TextStyle(
              color: colors.warningText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}