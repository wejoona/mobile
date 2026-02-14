import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for sharing data between main app and widgets
/// Uses app groups on iOS and shared preferences on Android
class WidgetDataService {
  static const String _balanceKey = 'widget_balance';
  static const String _currencyKey = 'widget_currency';
  static const String _lastTransactionKey = 'widget_last_transaction';
  static const String _lastUpdatedKey = 'widget_last_updated';
  static const String _userNameKey = 'widget_user_name';

  // iOS App Group identifier (must match Info.plist and widget target)
  static const String iosAppGroup = 'group.com.joonapay.usdcwallet';

  final FlutterSecureStorage _secureStorage;
  final Future<SharedPreferences> _prefs;

  WidgetDataService()
      : _secureStorage = const FlutterSecureStorage(
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
            groupId: iosAppGroup,
          ),
          aOptions: AndroidOptions(
          ),
        ),
        _prefs = SharedPreferences.getInstance();

  /// Update widget data with current balance
  Future<void> updateBalance({
    required double balance,
    required String currency,
    String? userName,
  }) async {
    final timestamp = DateTime.now().toIso8601String();

    // Store in secure storage (accessible by widgets)
    await _secureStorage.write(
      key: _balanceKey,
      value: balance.toString(),
      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
        groupId: iosAppGroup,
      ),
    );

    // Store in shared preferences for faster access
    final prefs = await _prefs;
    await prefs.setDouble(_balanceKey, balance);
    await prefs.setString(_currencyKey, currency);
    await prefs.setString(_lastUpdatedKey, timestamp);
    if (userName != null) {
      await prefs.setString(_userNameKey, userName);
    }
  }

  /// Update last transaction info for widget
  Future<void> updateLastTransaction({
    required String type,
    required double amount,
    required String currency,
    required String status,
    String? recipientName,
  }) async {
    final transaction = {
      'type': type,
      'amount': amount,
      'currency': currency,
      'status': status,
      'recipientName': recipientName,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final prefs = await _prefs;
    await prefs.setString(_lastTransactionKey, jsonEncode(transaction));
  }

  /// Get current widget data
  Future<WidgetData?> getWidgetData() async {
    try {
      final prefs = await _prefs;

      final balance = prefs.getDouble(_balanceKey);
      final currency = prefs.getString(_currencyKey);
      final lastUpdated = prefs.getString(_lastUpdatedKey);
      final userName = prefs.getString(_userNameKey);
      final lastTransactionJson = prefs.getString(_lastTransactionKey);

      if (balance == null || currency == null) {
        return null;
      }

      Map<String, dynamic>? lastTransaction;
      if (lastTransactionJson != null) {
        lastTransaction = jsonDecode(lastTransactionJson);
      }

      return WidgetData(
        balance: balance,
        currency: currency,
        lastUpdated: lastUpdated != null ? DateTime.parse(lastUpdated) : null,
        userName: userName,
        lastTransaction: lastTransaction,
      );
    } catch (e) {
      return null;
    }
  }

  /// Clear widget data (on logout)
  Future<void> clearWidgetData() async {
    await _secureStorage.delete(
      key: _balanceKey,
      iOptions: const IOSOptions(groupId: iosAppGroup),
    );

    final prefs = await _prefs;
    await prefs.remove(_balanceKey);
    await prefs.remove(_currencyKey);
    await prefs.remove(_lastUpdatedKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_lastTransactionKey);
  }
}

/// Widget data model
class WidgetData {
  final double balance;
  final String currency;
  final DateTime? lastUpdated;
  final String? userName;
  final Map<String, dynamic>? lastTransaction;

  WidgetData({
    required this.balance,
    required this.currency,
    this.lastUpdated,
    this.userName,
    this.lastTransaction,
  });

  String get formattedBalance {
    if (currency == 'XOF') {
      return 'XOF ${balance.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]} ',
          )}';
    }
    return '\$ ${balance.toStringAsFixed(2)}';
  }

  String get lastTransactionDescription {
    if (lastTransaction == null) return '';

    final type = lastTransaction!['type'] as String;
    final amount = lastTransaction!['amount'] as double;
    final recipientName = lastTransaction!['recipientName'] as String?;

    if (type == 'send' && recipientName != null) {
      return 'Sent \$${amount.toStringAsFixed(2)} to $recipientName';
    } else if (type == 'receive' && recipientName != null) {
      return 'Received \$${amount.toStringAsFixed(2)} from $recipientName';
    } else if (type == 'send') {
      return 'Sent \$${amount.toStringAsFixed(2)}';
    } else if (type == 'receive') {
      return 'Received \$${amount.toStringAsFixed(2)}';
    }

    return '';
  }
}
