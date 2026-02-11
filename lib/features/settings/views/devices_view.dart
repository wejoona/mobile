import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/device_tile.dart';
import '../../../design/components/primitives/confirmation_dialog.dart';
import '../../../design/components/primitives/empty_state.dart';
import '../../../services/api/api_client.dart';
import '../../../domain/entities/device.dart';

/// Active devices / sessions screen.
class DevicesView extends ConsumerWidget {
  const DevicesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In real app, this would be a FutureProvider
    return Scaffold(
      appBar: AppBar(title: const Text('Active Devices')),
      body: const EmptyState(
        icon: Icons.devices_rounded,
        title: 'Your Devices',
        subtitle: 'Manage devices that have access to your account',
      ),
    );
  }
}
