import 'dart:math';

/// Utilities for generating realistic mock data.
///
/// ```dart
/// MockDataGenerator.uuid();           // 'a1b2c3d4-e5f6-4g7h-8i9j-k0l1m2n3o4p5'
/// MockDataGenerator.email();          // 'john.doe42@gmail.com'
/// MockDataGenerator.fullName();       // 'John Doe'
/// MockDataGenerator.phoneNumber();    // '+1234567890'
/// MockDataGenerator.amount();         // 1234.56
/// MockDataGenerator.pastDate();       // DateTime 1-30 days ago
/// MockDataGenerator.pick(['a','b']);  // Random item
/// ```
class MockDataGenerator {
  MockDataGenerator._();

  static final _random = Random();

  // ==================== IDs ====================

  /// Generate a UUID v4 string.
  static String uuid() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replaceAllMapped(
      RegExp('[xy]'),
      (match) {
        final r = _random.nextInt(16);
        final v = match.group(0) == 'x' ? r : (r & 0x3 | 0x8);
        return v.toRadixString(16);
      },
    );
  }

  /// Generate a short ID (8 characters).
  static String shortId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(8, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  /// Generate a reference number (e.g., for transactions).
  static String reference({String prefix = 'REF'}) {
    return '$prefix${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(9999).toString().padLeft(4, '0')}';
  }

  // ==================== Personal Data ====================

  static final _firstNames = [
    'James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph',
    'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara', 'Susan', 'Jessica',
    'Sarah', 'Karen', 'Nancy', 'Lisa', 'Daniel', 'Matthew', 'Anthony', 'Mark',
  ];

  static final _lastNames = [
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
    'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
    'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson',
  ];

  /// Generate a random first name.
  static String firstName() => _firstNames[_random.nextInt(_firstNames.length)];

  /// Generate a random last name.
  static String lastName() => _lastNames[_random.nextInt(_lastNames.length)];

  /// Generate a random full name.
  static String fullName() => '${firstName()} ${lastName()}';

  /// Generate a random email address.
  static String email() {
    final first = firstName().toLowerCase();
    final last = lastName().toLowerCase();
    final domains = ['gmail.com', 'yahoo.com', 'outlook.com', 'mail.com', 'email.com'];
    return '$first.$last${_random.nextInt(99)}@${domains[_random.nextInt(domains.length)]}';
  }

  /// Generate a random phone number.
  ///
  /// [countryCode] - Country code prefix (default: '+1')
  /// [length] - Number of digits after country code (default: 10)
  static String phoneNumber({String countryCode = '+1', int length = 10}) {
    final digits = List.generate(length, (_) => _random.nextInt(10)).join();
    return '$countryCode$digits';
  }

  /// Generate a random username.
  static String username() {
    final adjectives = ['cool', 'super', 'mega', 'ultra', 'pro', 'epic', 'fast'];
    final nouns = ['user', 'player', 'coder', 'dev', 'ninja', 'master', 'star'];
    return '${adjectives[_random.nextInt(adjectives.length)]}_${nouns[_random.nextInt(nouns.length)]}${_random.nextInt(999)}';
  }

  // ==================== Addresses ====================

  /// Generate a random street address.
  static String streetAddress() {
    final number = _random.nextInt(9999) + 1;
    final streets = ['Main St', 'Oak Ave', 'Maple Dr', 'Cedar Ln', 'Park Blvd', 'First St', 'Second Ave'];
    return '$number ${streets[_random.nextInt(streets.length)]}';
  }

  /// Generate a random city name.
  static String city() {
    final cities = ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego'];
    return cities[_random.nextInt(cities.length)];
  }

  /// Generate a random country code (ISO 3166-1 alpha-2).
  static String countryCode() {
    final codes = ['US', 'CA', 'GB', 'DE', 'FR', 'ES', 'IT', 'AU', 'JP', 'BR'];
    return codes[_random.nextInt(codes.length)];
  }

  /// Generate an Ethereum-style wallet address.
  static String walletAddress() {
    const chars = '0123456789abcdef';
    final address = StringBuffer('0x');
    for (var i = 0; i < 40; i++) {
      address.write(chars[_random.nextInt(chars.length)]);
    }
    return address.toString();
  }

  // ==================== Financial ====================

  /// Generate a random amount.
  ///
  /// [min] - Minimum value (default: 1)
  /// [max] - Maximum value (default: 10000)
  /// [decimals] - Decimal places (default: 2)
  static double amount({double min = 1, double max = 10000, int decimals = 2}) {
    final value = min + _random.nextDouble() * (max - min);
    final factor = pow(10, decimals);
    return (value * factor).round() / factor;
  }

  /// Generate a random integer amount.
  static int intAmount({int min = 1, int max = 10000}) {
    return min + _random.nextInt(max - min);
  }

  /// Generate a random currency code.
  static String currencyCode() {
    final codes = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY', 'CHF', 'CNY'];
    return codes[_random.nextInt(codes.length)];
  }

  /// Generate a random percentage.
  static double percentage({double min = 0, double max = 100, int decimals = 1}) {
    return amount(min: min, max: max, decimals: decimals);
  }

  // ==================== Dates ====================

  /// Generate a date in the past.
  ///
  /// [maxDaysAgo] - Maximum days in the past (default: 30)
  static DateTime pastDate({int maxDaysAgo = 30}) {
    return DateTime.now().subtract(Duration(
      days: _random.nextInt(maxDaysAgo),
      hours: _random.nextInt(24),
      minutes: _random.nextInt(60),
      seconds: _random.nextInt(60),
    ));
  }

  /// Generate a date in the future.
  ///
  /// [maxDaysAhead] - Maximum days in the future (default: 30)
  static DateTime futureDate({int maxDaysAhead = 30}) {
    return DateTime.now().add(Duration(
      days: _random.nextInt(maxDaysAhead) + 1,
      hours: _random.nextInt(24),
      minutes: _random.nextInt(60),
      seconds: _random.nextInt(60),
    ));
  }

  /// Generate an ISO 8601 date string in the past.
  static String isoDatePast({int maxDaysAgo = 30}) {
    return pastDate(maxDaysAgo: maxDaysAgo).toIso8601String();
  }

  /// Generate an ISO 8601 date string in the future.
  static String isoDateFuture({int maxDaysAhead = 30}) {
    return futureDate(maxDaysAhead: maxDaysAhead).toIso8601String();
  }

  // ==================== Utilities ====================

  /// Pick a random item from a list.
  static T pick<T>(List<T> items) {
    if (items.isEmpty) throw ArgumentError('List cannot be empty');
    return items[_random.nextInt(items.length)];
  }

  /// Pick multiple random items from a list.
  static List<T> pickMany<T>(List<T> items, int count) {
    if (count > items.length) {
      throw ArgumentError('Count cannot be greater than list length');
    }
    final shuffled = List<T>.from(items)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// Generate a random boolean.
  ///
  /// [trueChance] - Probability of true (0.0 to 1.0, default: 0.5)
  static bool boolean({double trueChance = 0.5}) {
    return _random.nextDouble() < trueChance;
  }

  /// Generate a random integer.
  static int integer({int min = 0, int max = 100}) {
    return min + _random.nextInt(max - min);
  }

  /// Generate a random string of specified length.
  static String randomString(int length, {bool includeNumbers = true}) {
    final chars = includeNumbers
        ? 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
        : 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return List.generate(length, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  /// Generate lorem ipsum text.
  static String loremIpsum({int words = 10}) {
    const lorem = [
      'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur', 'adipiscing',
      'elit', 'sed', 'do', 'eiusmod', 'tempor', 'incididunt', 'ut', 'labore',
      'et', 'dolore', 'magna', 'aliqua', 'enim', 'ad', 'minim', 'veniam',
    ];
    return List.generate(words, (_) => lorem[_random.nextInt(lorem.length)]).join(' ');
  }

  /// Generate a sentence (capitalized, ends with period).
  static String sentence({int words = 8}) {
    final text = loremIpsum(words: words);
    return '${text[0].toUpperCase()}${text.substring(1)}.';
  }

  /// Generate a paragraph (multiple sentences).
  static String paragraph({int sentences = 4}) {
    return List.generate(sentences, (_) => sentence(words: 6 + _random.nextInt(8))).join(' ');
  }
}
