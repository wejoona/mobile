import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock authentication service for testing.
class MockAuthService {
  bool _isAuthenticated = false;
  bool _mfaVerified = false;
  String? _currentUser;

  Future<bool> login(String phone, String pin) async {
    _isAuthenticated = true;
    _currentUser = phone;
    return true;
  }

  Future<bool> verifyMfa(String code) async {
    _mfaVerified = true;
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _mfaVerified = false;
    _currentUser = null;
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isMfaVerified => _mfaVerified;
  String? get currentUser => _currentUser;
}

final mockAuthServiceProvider = Provider<MockAuthService>((ref) {
  return MockAuthService();
});
