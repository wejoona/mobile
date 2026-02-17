import 'package:flutter/material.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Stub for deferred loading - liveness check view
class LivenessCheckView extends StatelessWidget {
  const LivenessCheckView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(child: Text(AppLocalizations.of(context)!.liveness_title)),
      );
}
