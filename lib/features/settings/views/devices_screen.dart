import 'dart:io';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/components/dialogs/index.dart'
    hide AlertDialog;
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/device.dart';
import 'package:usdc_wallet/features/settings/models/devices_state.dart';
import 'package:usdc_wallet/features/settings/providers/devices_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/device_names.dart';

final _localDeviceInfoProvider = FutureProvider<Map<String, String>>((
  ref,
) async {
  final info = DeviceInfoPlugin();
  if (Platform.isIOS) {
    final ios = await info.iosInfo;
    final machine = ios.utsname.machine;
    return {
      'name': ios.name,
      'model': iosModelName(machine),
      'machine': machine,
      'os': 'iOS ${ios.systemVersion}',
      'platform': 'ios',
    };
  }

  if (Platform.isAndroid) {
    final android = await info.androidInfo;
    return {
      'name': androidModelName(android.brand, android.model),
      'model': androidModelName(android.brand, android.model),
      'os': 'Android ${android.version.release}',
      'platform': 'android',
    };
  }

  return const {'name': 'This device', 'model': '', 'os': '', 'platform': ''};
});

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(devicesStateProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText(
          l10n.settings_devices,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () =>
              context.fsmSafePop(fallbackRoute: '/settings/security'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(deviceActionsProvider).refresh(),
        color: colors.gold,
        backgroundColor: colors.container,
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
      return Center(
        child: CircularProgressIndicator(color: context.colors.gold),
      );
    }

    if (state.requiresUnlock && state.devices.isEmpty) {
      return _buildUnlockRequired(context, l10n);
    }

    if (state.error != null && state.devices.isEmpty) {
      return _buildErrorState(context, ref, l10n);
    }

    final devices = state.devices;
    final localId = ref.watch(localDeviceIdProvider).value ?? '';
    final currentDevice = _currentDevice(devices, localId);
    final otherDevices = devices
        .where((device) => !_isThisDevice(device, localId))
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      children: [
        _DevicesSummary(
          count: devices.length,
          blockedCount: devices.where((device) => device.cannotAccess).length,
        ),
        const SizedBox(height: AppSpacing.xl),
        _SectionHeader(title: l10n.settings_thisDevice),
        const SizedBox(height: AppSpacing.sm),
        _CurrentDeviceCard(device: currentDevice),
        const SizedBox(height: AppSpacing.xl),
        if (otherDevices.isNotEmpty) ...[
          _SectionHeader(title: l10n.settings_otherDevices),
          const SizedBox(height: AppSpacing.sm),
          ...otherDevices.map(
            (device) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _OtherDeviceCard(device: device),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.settings_signOutOtherDevices,
            onPressed: () =>
                _handleLogoutOthers(context, ref, l10n, devices, localId),
            variant: AppButtonVariant.danger,
            isFullWidth: true,
          ),
        ] else if (devices.isNotEmpty) ...[
          _NoOtherDevicesCard(l10n: l10n),
        ] else ...[
          _buildEmptyState(context, l10n),
        ],
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Device? _currentDevice(List<Device> devices, String localId) {
    for (final device in devices) {
      if (_isThisDevice(device, localId)) return device;
    }
    return null;
  }

  bool _isThisDevice(Device device, String localId) {
    return device.isCurrent ||
        (localId.isNotEmpty && device.deviceIdentifier == localId);
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          Icon(Icons.devices_rounded, size: 48, color: colors.gold),
          const SizedBox(height: AppSpacing.lg),
          AppText(
            l10n.settings_noDevices,
            variant: AppTextVariant.titleMedium,
            textAlign: TextAlign.center,
            color: colors.textPrimary,
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
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 44, color: colors.errorText),
            const SizedBox(height: AppSpacing.xl),
            AppText(
              l10n.settings_devicesLoadErrorTitle,
              variant: AppTextVariant.titleMedium,
              textAlign: TextAlign.center,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.settings_devicesLoadErrorDescription,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
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

  Widget _buildUnlockRequired(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 48, color: colors.gold),
            const SizedBox(height: AppSpacing.xl),
            AppText(
              l10n.session_unlockReason,
              variant: AppTextVariant.titleMedium,
              textAlign: TextAlign.center,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.settings_devicesDescription,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.auth_tapToUnlock,
              onPressed: () => context.fsmGo('/session-locked'),
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogoutOthers(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    List<Device> devices,
    String localId,
  ) async {
    final confirmed = await context.showDeleteConfirmation(
      title: l10n.settings_signOutOtherDevicesTitle,
      message: l10n.settings_signOutOtherDevicesMessage,
      confirmText: l10n.settings_signOutOtherDevices,
    );

    if (!confirmed) return;

    try {
      await ref
          .read(deviceActionsProvider)
          .revokeOtherDevices(devices, localId);
      if (context.mounted) {
        await context.showSuccessAlert(
          title: l10n.action_done,
          message: l10n.settings_signOutOtherDevicesSuccess,
        );
      }
    } catch (_) {
      if (context.mounted) {
        await context.showErrorAlert(
          title: l10n.common_error,
          message: l10n.settings_signOutOtherDevicesError,
        );
      }
    }
  }
}

class _DevicesSummary extends StatelessWidget {
  const _DevicesSummary({required this.count, required this.blockedCount});

  final int count;
  final int blockedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(Icons.devices_rounded, color: colors.gold, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.settings_connectedDevices,
                variant: AppTextVariant.titleSmall,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.xxs),
              AppText(
                count == 1
                    ? l10n.settings_oneDeviceAccess
                    : l10n.settings_multipleDevicesAccess(count),
                variant: AppTextVariant.bodySmall,
                color: blockedCount > 0
                    ? colors.warningText
                    : colors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppText(
      title.toUpperCase(),
      variant: AppTextVariant.labelSmall,
      color: context.colors.textSecondary,
    );
  }
}

class _CurrentDeviceCard extends ConsumerWidget {
  const _CurrentDeviceCard({required this.device});

  final Device? device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final localInfo = ref.watch(_localDeviceInfoProvider).value ?? const {};
    final modelName =
        localInfo['model'] ?? device?.displayLabel ?? l10n.settings_thisDevice;
    final deviceName = localInfo['name'] ?? device?.deviceName ?? modelName;
    final osInfo = localInfo['os'] ?? device?.osDisplay ?? '';
    final platform = localInfo['platform'] ?? device?.platform ?? '';
    final isBlocked = device?.isBlocked ?? false;
    final isInactive = device?.isActive == false;

    return AppCard(
      variant: AppCardVariant.goldAccent,
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DeviceIcon(platform: platform, isActive: true, isCurrent: true),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      modelName,
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      _joinDetails([
                        deviceName == modelName ? null : deviceName,
                        osInfo,
                        device?.appVersion == null
                            ? null
                            : 'v${device!.appVersion}',
                      ]),
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isBlocked)
                _StatusBadge(
                  label: l10n.settings_blocked,
                  color: colors.errorText,
                  background: colors.errorBg,
                )
              else if (isInactive)
                _StatusBadge(
                  label: l10n.settings_inactive,
                  color: colors.warningText,
                  background: colors.warningBg,
                )
              else
                _StatusBadge(
                  label: l10n.settings_activeNow,
                  color: colors.successText,
                  background: colors.successBg,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _DeviceMetaWrap(
            device: device,
            fallbackLastActive: l10n.settings_justNow,
          ),
          if (device?.cannotAccess == true) ...[
            const SizedBox(height: AppSpacing.md),
            _DeviceAccessNotice(device: device!),
          ],
        ],
      ),
    );
  }
}

class _OtherDeviceCard extends ConsumerWidget {
  const _OtherDeviceCard({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      variant: AppCardVariant.flat,
      borderRadius: AppRadius.lg,
      borderColor: device.isBlocked
          ? colors.error.withValues(alpha: 0.28)
          : null,
      child: Row(
        children: [
          _DeviceIcon(
            platform: device.platform,
            isActive: device.isRecentlyActive,
            isCurrent: false,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  device.displayLabel,
                  variant: AppTextVariant.labelLarge,
                  color: colors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  _joinDetails([
                    device.osDisplay,
                    _formatLastActive(context, device.lastActiveAt),
                  ]),
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _StatusBadge(
                      label: device.isBlocked
                          ? l10n.settings_blocked
                          : !device.isActive
                          ? l10n.settings_inactive
                          : device.isTrusted
                          ? l10n.settings_trusted
                          : l10n.settings_notTrusted,
                      color: device.isBlocked
                          ? colors.errorText
                          : !device.isActive
                          ? colors.warningText
                          : device.isTrusted
                          ? colors.successText
                          : colors.warningText,
                      background: device.isBlocked
                          ? colors.errorBg
                          : !device.isActive
                          ? colors.warningBg
                          : device.isTrusted
                          ? colors.successBg
                          : colors.warningBg,
                    ),
                    if (device.loginCount != null)
                      _StatusBadge(
                        label: l10n.settings_loginCountValue(
                          device.loginCount!,
                        ),
                        color: colors.textSecondary,
                        background: colors.elevated,
                      ),
                  ],
                ),
                if (device.cannotAccess) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _DeviceAccessNotice(device: device),
                ],
              ],
            ),
          ),
          _DeviceMenu(device: device),
        ],
      ),
    );
  }
}

