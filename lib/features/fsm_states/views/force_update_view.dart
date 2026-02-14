import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// Full-screen force update view shown when app version is too old
class ForceUpdateView extends StatelessWidget {
  const ForceUpdateView({super.key});

  static const _appStoreUrl = 'https://apps.apple.com/app/korido/id000000000';
  static const _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.joonapay.korido';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.system_update,
                size: 80,
                color: context.colors.gold,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppText(
                'Mise à jour requise',
                variant: AppTextVariant.headlineMedium,
                color: context.colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                'Une nouvelle version de Korido est disponible. Veuillez mettre à jour l\'application pour continuer.',
                variant: AppTextVariant.bodyLarge,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                label: 'Mettre à jour',
                onPressed: _openStore,
                isFullWidth: true,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore() async {
    final url = Platform.isIOS ? _appStoreUrl : _playStoreUrl;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
