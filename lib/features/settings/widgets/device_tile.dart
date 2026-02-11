import 'package:flutter/material.dart';
import '../../../domain/entities/device.dart';
import '../../../utils/duration_extensions.dart';

/// Tile showing a registered device.
class DeviceTile extends StatelessWidget {
  final Device device;
  final VoidCallback? onRemove;

  const DeviceTile({super.key, required this.device, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
            child: Icon(
              device.platform == 'ios' ? Icons.phone_iphone_rounded : Icons.phone_android_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(device.displayLabel, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                    if (device.isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text('This device', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Last active: ${device.lastActiveAt.timeAgo}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (!device.isCurrent && onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.close_rounded, color: theme.colorScheme.error, size: 20),
              visualDensity: VisualDensity.compact,
            ),
          if (device.isTrusted)
            Icon(Icons.verified_user_rounded, color: Colors.green.shade600, size: 18),
        ],
      ),
    );
  }
}