class _DeviceMenu extends ConsumerWidget {
  const _DeviceMenu({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    if (device.cannotAccess) {
      return Tooltip(
        message: device.isBlocked
            ? l10n.settings_deviceBlockedDescription
            : l10n.settings_deviceInactiveDescription,
        child: Icon(
          device.isBlocked ? Icons.shield_rounded : Icons.block_rounded,
          color: device.isBlocked ? colors.errorText : colors.warningText,
          size: 20,
        ),
      );
    }

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: colors.textSecondary,
        size: 20,
      ),
      color: colors.container,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.borderSubtle),
      ),
      onSelected: (action) {
        if (action == 'trust') {
          _handleTrust(context, ref, l10n, device);
        } else if (action == 'untrust') {
          _handleUntrust(context, ref, l10n, device);
        } else if (action == 'rename') {
          _handleRename(context, ref, l10n, device);
        } else if (action == 'remove') {
          _handleRemove(context, ref, l10n, device);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: device.isTrusted ? 'untrust' : 'trust',
          child: _MenuRow(
            icon: device.isTrusted
                ? Icons.verified_user_outlined
                : Icons.verified_user_rounded,
            label: device.isTrusted
                ? l10n.settings_untrustDevice
                : l10n.settings_trustDevice,
            color: colors.textPrimary,
          ),
        ),
        PopupMenuItem(
          value: 'rename',
          child: _MenuRow(
            icon: Icons.edit_outlined,
            label: l10n.settings_renameDevice,
            color: colors.textPrimary,
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          child: _MenuRow(
            icon: Icons.logout_rounded,
            label: l10n.settings_removeDevice,
            color: colors.errorText,
          ),
        ),
      ],
    );
  }

  Future<void> _handleTrust(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Device device,
  ) async {
    try {
      await ref.read(deviceActionsProvider).trustDevice(device.id);
      if (context.mounted) {
        await context.showSuccessAlert(
          title: l10n.action_done,
          message: l10n.settings_deviceTrustedSuccess,
        );
      }
    } catch (_) {
      if (context.mounted) {
        await context.showErrorAlert(
          title: l10n.common_error,
          message: l10n.settings_deviceTrustError,
        );
      }
    }
  }

  Future<void> _handleUntrust(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Device device,
  ) async {
    try {
      await ref.read(deviceActionsProvider).untrustDevice(device.id);
      if (context.mounted) {
        await context.showSuccessAlert(
          title: l10n.action_done,
          message: l10n.settings_deviceUntrustedSuccess,
        );
      }
    } catch (_) {
      if (context.mounted) {
        await context.showErrorAlert(
          title: l10n.common_error,
          message: l10n.settings_deviceUntrustError,
        );
      }
    }
  }

  Future<void> _handleRename(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Device device,
  ) async {
    final controller = TextEditingController(text: device.deviceName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.colors.container,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: AppText(
          l10n.settings_renameDevice,
          variant: AppTextVariant.titleMedium,
        ),
        content: AppInput(
          label: l10n.settings_deviceName,
          controller: controller,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          AppButton(
            label: l10n.action_cancel,
            onPressed: () => Navigator.pop(dialogContext),
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.small,
          ),
          AppButton(
            label: l10n.action_save,
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            variant: AppButtonVariant.primary,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;

    try {
      await ref.read(deviceActionsProvider).renameDevice(device.id, name);
      if (context.mounted) {
        await context.showSuccessAlert(
          title: l10n.action_done,
          message: l10n.settings_deviceRenamedSuccess,
        );
      }
    } catch (_) {
      if (context.mounted) {
        await context.showErrorAlert(
          title: l10n.common_error,
          message: l10n.settings_deviceRenameError,
        );
      }
    }
  }

  Future<void> _handleRemove(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Device device,
  ) async {
    final confirmed = await context.showDeleteConfirmation(
      title: l10n.settings_revokeDeviceTitle,
      message: l10n.settings_revokeDeviceMessage,
      confirmText: l10n.settings_removeDevice,
    );
    if (!confirmed) return;

    try {
      await ref.read(deviceActionsProvider).revokeDevice(device.id);
      if (context.mounted) {
        await context.showSuccessAlert(
          title: l10n.action_done,
          message: l10n.settings_deviceRemovedSuccess,
        );
      }
    } catch (_) {
      if (context.mounted) {
        await context.showErrorAlert(
          title: l10n.common_error,
          message: l10n.settings_deviceRemoveError,
        );
      }
    }
  }
}

class _DeviceAccessNotice extends StatelessWidget {
  const _DeviceAccessNotice({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final isBlocked = device.isBlocked;
    final rawReason = device.blockedReason?.trim();
    final message = rawReason != null && rawReason.isNotEmpty
        ? rawReason
        : isBlocked
        ? l10n.settings_deviceBlockedDescription
        : l10n.settings_deviceInactiveDescription;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isBlocked ? colors.errorBg : colors.warningBg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: (isBlocked ? colors.error : colors.warning).withValues(
            alpha: 0.26,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isBlocked ? Icons.shield_rounded : Icons.info_outline_rounded,
            size: 16,
            color: isBlocked ? colors.errorText : colors.warningText,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: AppText(
              message,
              variant: AppTextVariant.bodySmall,
              color: isBlocked ? colors.errorText : colors.warningText,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoOtherDevicesCard extends StatelessWidget {
  const _NoOtherDevicesCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.flat,
      borderRadius: AppRadius.lg,
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: colors.successText),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              l10n.settings_noOtherDevices,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceMetaWrap extends StatelessWidget {
  const _DeviceMetaWrap({
    required this.device,
    required this.fallbackLastActive,
  });

  final Device? device;
  final String fallbackLastActive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final rows = [
      _MetaItem(
        icon: Icons.access_time_rounded,
        label: l10n.settings_lastActive,
        value: device == null
            ? fallbackLastActive
            : _formatLastActive(context, device!.lastActiveAt),
      ),
      if (device?.lastIpAddress != null)
        _MetaItem(
          icon: Icons.public_rounded,
          label: l10n.settings_lastIp,
          value: device!.lastIpAddress!,
        ),
      if (device?.loginCount != null)
        _MetaItem(
          icon: Icons.login_rounded,
          label: l10n.settings_loginCount,
          value: device!.loginCount.toString(),
        ),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: rows
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 14, color: colors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  AppText(
                    '${item.label}: ${item.value}',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MetaItem {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _DeviceIcon extends StatelessWidget {
  const _DeviceIcon({
    required this.platform,
    required this.isActive,
    required this.isCurrent,
  });

  final String? platform;
  final bool isActive;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCurrent
                ? colors.gold.withValues(alpha: 0.12)
                : colors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(
            _platformIcon(platform),
            color: isCurrent ? colors.gold : colors.textSecondary,
            size: 24,
          ),
        ),
        if (isActive)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors.successText,
                shape: BoxShape.circle,
                border: Border.all(color: colors.container, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: AppText(
        label,
        variant: AppTextVariant.labelSmall,
        color: color,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppText(
            label,
            variant: AppTextVariant.bodyMedium,
            color: color,
          ),
        ),
      ],
    );
  }
}

IconData _platformIcon(String? platform) {
  switch (platform?.toLowerCase()) {
    case 'ios':
      return Icons.phone_iphone_rounded;
    case 'android':
      return Icons.smartphone_rounded;
    case 'web':
      return Icons.language_rounded;
    default:
      return Icons.devices_rounded;
  }
}

String _joinDetails(List<String?> values) {
  return values
      .where((value) => value != null && value.trim().isNotEmpty)
      .map((value) => value!.trim())
      .join(' · ');
}

String _formatLastActive(BuildContext context, DateTime? date) {
  final l10n = AppLocalizations.of(context)!;
  if (date == null) return l10n.settings_neverActive;

  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return l10n.settings_justNow;
  if (diff.inMinutes < 60) return l10n.settings_minutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.settings_hoursAgo(diff.inHours);
  if (diff.inDays < 7) return l10n.settings_daysAgo(diff.inDays);

  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat('MMM d, yyyy', locale).format(date);
}
