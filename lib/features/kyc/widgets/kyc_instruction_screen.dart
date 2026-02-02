import 'package:flutter/material.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/theme_colors.dart';
import '../../../design/components/primitives/app_button.dart';
import '../../../design/components/primitives/app_text.dart';

/// Reusable instruction screen shown before each KYC step
class KycInstructionScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<KycInstruction> instructions;
  final String buttonLabel;
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const KycInstructionScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.instructions,
    required this.buttonLabel,
    required this.onContinue,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: onBack != null
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                onPressed: onBack,
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      // Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: colors.gold.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 48,
                          color: colors.gold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      // Title
                      AppText(
                        title,
                        variant: AppTextVariant.headlineMedium,
                        color: colors.textPrimary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Description
                      AppText(
                        description,
                        variant: AppTextVariant.bodyLarge,
                        color: colors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      // Instructions list
                      ...instructions.map((instruction) => _buildInstructionRow(
                            context,
                            instruction,
                            colors,
                          )),
                    ],
                  ),
                ),
              ),
              // Continue button
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: buttonLabel,
                onPressed: onContinue,
                isFullWidth: true,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(
    BuildContext context,
    KycInstruction instruction,
    ThemeColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: instruction.isWarning
                  ? colors.warning.withOpacity(0.1)
                  : colors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              instruction.icon,
              size: 20,
              color: instruction.isWarning ? colors.warning : colors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  instruction.title,
                  variant: AppTextVariant.labelLarge,
                  color: colors.textPrimary,
                ),
                if (instruction.subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    instruction.subtitle!,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Single instruction item
class KycInstruction {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isWarning;

  const KycInstruction({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isWarning = false,
  });
}

/// Pre-built instruction configurations for each KYC step
class KycInstructions {
  static List<KycInstruction> get documentCapture => const [
        KycInstruction(
          icon: Icons.badge_outlined,
          title: 'Use your original document',
          subtitle: 'No photocopies or photos of photos',
        ),
        KycInstruction(
          icon: Icons.lightbulb_outline,
          title: 'Find good lighting',
          subtitle: 'Avoid shadows and reflections',
        ),
        KycInstruction(
          icon: Icons.crop_free,
          title: 'Fit document in frame',
          subtitle: 'All corners should be visible',
        ),
        KycInstruction(
          icon: Icons.blur_off,
          title: 'Keep steady',
          subtitle: 'Hold still to avoid blur',
          isWarning: true,
        ),
      ];

  static List<KycInstruction> get selfie => const [
        KycInstruction(
          icon: Icons.face,
          title: 'Face the camera directly',
          subtitle: 'Look straight at the camera',
        ),
        KycInstruction(
          icon: Icons.wb_sunny_outlined,
          title: 'Good lighting on your face',
          subtitle: 'Avoid backlighting or harsh shadows',
        ),
        KycInstruction(
          icon: Icons.visibility_off_outlined,
          title: 'Remove accessories',
          subtitle: 'Take off glasses, hats, or face coverings',
          isWarning: true,
        ),
        KycInstruction(
          icon: Icons.sentiment_satisfied_outlined,
          title: 'Neutral expression',
          subtitle: 'Keep a natural, relaxed face',
        ),
      ];

  static List<KycInstruction> get liveness => const [
        KycInstruction(
          icon: Icons.videocam_outlined,
          title: 'Video verification',
          subtitle: 'We\'ll ask you to perform simple actions',
        ),
        KycInstruction(
          icon: Icons.rotate_left,
          title: 'Follow the prompts',
          subtitle: 'Turn your head or blink when asked',
        ),
        KycInstruction(
          icon: Icons.timer_outlined,
          title: 'Takes about 30 seconds',
          subtitle: 'Stay in frame throughout',
        ),
        KycInstruction(
          icon: Icons.block,
          title: 'No photos of photos',
          subtitle: 'This verifies you\'re a real person',
          isWarning: true,
        ),
      ];
}
