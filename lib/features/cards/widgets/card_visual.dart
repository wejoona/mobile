import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/card.dart';

/// Visual representation of a virtual/physical card.
class CardVisual extends StatelessWidget {
  final KoridoCard card;
  final VoidCallback? onTap;

  const CardVisual({super.key, required this.card, this.onTap});

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: card.isActive
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [Colors.grey.shade600, Colors.grey.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('KORIDO', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2)),
                Text(card.type == CardType.virtual ? 'VIRTUAL' : 'PHYSICAL', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, letterSpacing: 1)),
              ],
            ),
            const Spacer(),
            Text(
              '•••• •••• •••• ${card.last4}',
              style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 3, fontFeatures: [FontFeature.tabularFigures()]),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EXPIRES', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
                    Text(card.expiryFormatted, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
                if (card.nickname != null)
                  Text(card.nickname!, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                Text(card.brand.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
