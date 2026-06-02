import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// Compact marker for contacts that already have a Korido account.
class KoridoAccountBadge extends StatelessWidget {
  const KoridoAccountBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => IdentityBadge.koridoMember(
    compact: compact,
    label: compact ? null : 'Korido',
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('compact', compact));
  }
}
