import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity State
enum ConnectivityStatus {
  /// Online with network access
  online,

  /// Offline, no network access
  offline,

  /// Unknown state (initializing)
  unknown,
}

/// Connectivity Service
/// Monitors network state and emits events on changes
class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<ConnectivityStatus> _statusController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;

  ConnectivityService({
    Connectivity? connectivity,
  })  : _connectivity = connectivity ?? Connectivity(),
        _statusController = StreamController<ConnectivityStatus>.broadcast();

  /// Current connectivity status
  ConnectivityStatus get status => _currentStatus;

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Check if currently online
  bool get isOnline => _currentStatus == ConnectivityStatus.online;

  /// Check if currently offline
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  /// Initialize the service
  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  /// Update status based on connectivity result
  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);

    final newStatus =
        hasConnection ? ConnectivityStatus.online : ConnectivityStatus.offline;

    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
    }
  }

  /// Manually check connectivity
  Future<ConnectivityStatus> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    return _currentStatus;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}

/// Connectivity Service Provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Connectivity Status Provider
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

/// Is Online Provider (convenience)
final isOnlineProvider = Provider<bool>((ref) {
  final statusAsync = ref.watch(connectivityStatusProvider);
  return statusAsync.when(
    data: (status) => status == ConnectivityStatus.online,
    loading: () => true, // Assume online while checking
    error: (error, stackTrace) => false,
  );
});
