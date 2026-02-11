import 'package:flutter/material.dart';

/// Alias for AlertBannerType used in some views.
typedef AlertVariant = AlertBannerType;

/// In-app alert banner for KYC reminders, promotions, warnings.
class AlertBanner extends StatelessWidget {
  final String message;
  final AlertBannerType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const AlertBanner({
    super.key,
    required this.message,
    this.type = AlertBannerType.info,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(colors.icon, size: 18, color: colors.foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: colors.foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.foreground,
                ),
              ),
            ),
          ],
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.close, size: 16, color: colors.foreground),
              ),
            ),
        ],
      ),
    );
  }

  _BannerColors _colors(BuildContext context) {
    switch (type) {
      case AlertBannerType.info:
        return _BannerColors(
          background: Colors.blue.shade50,
          foreground: Colors.blue.shade700,
          border: Colors.blue.shade200,
          icon: Icons.info_outline_rounded,
        );
      case AlertBannerType.warning:
        return _BannerColors(
          background: Colors.orange.shade50,
          foreground: Colors.orange.shade700,
          border: Colors.orange.shade200,
          icon: Icons.warning_amber_rounded,
        );
      case AlertBannerType.error:
        return _BannerColors(
          background: Colors.red.shade50,
          foreground: Colors.red.shade700,
          border: Colors.red.shade200,
          icon: Icons.error_outline_rounded,
        );
      case AlertBannerType.success:
        return _BannerColors(
          background: Colors.green.shade50,
          foreground: Colors.green.shade700,
          border: Colors.green.shade200,
          icon: Icons.check_circle_outline_rounded,
        );
    }
  }
}

enum AlertBannerType { info, warning, error, success }

class _BannerColors {
  final Color background;
  final Color foreground;
  final Color border;
  final IconData icon;

  const _BannerColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
  });
}
