import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/sync/sync_service.dart';

/// Singleton [SyncService] — lives as long as the provider scope.
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
