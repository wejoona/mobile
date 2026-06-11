import 'package:flutter/material.dart';
import 'package:usdc_wallet/features/cards/views/cards_list_view.dart';

/// Backward-compatible wallet route for virtual cards.
///
/// The production cards surface lives in `features/cards` and is wired to the
/// `/cards` API. Keeping this wrapper avoids legacy callers rendering a local
/// coming-soon card mockup.
class VirtualCardView extends StatelessWidget {
  const VirtualCardView({super.key});

  @override
  Widget build(BuildContext context) => const CardsListView();
}
