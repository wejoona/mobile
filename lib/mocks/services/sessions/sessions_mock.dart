import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';

/// Sessions Mock Data
class SessionsMock {
  static final List<Map<String, dynamic>> _mockSessions = _initialSessions();

  static void register(MockInterceptor interceptor) {
    // GET /sessions - Get all active sessions
    interceptor.register(
      method: 'GET',
      path: '/sessions',
      handler: (options) async {
        await Future.delayed(
          Duration(milliseconds: 500),
        ); // Simulate network delay
        return MockResponse.success({'sessions': _mockSessions});
      },
    );

    // DELETE /sessions/:id - Revoke a specific session
    interceptor.register(
      method: 'DELETE',
      path: '/sessions/:id',
      handler: (options) async {
        await Future.delayed(Duration(milliseconds: 300));

        // Extract session ID from path
        final sessionId = options.extractPathParams('/sessions/:id')['id'];

        // Remove from mock data
        _mockSessions.removeWhere((s) => s['id'] == sessionId);

        return MockResponse.success({
          'success': true,
          'message': 'Session revoked successfully',
        });
      },
    );

    // DELETE /sessions - Logout from all devices
    interceptor.register(
      method: 'DELETE',
      path: '/sessions',
      handler: (options) async {
        await Future.delayed(Duration(milliseconds: 400));

        // Clear all sessions
        _mockSessions.clear();

        return MockResponse.success({
          'success': true,
          'message': 'All sessions revoked successfully',
        });
      },
    );
  }

  static void reset() {
    _mockSessions
      ..clear()
      ..addAll(_initialSessions());
  }

  static List<Map<String, dynamic>> _initialSessions() {
    return [
      {
        'id': 'session-1',
        'deviceId': 'device-current',
        'ipAddress': '197.155.45.10',
        'userAgent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
        'location': 'Abidjan, Côte d\'Ivoire',
        'isActive': true,
        'lastActivityAt': DateTime.now().toIso8601String(),
        'expiresAt': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
      },
      {
        'id': 'session-2',
        'deviceId': 'device-2',
        'ipAddress': '41.223.45.88',
        'userAgent':
            'Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36',
        'location': 'Dakar, Senegal',
        'isActive': true,
        'lastActivityAt': DateTime.now()
            .subtract(const Duration(hours: 3))
            .toIso8601String(),
        'expiresAt': DateTime.now()
            .add(const Duration(days: 25))
            .toIso8601String(),
      },
      {
        'id': 'session-3',
        'deviceId': null,
        'ipAddress': '196.201.207.62',
        'userAgent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/119.0.0.0',
        'location': 'Bamako, Mali',
        'isActive': true,
        'lastActivityAt': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'expiresAt': DateTime.now()
            .add(const Duration(days: 20))
            .toIso8601String(),
      },
    ];
  }
}
