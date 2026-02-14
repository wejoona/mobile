import 'package:flutter/material.dart';

/// Tile for selecting a bill payment provider.
class BillerTile extends StatelessWidget {
  final String name;
  final String category;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const BillerTile({
    super.key,
    required this.name,
    required this.category,
    this.icon = Icons.receipt_long_rounded,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = color ?? theme.colorScheme.primaryContainer;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: bgColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: bgColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    Text(category, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category of bill payment billers.
class BillerCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<BillerInfo> billers;

  const BillerCategory({required this.name, required this.icon, required this.color, required this.billers});

  static const List<BillerCategory> categories = [
    BillerCategory(name: 'Electricity', icon: Icons.bolt_rounded, color: Colors.amber, billers: [
      BillerInfo(id: 'cie', name: 'CIE', category: 'Electricity'),
    ]),
    BillerCategory(name: 'Water', icon: Icons.water_drop_rounded, color: Colors.blue, billers: [
      BillerInfo(id: 'sodeci', name: 'SODECI', category: 'Water'),
    ]),
    BillerCategory(name: 'Internet', icon: Icons.wifi_rounded, color: Colors.purple, billers: [
      BillerInfo(id: 'orange_internet', name: 'Orange Internet', category: 'Internet'),
      BillerInfo(id: 'mtn_internet', name: 'MTN Internet', category: 'Internet'),
    ]),
    BillerCategory(name: 'TV', icon: Icons.tv_rounded, color: Colors.teal, billers: [
      BillerInfo(id: 'canal_plus', name: 'Canal+', category: 'TV'),
      BillerInfo(id: 'startimes', name: 'StarTimes', category: 'TV'),
    ]),
    BillerCategory(name: 'Airtime', icon: Icons.phone_android_rounded, color: Colors.orange, billers: [
      BillerInfo(id: 'orange_airtime', name: 'Orange Airtime', category: 'Airtime'),
      BillerInfo(id: 'mtn_airtime', name: 'MTN Airtime', category: 'Airtime'),
      BillerInfo(id: 'moov_airtime', name: 'Moov Airtime', category: 'Airtime'),
    ]),
  ];
}

class BillerInfo {
  final String id;
  final String name;
  final String category;

  const BillerInfo({required this.id, required this.name, required this.category});
}
