import 'package:flutter/material.dart';
import 'package:usdc_wallet/features/pin/views/pin_screen.dart';

/// Backward-compatible alias for the canonical login PIN surface.
///
/// `/login/pin` is routed directly to [PinScreen]; this class remains for older
/// tests/goldens and feature imports without carrying separate unlock state.
class LoginPinView extends StatelessWidget {
  const LoginPinView({super.key});

  @override
  Widget build(BuildContext context) =>
      const PinScreen(pinContext: PinContext.login);
}
