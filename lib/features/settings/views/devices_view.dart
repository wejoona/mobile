import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/empty_state.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Active devices / sessions screen.
class DevicesView extends ConsumerWidget {
  const DevicesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings_activeDevices)),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: invalidate devices provider when wired
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            EmptyState(
              icon: Icons.devices_rounded,
              title: l10n.security_devices,
              subtitle: l10n.security_devicesSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}
