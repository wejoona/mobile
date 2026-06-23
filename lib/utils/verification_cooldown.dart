int normalizeVerificationCooldownSeconds(int seconds) {
  if (seconds <= 0) return 60;
  if (seconds > 3600) return 3600;
  return seconds;
}

String formatVerificationCooldownDuration(int seconds) {
  final waitSeconds = normalizeVerificationCooldownSeconds(seconds);
  final minutes = (waitSeconds / 60).ceil();
  if (waitSeconds < 60) {
    return '$waitSeconds seconds';
  }
  return '$minutes minute${minutes == 1 ? '' : 's'}';
}

String verificationCooldownMessage({
  required int seconds,
  String? reason,
  String Function(int seconds)? formatWait,
}) {
  final normalizedSeconds = normalizeVerificationCooldownSeconds(seconds);
  final wait =
      formatWait?.call(normalizedSeconds) ??
      'You can request another in ${formatVerificationCooldownDuration(normalizedSeconds)}';
  final prefix = switch (reason) {
    'route_throttle' ||
    'otp_request_limit' ||
    'verification_rate_limited' => 'Too many verification requests.',
    'verification_attempts_rate_limited' => 'Too many code attempts.',
    'provider_rate_limit' => 'Verification provider cooldown is active.',
    _ => 'Use the verification code already sent.',
  };

  return '$prefix $wait.';
}

String? verificationCooldownReason(Object? raw) {
  return verificationApiErrorString(raw, 'cooldownReason');
}

String? verificationApiErrorString(Object? raw, String key) {
  if (raw is Map<String, dynamic>) {
    final direct = raw[key];
    if (direct != null) return direct.toString();
    final error = raw['error'];
    if (error is Map) {
      final nested = error[key];
      if (nested != null) return nested.toString();
      final context = error['context'];
      if (context is Map && context[key] != null) {
        return context[key].toString();
      }
    }
    final context = raw['context'];
    if (context is Map && context[key] != null) {
      return context[key].toString();
    }
  } else if (raw is Map) {
    final normalized = <String, dynamic>{};
    raw.forEach((mapKey, value) {
      normalized[mapKey.toString()] = value;
    });
    return verificationApiErrorString(normalized, key);
  }
  return null;
}
