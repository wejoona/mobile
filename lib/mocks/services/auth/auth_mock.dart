/// Auth Mock Implementation
///
/// Mock handlers for authentication endpoints.
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import '../../base/api_contract.dart';
import '../../base/mock_data_generator.dart';
import '../../base/mock_interceptor.dart';
import 'auth_contract.dart';

/// Auth mock state (simulates backend state)
class AuthMockState {
  static String? currentUserId;
  static String? currentPhone;
  static String? pendingOtp;
  static DateTime? otpExpiry;
  static final Map<String, UserResponse> users = {};
  static final Map<String, String> refreshTokens = {};

  static void reset() {
    currentUserId = null;
    currentPhone = null;
    pendingOtp = null;
    otpExpiry = null;
    users.clear();
    refreshTokens.clear();
  }

  /// Generate and store OTP for a phone
  static String generateOtp(String phone) {
    pendingOtp = '123456'; // Dev OTP for easy testing
    otpExpiry = DateTime.now().add(const Duration(minutes: 5));
    currentPhone = phone;
    return pendingOtp!;
  }

  /// Verify OTP
  static bool verifyOtp(String phone, String otp) {
    if (currentPhone != phone) return false;
    if (pendingOtp != otp) return false;
    if (otpExpiry != null && DateTime.now().isAfter(otpExpiry!)) return false;
    return true;
  }

  /// Get or create user for phone
  static UserResponse getOrCreateUser(String phone, {String? countryCode}) {
    if (users.containsKey(phone)) {
      return users[phone]!;
    }

    final user = UserResponse(
      id: MockDataGenerator.uuid(),
      phone: phone,
      firstName: MockDataGenerator.firstName(),
      lastName: MockDataGenerator.lastName(),
      countryCode: countryCode ?? 'CI',
      kycStatus: 'not_started',
      hasPinSet: false,
      createdAt: DateTime.now(),
    );

    users[phone] = user;
    return user;
  }

  /// Generate auth tokens
  /// Creates mock JWT-formatted tokens for testing
  static AuthTokensResponse generateTokens(UserResponse user) {
    // Generate JWT-like tokens (base64 encoded header.payload.signature)
    final header = _base64UrlEncode('{"alg":"HS256","typ":"JWT"}');
    final accessPayload = _base64UrlEncode(
      '{"sub":"${user.id}","phone":"${user.phone}","iat":${DateTime.now().millisecondsSinceEpoch ~/ 1000},"exp":${(DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600}}'
    );
    final refreshPayload = _base64UrlEncode(
      '{"sub":"${user.id}","type":"refresh","iat":${DateTime.now().millisecondsSinceEpoch ~/ 1000},"exp":${(DateTime.now().millisecondsSinceEpoch ~/ 1000) + 604800}}'
    );
    final signature = _base64UrlEncode('mock_signature_${user.id}');

    final accessToken = '$header.$accessPayload.$signature';
    final refreshToken = '$header.$refreshPayload.$signature';

    refreshTokens[refreshToken] = user.id;
    currentUserId = user.id;

    return AuthTokensResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: 3600,
      user: user,
    );
  }

  /// Base64 URL encode without padding
  static String _base64UrlEncode(String input) {
    return base64Url.encode(utf8.encode(input)).replaceAll('=', '');
  }

  /// Get user from refresh token
  static UserResponse? getUserFromRefreshToken(String refreshToken) {
    // First check exact match (for tokens we generated)
    final userId = refreshTokens[refreshToken];
    if (userId != null) {
      return users.values.firstWhere(
        (u) => u.id == userId,
        orElse: () => throw Exception('User not found'),
      );
    }

    // Try to decode JWT and find user (for persisted tokens)
    try {
      final parts = refreshToken.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final sub = data['sub'] as String?;

      if (sub != null) {
        return users.values.firstWhere(
          (u) => u.id == sub,
          orElse: () => throw Exception('User not found'),
        );
      }
    } catch (e) {
      // Token decode failed
    }

    return null;
  }
}

/// Auth mock handlers
class AuthMock {
  /// Register all auth mock handlers
  static void register(MockInterceptor interceptor) {
    // POST /auth/login
    interceptor.register(
      method: 'POST',
      path: '/auth/login',
      handler: _handleLogin,
    );

    // POST /auth/register
    interceptor.register(
      method: 'POST',
      path: '/auth/register',
      handler: _handleRegister,
    );

    // POST /auth/verify-otp
    interceptor.register(
      method: 'POST',
      path: '/auth/verify-otp',
      handler: _handleVerifyOtp,
    );

    // POST /auth/refresh
    interceptor.register(
      method: 'POST',
      path: '/auth/refresh',
      handler: _handleRefresh,
    );

    // POST /auth/logout
    interceptor.register(
      method: 'POST',
      path: '/auth/logout',
      handler: _handleLogout,
    );

    // GET /auth/me
    interceptor.register(
      method: 'GET',
      path: '/auth/me',
      handler: _handleGetMe,
    );

    // PATCH /auth/me
    interceptor.register(
      method: 'PATCH',
      path: '/auth/me',
      handler: _handleUpdateProfile,
    );
  }

