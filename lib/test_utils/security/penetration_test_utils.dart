/// Utilities for security penetration testing.
///
/// These helpers simulate common attack vectors for testing
/// the app's defenses in a controlled environment.
class PenetrationTestUtils {
  /// Generate SQL injection test payloads.
  static List<String> sqlInjectionPayloads() {
    return [
      "' OR '1'='1",
      "'; DROP TABLE users; --",
      "1' UNION SELECT * FROM users--",
      "admin'--",
      "' OR 1=1--",
    ];
  }

  /// Generate XSS test payloads.
  static List<String> xssPayloads() {
    return [
      '<script>alert("xss")</script>',
      '<img src=x onerror=alert(1)>',
      'javascript:alert(1)',
      '<svg onload=alert(1)>',
      '"><script>alert(1)</script>',
    ];
  }

  /// Generate buffer overflow test strings.
  static List<String> overflowPayloads() {
    return [
      'A' * 256,
      'A' * 1024,
      'A' * 10000,
      '\x00' * 100,
    ];
  }

  /// Generate malformed JSON payloads.
  static List<String> malformedJsonPayloads() {
    return [
      '{',
      '{"key":}',
      '{"key": undefined}',
      '{"key": NaN}',
      '[[[[[[[[[[[',
      '{"a":"b"' * 1000,
    ];
  }

  /// Generate path traversal payloads.
  static List<String> pathTraversalPayloads() {
    return [
      '../../../etc/passwd',
      '..\\..\\..\\windows\\system32',
      '%2e%2e%2f%2e%2e%2f',
      '....//....//....//etc/passwd',
    ];
  }
}
