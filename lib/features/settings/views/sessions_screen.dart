import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/sessions_provider.dart';
import '../models/session.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  @override
  void initState() {
    super.initState();
    // Load sessions on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionsProvider.notifier).loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          l10n.settings_activeSessions,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildBody(context, l10n, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, SessionsState state) {
    if (state.isLoading && state.sessions.isEmpty) {
      return _buildLoading();
    }

    if (state.error != null && state.sessions.isEmpty) {
      return _buildError(l10n, state.error!);
    }

    if (state.sessions.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(sessionsProvider.notifier).loadSessions(),
      color: AppColors.gold500,
      backgroundColor: AppColors.slate,
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: state.sessions.length,
              separatorBuilder: (context, index) => SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final session = state.sessions[index];
                final isCurrentSession = session.id == state.currentSessionId;
                return _buildSessionCard(context, l10n, session, isCurrentSession);
              },
            ),
          ),
          if (state.sessions.length > 1) _buildLogoutAllButton(context, l10n),
        ],
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    AppLocalizations l10n,
    Session session,
    bool isCurrentSession,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy • HH:mm');

    return AppCard(
      variant: isCurrentSession ? AppCardVariant.goldAccent : AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with device and current badge
          Row(
            children: [
              Icon(
                _getDeviceIcon(session.deviceDescription),
                color: isCurrentSession ? AppColors.gold500 : AppColors.textSecondary,
                size: 24,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      session.deviceDescription,
                      variant: AppTextVariant.titleMedium,
                      fontWeight: FontWeight.w600,
                    ),
                    if (isCurrentSession) ...[
                      SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold500.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.gold500, width: 1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: AppText(
                          l10n.sessions_currentSession,
                          variant: AppTextVariant.labelSmall,
                          color: AppColors.gold500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isCurrentSession)
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.errorBase, size: 20),
                  onPressed: () => _showRevokeDialog(context, l10n, session),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Location and IP
          _buildInfoRow(
            Icons.location_on_outlined,
            session.location ?? l10n.sessions_unknownLocation,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            Icons.public,
            session.ipAddress ?? l10n.sessions_unknownIP,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            Icons.access_time,
            '${l10n.sessions_lastActive}: ${dateFormat.format(session.lastActivityAt)}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppText(
            text,
            variant: AppTextVariant.bodySmall,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  IconData _getDeviceIcon(String description) {
    final lower = description.toLowerCase();
    if (lower.contains('iphone') || lower.contains('android')) {
      return Icons.smartphone;
    }
    if (lower.contains('ipad') || lower.contains('tablet')) {
      return Icons.tablet_mac;
    }
    return Icons.computer;
  }

  Widget _buildLogoutAllButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.slate,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: AppButton(
        label: l10n.sessions_logoutAllDevices,
        onPressed: () => _showLogoutAllDialog(context, l10n),
        variant: AppButtonVariant.danger,
        isFullWidth: true,
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold500),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.errorBase),
            SizedBox(height: AppSpacing.md),
            AppText(
              l10n.sessions_errorLoading,
              variant: AppTextVariant.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              error,
              variant: AppTextVariant.bodySmall,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.action_retry,
              onPressed: () => ref.read(sessionsProvider.notifier).loadSessions(),
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_other, size: 64, color: AppColors.textSecondary),
            SizedBox(height: AppSpacing.md),
            AppText(
              l10n.sessions_noActiveSessions,
              variant: AppTextVariant.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.sessions_noActiveSessionsDesc,
              variant: AppTextVariant.bodySmall,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRevokeDialog(
    BuildContext context,
    AppLocalizations l10n,
    Session session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: AppText(
          l10n.sessions_revokeTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        content: AppText(
          l10n.sessions_revokeMessage,
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        actions: [
          AppButton(
            label: l10n.action_cancel,
            onPressed: () => Navigator.pop(context, false),
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.small,
          ),
          AppButton(
            label: l10n.sessions_revoke,
            onPressed: () => Navigator.pop(context, true),
            variant: AppButtonVariant.danger,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final success = await ref.read(sessionsProvider.notifier).revokeSession(session.id);
    if (!success || !mounted) return;

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(l10n.sessions_revokeSuccess),
        backgroundColor: AppColors.successBase,
      ),
    );
  }

  Future<void> _showLogoutAllDialog(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: AppText(
          l10n.sessions_logoutAllTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              l10n.sessions_logoutAllMessage,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.errorBase.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.errorBase, width: 1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.errorBase, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppText(
                      l10n.sessions_logoutAllWarning,
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.errorBase,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          AppButton(
            label: l10n.action_cancel,
            onPressed: () => Navigator.pop(context, false),
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.small,
          ),
          AppButton(
            label: l10n.sessions_logoutAll,
            onPressed: () => Navigator.pop(context, true),
            variant: AppButtonVariant.danger,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final success = await ref.read(sessionsProvider.notifier).logoutAllDevices();
    if (!success || !mounted) return;

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(l10n.sessions_logoutAllSuccess),
        backgroundColor: AppColors.successBase,
      ),
    );
    // Navigate back or to login
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }
}
