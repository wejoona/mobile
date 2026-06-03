import 'package:flutter/material.dart';
import 'package:usdc_wallet/features/cards/views/request_card_view.dart';

/// Backward-compatible card creation route.
///
/// Card issuance must collect verified cardholder details and an explicit
/// spending limit. The production flow lives in [RequestCardView].
class CreateCardScreen extends StatelessWidget {
  const CreateCardScreen({super.key});

  @override
  Widget build(BuildContext context) => const RequestCardView();
}
