/// Registration request model
class RegistrationRequest {
  final String phoneNumber;
  final String countryCode;

  const RegistrationRequest({
    required this.phoneNumber,
    required this.countryCode,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'countryCode': countryCode,
  };
}

/// OTP verification request
class OtpVerificationRequest {
  final String phoneNumber;
  final String otp;

  const OtpVerificationRequest({
    required this.phoneNumber,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'otp': otp,
  };
}

/// Profile setup request
class ProfileSetupRequest {
  final String firstName;
  final String lastName;
  final String? email;

  const ProfileSetupRequest({
    required this.firstName,
    required this.lastName,
    this.email,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    if (email != null && email!.isNotEmpty) 'email': email,
  };
}

/// PIN setup request
class PinSetupRequest {
  final String pin;

  const PinSetupRequest({
    required this.pin,
  });

  Map<String, dynamic> toJson() => {
    'pin': pin,
  };
}
