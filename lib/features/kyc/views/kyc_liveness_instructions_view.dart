import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/features/kyc/widgets/kyc_instruction_screen.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Écran d'instructions pour la vérification de présence (liveness)
/// Affiché AVANT l'écran de défi caméra, comme pour le selfie et le document.
class KycLivenessInstructionsView extends ConsumerStatefulWidget {
  const KycLivenessInstructionsView({super.key});

  @override
  ConsumerState<KycLivenessInstructionsView> createState() =>
      _KycLivenessInstructionsViewState();
}

class _KycLivenessInstructionsViewState
    extends ConsumerState<KycLivenessInstructionsView> {
  late bool _accepted;

  @override
  void initState() {
    super.initState();
    _accepted = ref.read(kycProvider).kycConsentAccepted;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return KycInstructionScreen(
      title: 'Vérification de présence',
      description:
          'Nous devons vérifier que vous êtes une personne réelle en analysant votre présence en direct.',
      icon: Icons.videocam_outlined,
      instructions: KycInstructions.liveness,
      buttonLabel: l10n.common_continue,
      canContinue: _accepted,
      extraContent: _buildConsentCard(context),
      onContinue: () {
        ref.read(kycProvider.notifier).setKycConsentAccepted(accepted: true);
        context.fsmGo('/kyc/liveness');
      },
      onBack: () => context.fsmPop(),
    );
  }

  Widget _buildConsentCard(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _accepted ? colors.borderGold : colors.border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: _toggleConsent,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _accepted,
                onChanged: (_) => _toggleConsent(),
                activeColor: colors.gold,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Identity verification consent',
                      variant: AppTextVariant.labelLarge,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      'I agree that Korido may process my identity data, share it with verification providers, and run AML/sanctions screening for account verification.',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleConsent() {
    setState(() => _accepted = !_accepted);
    ref.read(kycProvider.notifier).setKycConsentAccepted(accepted: _accepted);
  }
}
