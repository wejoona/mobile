import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/empty_state.dart';

/// Active devices / sessions screen.
class DevicesView extends ConsumerWidget {
  const DevicesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appareils actifs')),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: invalidate devices provider when wired
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            EmptyState(
              icon: Icons.devices_rounded,
              title: 'Vos appareils',
              subtitle: 'Gérez les appareils ayant accès à votre compte',
            ),
          ],
        ),
      ),
    );
  }
}
