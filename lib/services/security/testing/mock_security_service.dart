import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock security service for testing.
class MockSecurityService {
  bool _isSecure = true;
  bool _isRooted = false;
  bool _isDebugger = false;

  void setSecure(bool value) => _isSecure = value;
  void setRooted(bool value) => _isRooted = value;
  void setDebugger(bool value) => _isDebugger = value;

  bool get isSecure => _isSecure;
  bool get isRooted => _isRooted;
  bool get isDebuggerAttached => _isDebugger;

  /// Simulate a security check.
  Future<bool> performSecurityCheck() async {
    return _isSecure && !_isRooted && !_isDebugger;
  }
}

final mockSecurityServiceProvider = Provider<MockSecurityService>((ref) {
  return MockSecurityService();
});
