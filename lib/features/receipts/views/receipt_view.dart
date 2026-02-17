import 'package:flutter/material.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Stub for deferred loading - receipt view
class ReceiptView extends StatelessWidget {
  const ReceiptView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(child: Text(AppLocalizations.of(context)!.receipts_receiptView)),
      );
}
