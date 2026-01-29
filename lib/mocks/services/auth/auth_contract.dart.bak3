/// Auth API Contract
///
/// Defines the interface for authentication endpoints.
/// This serves as the specification for backend implementation.
library;

import '../../base/api_contract.dart';

// ==================== REQUEST/RESPONSE TYPES ====================

/// Login request
class LoginRequest {
  final String phone;

  const LoginRequest({required this.phone});

  Map<String, dynamic> toJson() => {'phone': phone};
}

/// Register request
class RegisterRequest {
  final String phone;
  final String countryCode;

  const RegisterRequest({required this.phone, required this.countryCode});

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'countryCode': countryCode,
  };
}

/// Verify OTP request
class VerifyOtpRequest {
  final String phone;
  final String otp;

  const VerifyOtpRequest({required this.phone, required this.otp});

  Map<String, dynamic> toJson() => {'phone': phone, 'otp': otp};
}

/// Auth tokens response
class AuthTokensResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserResponse user;

  const AuthTokensResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresIn': expiresIn,
    'user': user.toJson(),
  };
}

/// User response
class UserResponse {
  final String id;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String countryCode;
  final String kycStatus;
  final bool hasPinSet;
  final DateTime createdAt;

  const UserResponse({
    required this.id,
    required this.phone,
    this.firstName,
    this.lastName,
    this.email,
    required this.countryCode,
    required this.kycStatus,
    required this.hasPinSet,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'countryCode': countryCode,
    'kycStatus': kycStatus,
    'hasPinSet': hasPinSet,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// Refresh token request
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

/// OTP sent response
class OtpSentResponse {
  final String message;
  final int expiresIn;

  const OtpSentResponse({required this.message, required this.expiresIn});

  Map<String, dynamic> toJson() => {
    'message': message,
    'expiresIn': expiresIn,
  };
}

// ==================== CONTRACT ====================

/// Auth API Contract
class AuthContract extends ApiContract {
  @override
  String get serviceName => 'Auth';

  @override
  String get basePath => '/auth';

  // Endpoint definitions
  static const login = ApiEndpoint(
    path: '/login',
    method: HttpMethod.post,
    description: 'Request OTP for login',
    requestType: LoginRequest,
    responseType: OtpSentResponse,
    requiresAuth: false,
  );

  static const register = ApiEndpoint(
    path: '/register',
    method: HttpMethod.post,
    description: 'Register a new user and request OTP',
    requestType: RegisterRequest,
    responseType: OtpSentResponse,
    requiresAuth: false,
  );

  static const verifyOtp = ApiEndpoint(
    path: '/verify-otp',
    method: HttpMethod.post,
    description: 'Verify OTP and get auth tokens',
    requestType: VerifyOtpRequest,
    responseType: AuthTokensResponse,
    requiresAuth: false,
  );

  static const refresh = ApiEndpoint(
    path: '/refresh',
    method: HttpMethod.post,
    description: 'Refresh access token',
    requestType: RefreshTokenRequest,
    responseType: AuthTokensResponse,
    requiresAuth: false,
  );

  static const logout = ApiEndpoint(
    path: '/logout',
    method: HttpMethod.post,
    description: 'Logout and invalidate tokens',
    requiresAuth: true,
  );

  static const me = ApiEndpoint(
    path: '/me',
    method: HttpMethod.get,
    description: 'Get current user profile',
    responseType: UserResponse,
    requiresAuth: true,
  );

  static const updateProfile = ApiEndpoint(
    path: '/me',
    method: HttpMethod.patch,
    description: 'Update user profile',
    responseType: UserResponse,
    requiresAuth: true,
  );

  @override
  List<ApiEndpoint> get endpoints => [
    login,
    register,
    verifyOtp,
    refresh,
    logout,
    me,
    updateProfile,
  ];
}
