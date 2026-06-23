import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/card.dart';
import 'package:usdc_wallet/features/cards/widgets/korido_card_surface.dart';

/// Visual representation of a virtual/physical card.
class CardVisual extends StatelessWidget {
  const CardVisual({super.key, required this.card, this.onTap});

  final KoridoCard card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      KoridoCardSurface(card: card, onTap: onTap, margin: EdgeInsets.zero);
}
