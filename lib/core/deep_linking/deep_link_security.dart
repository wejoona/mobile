import 'package:flutter/foundation.dart';

/// Security validation for deep link parameters
class DeepLinkSecurity {
  /// Validate phone number (E.164 format)
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    return RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(phone);
  }

  /// Validate amount (must be positive, max 1M USDC)
  static bool isValidAmount(String? amount) {
    if (amount == null || amount.isEmpty) return false;

    final parsed = double.tryParse(amount);
    if (parsed == null) return false;
    if (parsed <= 0) return false;
    if (parsed > 1000000) return false; // Max 1M USDC

    return true;
  }

  /// Validate UUID (version 4)
  static bool isValidUuid(String? id) {
    if (id == null || id.isEmpty) return false;

    return RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).hasMatch(id);
  }

  /// Validate payment link code (alphanumeric, 4-20 chars)
  static bool isValidLinkCode(String? code) {
    if (code == null || code.isEmpty) return false;
    if (code.length < 4 || code.length > 20) return false;

    return RegExp(r'^[A-Za-z0-9]+$').hasMatch(code);
  }

  /// Validate referral code (alphanumeric, 4-16 chars)
  static bool isValidReferralCode(String? code) {
    if (code == null || code.isEmpty) return false;
    if (code.length < 4 || code.length > 16) return false;

    return RegExp(r'^[A-Za-z0-9]+$').hasMatch(code);
  }

  /// Sanitize note/text input (prevent XSS, SQL injection)
  static String sanitizeText(String? text) {
    if (text == null || text.isEmpty) return '';

    // Remove null bytes
    String sanitized = text.replaceAll('\u0000', '');

    // Limit length
    if (sanitized.length > 500) {
      sanitized = sanitized.substring(0, 500);
    }

    // HTML encode special characters
    sanitized = _htmlEncode(sanitized);

    return sanitized;
  }

  /// HTML encode string
  static String _htmlEncode(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// Validate deep link domain (prevent phishing)
  static bool isValidDeepLinkDomain(Uri uri) {
    // Allow custom scheme
    if (uri.scheme == 'joonapay') return true;

    // Allow only trusted domains for universal links
    if (uri.scheme == 'https') {
      final allowedHosts = [
        'app.joonapay.com',
        'joonapay.com',
        // Add staging/dev domains if needed
      ];

      return allowedHosts.contains(uri.host.toLowerCase());
    }

    return false;
  }

  /// Check for suspicious patterns
  static bool isSuspiciousLink(Uri uri) {
    // ignore: unused_local_variable
    final __path = uri.path.toLowerCase();
    final params = uri.queryParameters;

    // Check for excessive parameters (> 10)
    if (params.length > 10) {
      debugPrint('Suspicious: Too many parameters');
      return true;
    }

    // Check for extremely long parameter values
    for (final value in params.values) {
      if (value.length > 1000) {
        debugPrint('Suspicious: Parameter too long');
        return true;
      }
    }

    // Check for SQL injection patterns
    final sqlPatterns = [
      'select ',
      'insert ',
      'update ',
      'delete ',
      'drop ',
      'union ',
      'exec ',
      '--',
      ';--',
      'xp_',
    ];

    for (final value in params.values) {
      final lower = value.toLowerCase();
      for (final pattern in sqlPatterns) {
        if (lower.contains(pattern)) {
          debugPrint('Suspicious: SQL pattern detected');
          return true;
        }
      }
    }

    // Check for XSS patterns
    final xssPatterns = [
      '<script',
      'javascript:',
      'onerror=',
      'onload=',
      '<iframe',
    ];

    for (final value in params.values) {
      final lower = value.toLowerCase();
      for (final pattern in xssPatterns) {
        if (lower.contains(pattern)) {
          debugPrint('Suspicious: XSS pattern detected');
          return true;
        }
      }
    }

    return false;
  }

  /// Validate and sanitize deep link parameters
  static Map<String, dynamic> validateParameters({
    required String path,
    required Map<String, String> params,
  }) {
    final validated = <String, dynamic>{};

    // Validate based on path
    if (path.contains('send')) {
      // Validate phone number
      if (params.containsKey('to')) {
        final phone = params['to']!;
        if (isValidPhoneNumber(phone)) {
          validated['to'] = phone;
        } else {
          throw InvalidPhoneNumberException(phone);
        }
      }

      // Validate amount
      if (params.containsKey('amount')) {
        final amount = params['amount']!;
        if (isValidAmount(amount)) {
          validated['amount'] = double.parse(amount);
        } else {
          throw InvalidAmountException(amount);
        }
      }

      // Sanitize note
      if (params.containsKey('note')) {
        validated['note'] = sanitizeText(params['note']);
      }
    }

    if (path.contains('receive')) {
      // Validate amount
      if (params.containsKey('amount')) {
        final amount = params['amount']!;
        if (isValidAmount(amount)) {
          validated['amount'] = double.parse(amount);
        } else {
          throw InvalidAmountException(amount);
        }
      }
    }

    if (path.contains('transaction')) {
      // Extract and validate UUID from path
      final parts = path.split('/');
      if (parts.length >= 2) {
        final id = parts[1];
        if (isValidUuid(id)) {
          validated['id'] = id;
        } else {
          throw InvalidUuidException(id);
        }
      }
    }

    if (path.contains('pay') || path.contains('payment-link')) {
      // Extract and validate link code from path
      final parts = path.split('/');
      if (parts.length >= 2) {
        final code = parts[1];
        if (isValidLinkCode(code)) {
          validated['code'] = code;
        } else {
          throw InvalidLinkCodeException(code);
        }
      }
    }

    if (path.contains('referral')) {
      // Validate referral code
      if (params.containsKey('code')) {
        final code = params['code']!;
        if (isValidReferralCode(code)) {
          validated['code'] = code;
        } else {
          throw InvalidReferralCodeException(code);
        }
      }
    }

    return validated;
  }

  /// Rate limiting check (simple in-memory implementation)
  static final Map<String, List<DateTime>> _rateLimitCache = {};
  static const int _maxRequestsPerMinute = 10;

  static bool checkRateLimit(String userId) {
    final now = DateTime.now();
    final minuteAgo = now.subtract(const Duration(minutes: 1));

    // Get or create rate limit list for user
    _rateLimitCache[userId] ??= [];

    // Remove old entries
    _rateLimitCache[userId]!
        .removeWhere((timestamp) => timestamp.isBefore(minuteAgo));

    // Check if over limit
    if (_rateLimitCache[userId]!.length >= _maxRequestsPerMinute) {
      debugPrint('Rate limit exceeded for user: $userId');
      return false;
    }

    // Add current request
    _rateLimitCache[userId]!.add(now);
    return true;
  }
}

// Custom exceptions
class InvalidPhoneNumberException implements Exception {
  final String phone;
  InvalidPhoneNumberException(this.phone);

  @override
  String toString() => 'Invalid phone number: $phone';
}

class InvalidAmountException implements Exception {
  final String amount;
  InvalidAmountException(this.amount);

  @override
  String toString() => 'Invalid amount: $amount';
}

class InvalidUuidException implements Exception {
  final String id;
  InvalidUuidException(this.id);

  @override
  String toString() => 'Invalid UUID: $id';
}

class InvalidLinkCodeException implements Exception {
  final String code;
  InvalidLinkCodeException(this.code);

  @override
  String toString() => 'Invalid link code: $code';
}

class InvalidReferralCodeException implements Exception {
  final String code;
  InvalidReferralCodeException(this.code);

  @override
  String toString() => 'Invalid referral code: $code';
}

class RateLimitExceededException implements Exception {
  @override
  String toString() => 'Rate limit exceeded. Please try again later.';
}

class SuspiciousLinkException implements Exception {
  @override
  String toString() => 'Suspicious link detected and blocked.';
}
