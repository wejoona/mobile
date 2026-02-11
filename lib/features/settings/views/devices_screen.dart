import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/dialogs/index.dart';
import 'package:usdc_wallet/features/settings/providers/devices_provider.dart';
import 'package:usdc_wallet/features/settings/models/device.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(devicesProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.settings_devices,
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold500),
          onPressed: () => context.safePop(fallbackRoute: '/settings/security'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(deviceActionsProvider).refresh(),
        color: AppColors.gold500,
        backgroundColor: AppColors.slate,
        child: _buildBody(context, ref, state, l10n),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DevicesState state,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && state.devices.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.gold500,
        ),
      );
    }

    if (state.error != null && state.devices.isEmpty) {
      return _buildErrorState(context, ref, state.error!, l10n);
    }

    if (state.devices.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        // Info card
        _buildInfoCard(l10n),
        SizedBox(height: AppSpacing.xl),

        // Devices list
        ...state.devices.map((device) {
          final isCurrentDevice =
              ref.read(deviceActionsProvider).isCurrentDevice(device);
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildDeviceCard(
              context,
              ref,
              device,
              isCurrentDevice,
              l10n,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInfoCard(AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.goldAccent,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gold500.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.gold500,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              l10n.settings_devicesDescription,
              variant: AppTextVariant.bodySmall,
              color: AppColors.textSecondary,
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
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  _getPlatformIcon(device.platform),
                  color: AppColors.gold500,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpacing.md),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentDevice) ...[
                          SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: EdgeInsets.symmetric(
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
                    SizedBox(height: AppSpacing.xxs),
                    AppText(
                      device.osDisplay,
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              if (device.isTrusted)
                const Icon(
                  Icons.verified,
                  color: AppColors.successBase,
                  size: 20,
                ),
            ],
          ),

          SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.borderSubtle, height: 1),
          SizedBox(height: AppSpacing.md),

          // Details
          _buildDetailRow(
            Icons.schedule,
            l10n.settings_lastActive,
            _formatLastLogin(device.lastLoginAt),
          ),
          SizedBox(height: AppSpacing.sm),
          _buildDetailRow(
            Icons.login,
            l10n.settings_loginCount,
            '${device.loginCount} ${l10n.settings_times}',
          ),
          if (device.lastIpAddress != null) ...[
            SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              Icons.location_on_outlined,
              l10n.settings_lastIp,
              device.lastIpAddress!,
            ),
          ],

          // Actions
          if (!isCurrentDevice) ...[
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                if (!device.isTrusted)
                  Expanded(
                    child: AppButton(
                      label: l10n.settings_trustDevice,
                      onPressed: () => _handleTrustDevice(context, ref, device, l10n),
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.small,
                    ),
                  ),
                if (!device.isTrusted && !isCurrentDevice)
                  SizedBox(width: AppSpacing.sm),
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
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        SizedBox(width: AppSpacing.sm),
        AppText(
          label,
          variant: AppTextVariant.bodySmall,
          color: AppColors.textSecondary,
        ),
        const Spacer(),
        AppText(
          value,
          variant: AppTextVariant.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.elevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.devices_other,
                size: 60,
                color: AppColors.textTertiary,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            AppText(
              l10n.settings_noDevices,
              variant: AppTextVariant.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.settings_noDevicesDescription,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
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
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.errorBase,
            ),
            SizedBox(height: AppSpacing.xl),
            AppText(
              l10n.error_generic,
              variant: AppTextVariant.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.action_retry,
              onPressed: () => ref.read(deviceActionsProvider).refresh(),
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
    AppLocalizations l10n,
  ) async {
    try {
      await ref.read(deviceActionsProvider).trustDevice(device.id);

      if (context.mounted) {
        await context.showSuccessAlert(
          title: l10n.action_done,
          message: l10n.settings_deviceTrustedSuccess,
        );
      }
    } catch (e) {
      if (context.mounted) {
        await context.showErrorAlert(
          title: l10n.common_error,
          message: l10n.settings_deviceTrustError,
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
    final confirmed = await context.showDeleteConfirmation(
      title: l10n.settings_removeDevice,
      message: l10n.settings_removeDeviceConfirm,
      confirmText: l10n.action_remove,
    );

    if (confirmed) {
      try {
        await ref.read(deviceActionsProvider).revokeDevice(device.id);

        if (context.mounted) {
          await context.showSuccessAlert(
            title: l10n.action_done,
            message: l10n.settings_deviceRemovedSuccess,
          );
        }
      } catch (e) {
        if (context.mounted) {
          await context.showErrorAlert(
            title: l10n.common_error,
            message: l10n.settings_deviceRemoveError,
          );
        }
      }
    }
  }
}
