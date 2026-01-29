import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/devices_provider.dart';
import '../models/device.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(devicesProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.settings_devices,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(devicesProvider.notifier).refresh(),
        color: colors.gold,
        backgroundColor: colors.container,
        child: _buildBody(context, ref, state, colors, l10n),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DevicesState state,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && state.devices.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.devices.isEmpty) {
      return _buildErrorState(context, ref, state.error!, colors, l10n);
    }

    if (state.devices.isEmpty) {
      return _buildEmptyState(colors, l10n);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        // Info card
        _buildInfoCard(colors, l10n),
        const SizedBox(height: AppSpacing.xl),

        // Devices list
        ...state.devices.map((device) {
          final isCurrentDevice =
              ref.read(devicesProvider.notifier).isCurrentDevice(device);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildDeviceCard(
              context,
              ref,
              device,
              isCurrentDevice,
              colors,
              l10n,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInfoCard(ThemeColors colors, AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.goldAccent,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.info_outline,
              color: colors.gold,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              l10n.settings_devicesDescription,
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context,
    WidgetRef ref,
    Device device,
    bool isCurrentDevice,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon, Name, Badge
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  _getPlatformIcon(device.platform),
                  color: colors.gold,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: AppText(
                            device.displayName,
                            variant: AppTextVariant.labelLarge,
                            color: colors.textPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentDevice) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successBase.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: AppText(
                              l10n.settings_thisDevice,
                              variant: AppTextVariant.labelSmall,
                              color: AppColors.successBase,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      device.osDisplay,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              if (device.isTrusted)
                Icon(
                  Icons.verified,
                  color: AppColors.successBase,
                  size: 20,
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.borderSubtle, height: 1),
          const SizedBox(height: AppSpacing.md),

          // Details
          _buildDetailRow(
            colors,
            Icons.schedule,
            l10n.settings_lastActive,
            _formatLastLogin(device.lastLoginAt),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildDetailRow(
            colors,
            Icons.login,
            l10n.settings_loginCount,
            '${device.loginCount} ${l10n.settings_times}',
          ),
          if (device.lastIpAddress != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              colors,
              Icons.location_on_outlined,
              l10n.settings_lastIp,
              device.lastIpAddress!,
            ),
          ],

          // Actions
          if (!isCurrentDevice) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                if (!device.isTrusted)
                  Expanded(
                    child: AppButton(
                      label: l10n.settings_trustDevice,
                      onPressed: () => _handleTrustDevice(context, ref, device),
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.small,
                    ),
                  ),
                if (!device.isTrusted && !isCurrentDevice)
                  const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: l10n.settings_removeDevice,
                    onPressed: () => _handleRevokeDevice(context, ref, device, l10n),
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.small,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeColors colors,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.textTertiary),
        const SizedBox(width: AppSpacing.sm),
        AppText(
          label,
          variant: AppTextVariant.bodySmall,
          color: colors.textSecondary,
        ),
        const Spacer(),
        AppText(
          value,
          variant: AppTextVariant.bodySmall,
          color: colors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeColors colors, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colors.elevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.devices_other,
                size: 60,
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppText(
              l10n.settings_noDevices,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.settings_noDevicesDescription,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    String error,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.errorBase,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppText(
              l10n.error_generic,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.action_retry,
              onPressed: () => ref.read(devicesProvider.notifier).refresh(),
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String? platform) {
    switch (platform?.toLowerCase()) {
      case 'ios':
        return Icons.phone_iphone;
      case 'android':
        return Icons.smartphone;
      case 'web':
        return Icons.computer;
      default:
        return Icons.devices;
    }
  }

  String _formatLastLogin(DateTime? lastLogin) {
    if (lastLogin == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(lastLogin);
    }
  }

  Future<void> _handleTrustDevice(
    BuildContext context,
    WidgetRef ref,
    Device device,
  ) async {
    try {
      await ref.read(devicesProvider.notifier).trustDevice(device.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device trusted successfully'),
            backgroundColor: AppColors.successBase,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to trust device: ${e.toString()}'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    }
  }

  Future<void> _handleRevokeDevice(
    BuildContext context,
    WidgetRef ref,
    Device device,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.colors;
        return AlertDialog(
          backgroundColor: colors.container,
          title: AppText(
            l10n.settings_removeDevice,
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          content: AppText(
            l10n.settings_removeDeviceConfirm,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: AppText(
                l10n.action_cancel,
                variant: AppTextVariant.labelLarge,
                color: colors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: AppText(
                l10n.action_remove,
                variant: AppTextVariant.labelLarge,
                color: AppColors.errorBase,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await ref.read(devicesProvider.notifier).revokeDevice(device.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Device removed successfully'),
              backgroundColor: AppColors.successBase,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove device: ${e.toString()}'),
              backgroundColor: AppColors.errorBase,
            ),
          );
        }
      }
    }
  }
}
