import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/app_version/mobile_version_policy_service.dart';

/// Full-screen force update view shown when app version is too old
class ForceUpdateView extends ConsumerWidget {
  const ForceUpdateView({super.key});

  static const _appStoreUrl = 'https://apps.apple.com/app/korido/id6761443157';
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.joonapay.usdcWallet';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final policyState = ref.watch(mobileVersionPolicyProvider);
    final policy = policyState.policy;
    final message = policy?.message ?? l10n.forceUpdate_defaultMessage;
    final requiredVersion = policy?.minimumSupportedVersion;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(Icons.system_update, size: 80, color: context.colors.gold),
              const SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.forceUpdate_title,
                variant: AppTextVariant.headlineMedium,
                color: context.colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                message,
                variant: AppTextVariant.bodyLarge,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              if (requiredVersion != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppText(
                  l10n.forceUpdate_requiredVersion(requiredVersion),
                  color: context.colors.textTertiary,
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              AppButton(
                label: l10n.forceUpdate_button,
                onPressed: () async {
                  final opened = await _openStore(policy?.appUrl);
                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not open the store link. Please try again from TestFlight or your app store.',
                        ),
                      ),
                    );
                  }
                },
                isFullWidth: true,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _openStore(String? configuredUrl) async {
    final url =
        configuredUrl ?? (Platform.isIOS ? _appStoreUrl : _playStoreUrl);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }
}
