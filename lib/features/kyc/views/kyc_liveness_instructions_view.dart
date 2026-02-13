import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/features/kyc/widgets/kyc_instruction_screen.dart';

/// Écran d'instructions pour la vérification de présence (liveness)
/// Affiché AVANT l'écran de défi caméra, comme pour le selfie et le document.
class KycLivenessInstructionsView extends ConsumerWidget {
  const KycLivenessInstructionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return KycInstructionScreen(
      title: 'Vérification de présence',
      description:
          'Nous devons vérifier que vous êtes une personne réelle en analysant votre présence en direct.',
      icon: Icons.videocam_outlined,
      instructions: KycInstructions.liveness,
      buttonLabel: l10n.common_continue,
      onContinue: () => context.go('/kyc/liveness'),
      onBack: () => context.pop(),
    );
  }
}
