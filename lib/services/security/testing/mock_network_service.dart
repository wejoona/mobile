import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock network service for testing security features.
class MockNetworkService {
  bool _isOnline = true;
  bool _isMitmDetected = false;
  bool _isVpnDetected = false;
  int _latencyMs = 50;

  void setOnline(bool value) => _isOnline = value;
  void setMitmDetected(bool value) => _isMitmDetected = value;
  void setVpnDetected(bool value) => _isVpnDetected = value;
  void setLatency(int ms) => _latencyMs = ms;

  bool get isOnline => _isOnline;
  bool get isMitmDetected => _isMitmDetected;
  bool get isVpnDetected => _isVpnDetected;
  int get latencyMs => _latencyMs;

  Future<Map<String, dynamic>> makeRequest(String endpoint) async {
    if (!_isOnline) throw Exception('Offline');
    return {'status': 200, 'endpoint': endpoint};
  }
}

final mockNetworkServiceProvider = Provider<MockNetworkService>((ref) {
  return MockNetworkService();
});
