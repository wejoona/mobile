/// Mock Data Generator
///
/// Utilities for generating realistic mock data for testing.
library;

import 'dart:math';

/// Mock data generator utilities
class MockDataGenerator {
  static final _random = Random();

  // ==================== IDs ====================

  /// Generate a UUID v4
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

  /// Generate a transaction reference
  static String transactionRef() {
    return 'TXN${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(9999).toString().padLeft(4, '0')}';
  }

  /// Generate a wallet address (Ethereum-style)
  static String walletAddress() {
    final chars = '0123456789abcdef';
    final address = StringBuffer('0x');
    for (var i = 0; i < 40; i++) {
      address.write(chars[_random.nextInt(chars.length)]);
    }
    return address.toString();
  }

  // ==================== User Data ====================

  static final _firstNames = [
    'Amadou', 'Fatou', 'Moussa', 'Awa', 'Ibrahim', 'Mariam',
    'Oumar', 'Aissatou', 'Mamadou', 'Kadiatou', 'Sekou', 'Aminata',
  ];

  static final _lastNames = [
    'Diallo', 'Traore', 'Coulibaly', 'Keita', 'Camara', 'Toure',
    'Kone', 'Sanogo', 'Diarra', 'Sissoko', 'Barry', 'Bah',
  ];

  /// Generate a random name
  static String fullName() {
    return '${_firstNames[_random.nextInt(_firstNames.length)]} ${_lastNames[_random.nextInt(_lastNames.length)]}';
  }

  static String firstName() => _firstNames[_random.nextInt(_firstNames.length)];
  static String lastName() => _lastNames[_random.nextInt(_lastNames.length)];

  /// Generate a phone number for West African countries
  static String phoneNumber({String countryCode = '+225'}) {
    final digits = StringBuffer();
    for (var i = 0; i < 10; i++) {
      digits.write(_random.nextInt(10));
    }
    return '$countryCode${digits.toString().substring(0, 9)}';
  }

  /// Generate an email
  static String email() {
    final first = firstName().toLowerCase();
    final last = lastName().toLowerCase();
    final domains = ['gmail.com', 'yahoo.fr', 'outlook.com', 'mail.ci'];
    return '$first.$last${_random.nextInt(99)}@${domains[_random.nextInt(domains.length)]}';
  }

  // ==================== Financial Data ====================

  /// Generate a random amount
  static double amount({double min = 1, double max = 10000}) {
    return (min + _random.nextDouble() * (max - min));
  }

  /// Generate a rounded amount (for display)
  static double roundedAmount({double min = 1, double max = 10000}) {
    return (amount(min: min, max: max) * 100).round() / 100;
  }

  /// Generate a balance
  static double balance({double min = 0, double max = 50000}) {
    return roundedAmount(min: min, max: max);
  }

  /// Currency codes for West Africa
  static final _currencies = ['XOF', 'XAF', 'GNF', 'NGN'];

  static String currency() => _currencies[_random.nextInt(_currencies.length)];

  // ==================== Dates ====================

  /// Generate a date within the last N days
  static DateTime pastDate({int maxDaysAgo = 30}) {
    return DateTime.now().subtract(Duration(
      days: _random.nextInt(maxDaysAgo),
      hours: _random.nextInt(24),
      minutes: _random.nextInt(60),
    ));
  }

  /// Generate a date within the next N days
  static DateTime futureDate({int maxDaysAhead = 30}) {
    return DateTime.now().add(Duration(
      days: _random.nextInt(maxDaysAhead),
      hours: _random.nextInt(24),
      minutes: _random.nextInt(60),
    ));
  }

  /// Generate an ISO 8601 date string
  static String isoDate({int maxDaysAgo = 30}) {
    return pastDate(maxDaysAgo: maxDaysAgo).toIso8601String();
  }

  // ==================== Lists & Selection ====================

  /// Pick a random item from a list
  static T pick<T>(List<T> items) {
    return items[_random.nextInt(items.length)];
  }

  /// Pick N random items from a list
  static List<T> pickMany<T>(List<T> items, int count) {
    final shuffled = List<T>.from(items)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// Generate a random boolean
  static bool boolean({double trueChance = 0.5}) {
    return _random.nextDouble() < trueChance;
  }

  /// Generate a random integer
  static int integer({int min = 0, int max = 100}) {
    return min + _random.nextInt(max - min);
  }

  // ==================== Text ====================

  static final _words = [
    'payment', 'transfer', 'deposit', 'withdrawal', 'purchase',
    'refund', 'fee', 'commission', 'salary', 'rent', 'groceries',
    'transport', 'utilities', 'mobile', 'airtime', 'subscription',
  ];

  /// Generate a random note/description
  static String note({int wordCount = 3}) {
    return pickMany(_words, wordCount).join(' ').capitalize();
  }

  /// Generate a transaction description
  static String transactionDescription() {
    final types = [
      'Payment for services',
      'Monthly transfer',
      'Bill payment',
      'Mobile money deposit',
      'Salary payment',
      'Refund',
      'Commission',
    ];
    return pick(types);
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