  /// Handle login request
  static Future<MockResponse> _handleLogin(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>?;
    final phone = data?['phone'] as String?;

    if (phone == null || phone.isEmpty) {
      return MockResponse.badRequest('Phone number is required');
    }

    // Check if user exists (for login, user should exist)
    // For this mock, we allow login for any phone
    AuthMockState.generateOtp(phone);

    return MockResponse.success({
      'message': 'OTP sent successfully',
      'expiresIn': 300,
    });
  }

  /// Handle register request
  static Future<MockResponse> _handleRegister(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>?;
    final phone = data?['phone'] as String?;
    final countryCode = data?['countryCode'] as String?;

    if (phone == null || phone.isEmpty) {
      return MockResponse.badRequest('Phone number is required');
    }

    if (countryCode == null || countryCode.isEmpty) {
      return MockResponse.badRequest('Country code is required');
    }

    // Check if user already exists
    if (AuthMockState.users.containsKey(phone)) {
      return MockResponse.badRequest('User already exists');
    }

    AuthMockState.generateOtp(phone);

    return MockResponse.success({
      'message': 'OTP sent successfully',
      'expiresIn': 300,
    });
  }

  /// Handle verify OTP request
  static Future<MockResponse> _handleVerifyOtp(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>?;
    final phone = data?['phone'] as String?;
    final otp = data?['otp'] as String?;

    if (phone == null || otp == null) {
      return MockResponse.badRequest('Phone and OTP are required');
    }

    if (!AuthMockState.verifyOtp(phone, otp)) {
      return MockResponse.badRequest('Invalid or expired OTP');
    }

    // Get or create user
    final user = AuthMockState.getOrCreateUser(phone);
    final tokens = AuthMockState.generateTokens(user);

    return MockResponse.success(tokens.toJson());
  }

  /// Handle refresh token request
  static Future<MockResponse> _handleRefresh(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>?;
    final refreshToken = data?['refreshToken'] as String?;

    if (refreshToken == null) {
      return MockResponse.badRequest('Refresh token is required');
    }

    try {
      final user = AuthMockState.getUserFromRefreshToken(refreshToken);
      if (user == null) {
        return MockResponse.unauthorized('Invalid refresh token');
      }

      final tokens = AuthMockState.generateTokens(user);
      return MockResponse.success(tokens.toJson());
    } catch (e) {
      return MockResponse.unauthorized('Invalid refresh token');
    }
  }

  /// Handle logout request
  static Future<MockResponse> _handleLogout(RequestOptions options) async {
    AuthMockState.currentUserId = null;
    return MockResponse.noContent();
  }

  /// Handle get me request
  static Future<MockResponse> _handleGetMe(RequestOptions options) async {
    if (AuthMockState.currentUserId == null) {
      return MockResponse.unauthorized();
    }

    final user = AuthMockState.users.values.firstWhere(
      (u) => u.id == AuthMockState.currentUserId,
      orElse: () => throw Exception('User not found'),
    );

    return MockResponse.success(user.toJson());
  }

  /// Handle update profile request
  static Future<MockResponse> _handleUpdateProfile(
    RequestOptions options,
  ) async {
    if (AuthMockState.currentUserId == null) {
      return MockResponse.unauthorized();
    }

    final data = options.data as Map<String, dynamic>?;
    final currentUser = AuthMockState.users.values.firstWhere(
      (u) => u.id == AuthMockState.currentUserId,
    );

    // Create updated user
    final updatedUser = UserResponse(
      id: currentUser.id,
      phone: currentUser.phone,
      firstName: data?['firstName'] ?? currentUser.firstName,
      lastName: data?['lastName'] ?? currentUser.lastName,
      email: data?['email'] ?? currentUser.email,
      countryCode: currentUser.countryCode,
      kycStatus: currentUser.kycStatus,
      hasPinSet: currentUser.hasPinSet,
      createdAt: currentUser.createdAt,
    );

    AuthMockState.users[currentUser.phone] = updatedUser;

    return MockResponse.success(updatedUser.toJson());
  }
}
