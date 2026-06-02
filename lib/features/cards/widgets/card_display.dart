import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/card.dart';
import 'package:usdc_wallet/features/cards/widgets/korido_card_surface.dart';

/// Run 383: Virtual/physical card display widget.
class CardDisplay extends StatelessWidget {
  const CardDisplay({
    super.key,
    required this.card,
    this.showDetails = false,
    this.onTap,
  });

  final KoridoCard card;
  final bool showDetails;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      KoridoCardSurface(card: card, showDetails: showDetails, onTap: onTap);
}
