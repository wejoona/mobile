import 'package:usdc_wallet/features/settings/models/devices_state.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/dialogs/index.dart';
import 'package:usdc_wallet/features/settings/providers/devices_provider.dart';
import 'package:usdc_wallet/domain/entities/device.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

import 'package:usdc_wallet/utils/device_names.dart';

/// Local device info for display (cached).
final _localDeviceInfoProvider = FutureProvider<Map<String, String>>((ref) async {
  final info = DeviceInfoPlugin();
  if (Platform.isIOS) {
    final ios = await info.iosInfo;
    final machine = ios.utsname.machine; // e.g. "iPhone17,2"
    final marketingName = iosModelName(machine); // e.g. "iPhone 16 Pro Max"
    return {
      'name': ios.name,  // "Ben's iPhone 16 Pro Max"
      'model': marketingName,
      'machine': machine,
      'os': 'iOS ${ios.systemVersion}',
      'platform': 'ios',
    };
  } else if (Platform.isAndroid) {
    final android = await info.androidInfo;
    return {
      'name': androidModelName(android.brand, android.model),
      'model': androidModelName(android.brand, android.model),
      'os': 'Android ${android.version.release}',
      'platform': 'android',
    };
  }
  return {'name': 'Appareil', 'model': '', 'os': '', 'platform': ''};
});

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(devicesStateProvider);
    final colors = context.colors;

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
          onPressed: () => context.safePop(fallbackRoute: '/settings/security'),
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

    if (state.error != null && state.devices.isEmpty) {
      return _buildErrorState(context, ref, state.error!, l10n);
    }

    if (state.devices.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    final devices = state.devices.cast<Device>();
    final localId = ref.watch(localDeviceIdProvider).value ?? '';
    
    bool isThisDevice(Device d) =>
        d.isCurrent || (localId.isNotEmpty && d.deviceIdentifier == localId);
    
    final currentDevice = devices.where(isThisDevice).toList();
    final otherDevices = devices.where((d) => !isThisDevice(d)).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      children: [
        // Device count header
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: context.colors.goldGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.devices_rounded, color: Colors.black, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      '${devices.length} appareil${devices.length > 1 ? 's' : ''} connecté${devices.length > 1 ? 's' : ''}',
                      variant: AppTextVariant.titleSmall,
                      color: context.colors.textPrimary,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      'Gérez l\'accès à votre compte',
                      variant: AppTextVariant.bodySmall,
                      color: context.colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Current device section — always show, use local info
        _buildSectionHeader(context, 'CET APPAREIL'),
        const SizedBox(height: AppSpacing.sm),
        _buildCurrentDeviceCard(
          context, ref,
          currentDevice.isNotEmpty ? currentDevice.first : null,
          l10n,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Other devices section
        if (otherDevices.isNotEmpty) ...[
          _buildSectionHeader(context, 'AUTRES APPAREILS'),
          const SizedBox(height: AppSpacing.sm),
          ...otherDevices.map((device) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildOtherDeviceCard(context, ref, device, l10n),
          )),
        ],

        // Logout all button
        if (otherDevices.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: () => _handleLogoutAll(context, ref, l10n),
            icon: Icon(Icons.logout_rounded, size: 18, color: context.colors.error),
            label: AppText(
              'Déconnecter tous les autres appareils',
              variant: AppTextVariant.labelMedium,
              color: context.colors.error,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: context.colors.error.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: context.colors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCurrentDeviceCard(
    BuildContext context,
    WidgetRef ref,
    Device? device,
    AppLocalizations l10n,
  ) {
    final colors = context.colors;
    final localInfo = ref.watch(_localDeviceInfoProvider).value ?? {};
    final modelName = localInfo['model'] ?? device?.displayLabel ?? 'iPhone';
    final deviceName = localInfo['name'] ?? device?.deviceName ?? modelName;
    final osInfo = localInfo['os'] ?? '${device?.platform ?? ""} ${device?.osVersion ?? ""}';
    final platformStr = localInfo['platform'] ?? device?.platform ?? 'ios';
    final appVer = device?.appVersion;
    final lastActive = device?.lastActiveAt;
    final isTrusted = device?.isTrusted ?? false;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.gold.withValues(alpha: 0.08),
            colors.gold.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Device icon with active pulse
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getPlatformIcon(platformStr),
                      color: colors.gold,
                      size: 26,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.canvas, width: 2),
                      ),
                    ),
                  ),
                ],
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
                            modelName,
                            variant: AppTextVariant.titleSmall,
                            color: colors.textPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              AppText(
                                'Actif',
                                variant: AppTextVariant.labelSmall,
                                color: colors.success,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      '$deviceName · $osInfo${appVer != null ? " · v$appVer" : ""}',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              if (isTrusted)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.verified_user_rounded, color: colors.success, size: 18),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Last active
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.canvas.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: colors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                AppText(
                  'Dernière activité: ${_formatLastActive(lastActive)}',
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherDeviceCard(
    BuildContext context,
    WidgetRef ref,
    Device device,
    AppLocalizations l10n,
  ) {
    final colors = context.colors;
    final isRecent = device.isRecentlyActive;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        children: [
          // Device icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPlatformIcon(device.platform),
              color: isRecent ? colors.textPrimary : colors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Info
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
                const SizedBox(height: 2),
                AppText(
                  '${device.platform} ${device.osVersion ?? ""} · ${_formatLastActive(device.lastActiveAt)}',
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: colors.textSecondary, size: 20),
            color: colors.container,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: colors.borderSubtle),
            ),
            onSelected: (action) {
              switch (action) {
                case 'trust':
                  _handleTrustDevice(context, ref, device, l10n);
                case 'revoke':
                  _handleRevokeDevice(context, ref, device, l10n);
              }
            },
            itemBuilder: (ctx) => [
              if (!device.isTrusted)
                PopupMenuItem(
                  value: 'trust',
                  child: Row(
                    children: [
                      Icon(Icons.verified_user_outlined, size: 18, color: colors.success),
                      const SizedBox(width: 10),
                      Text(AppLocalizations.of(context)!.settings_approve, style: TextStyle(color: colors.textPrimary)),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'revoke',
                child: Row(
                  children: [
                    Icon(Icons.block_rounded, size: 18, color: colors.error),
                    const SizedBox(width: 10),
                    Text('Révoquer', style: TextStyle(color: colors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.gold.withValues(alpha: 0.15),
                    colors.gold.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.devices_rounded, size: 48, color: colors.gold),
            ),
            const SizedBox(height: AppSpacing.xl),
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
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    String error,
    AppLocalizations l10n,
  ) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, size: 40, color: colors.error),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppText(
              'Impossible de charger les appareils',
              variant: AppTextVariant.titleMedium,
              textAlign: TextAlign.center,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'Vérifiez votre connexion et réessayez',
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

  IconData _getPlatformIcon(String? platform) {
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

  String _formatLastActive(DateTime? date) {
    if (date == null) return 'Jamais';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return DateFormat('d MMM yyyy', 'fr').format(date);
  }

  Future<void> _handleTrustDevice(
    BuildContext context, WidgetRef ref, Device device, AppLocalizations l10n,
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
    BuildContext context, WidgetRef ref, Device device, AppLocalizations l10n,
  ) async {
    final confirmed = await context.showDeleteConfirmation(
      title: 'Révoquer l\'appareil',
      message: 'Cet appareil sera déconnecté et devra se reconnecter.',
      confirmText: 'Révoquer',
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

  Future<void> _handleLogoutAll(
    BuildContext context, WidgetRef ref, AppLocalizations l10n,
  ) async {
    final confirmed = await context.showDeleteConfirmation(
      title: 'Déconnecter tous les appareils',
      message: 'Tous les autres appareils seront déconnectés. Seul cet appareil restera actif.',
      confirmText: 'Déconnecter tout',
    );

    if (confirmed) {
      try {
        await ref.read(deviceActionsProvider).revokeAllOtherDevices();
        if (context.mounted) {
          await context.showSuccessAlert(
            title: l10n.action_done,
            message: 'Tous les autres appareils ont été déconnectés.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          await context.showErrorAlert(
            title: l10n.common_error,
            message: 'Impossible de déconnecter les appareils.',
          );
        }
      }
    }
  }
}
