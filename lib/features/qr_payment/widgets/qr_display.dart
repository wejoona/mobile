import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

/// Reusable QR Code Display Widget
class QrDisplay extends StatelessWidget {
  const QrDisplay({
    super.key,
    required this.data,
    this.size = 200,
    this.padding,
    this.backgroundColor = Colors.white,
    this.foregroundColor = const Color(0xFF1A1A2E),
    this.showBorder = true,
    this.title,
    this.subtitle,
    this.footer,
  });

  final String data;
  final double size;
  final EdgeInsets? padding;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool showBorder;
  final String? title;
  final String? subtitle;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          AppText(
            title!,
            variant: AppTextVariant.titleLarge,
            color: colors.gold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (subtitle != null) ...[
          AppText(
            subtitle!,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: showBorder
                ? Border.all(color: colors.borderSubtle, width: 1)
                : null,
            boxShadow: showBorder
                ? [
                    BoxShadow(
                      color: colors.gold.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: QrImageView(
            data: data,
            version: QrVersions.auto,
            size: size,
            backgroundColor: backgroundColor,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: foregroundColor,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: foregroundColor,
            ),
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: AppSpacing.lg),
          footer!,
        ],
      ],
    );
  }
}

/// QR Code with overlay information
class QrDisplayWithInfo extends StatelessWidget {
  const QrDisplayWithInfo({
    super.key,
    required this.data,
    required this.phone,
    this.name,
    this.amount,
    this.currency,
    this.size = 200,
  });

  final String data;
  final String phone;
  final String? name;
  final double? amount;
  final String? currency;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          // QR Code
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: size,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1A1A2E),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Branding
          AppText(
            'Korido',
            variant: AppTextVariant.titleLarge,
            color: colors.gold,
          ),

          const SizedBox(height: AppSpacing.sm),

          // Phone
          AppText(
            phone,
            variant: AppTextVariant.bodyLarge,
            color: colors.textPrimary,
          ),

          if (name != null && name!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            AppText(
              name!,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
          ],

          if (amount != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Divider(color: colors.borderSubtle),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              'Amount',
              variant: AppTextVariant.labelSmall,
              color: colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              '\$$amount ${currency ?? "USD"}',
              variant: AppTextVariant.headlineSmall,
              color: colors.gold,
            ),
          ],
        ],
      ),
    );
  }
}
