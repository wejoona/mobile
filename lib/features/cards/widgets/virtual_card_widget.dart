import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/card.dart';
import 'package:usdc_wallet/features/cards/widgets/korido_card_surface.dart';

/// Visual representation of a virtual card.
class VirtualCardWidget extends StatelessWidget {
  const VirtualCardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.showDetails = false,
  });

  final KoridoCard card;
  final VoidCallback? onTap;
  final bool showDetails;

  @override
  Widget build(BuildContext context) => KoridoCardSurface(
    card: card,
    showDetails: showDetails,
    onTap: onTap,
    margin: EdgeInsets.zero,
  );
}
