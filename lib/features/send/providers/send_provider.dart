import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';
import 'package:usdc_wallet/services/transfers/transfers_service.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';
import 'package:usdc_wallet/services/app_review/app_review_service.dart';
import 'package:usdc_wallet/services/analytics/analytics_service.dart';
import 'package:usdc_wallet/services/realtime/realtime_service.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/features/offline/providers/offline_provider.dart';
import 'package:usdc_wallet/features/send/models/transfer_request.dart';
import 'package:usdc_wallet/core/haptics/haptic_service.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';

/// Send Money State
class SendMoneyState {
  final bool isLoading;
  final String? error;
  final RecipientInfo? recipient;
  final double? amount;
  final String? note;
  final TransferResult? result;
  final List<RecentRecipient> recentRecipients;
  final double availableBalance;
  final double fee;
  final String? pinToken;
  final String? idempotencyKey;
  final String? pendingTransferId;
  final bool isSubmitting;

  const SendMoneyState({
    this.isLoading = false,
    this.error,
    this.recipient,
    this.amount,
    this.note,
    this.result,
    this.recentRecipients = const [],
    this.availableBalance = 0.0,
    this.fee = 0.0,
    this.pinToken,
    this.idempotencyKey,
    this.pendingTransferId,
    this.isSubmitting = false,
  });

  bool get canProceedToAmount => recipient != null;
  bool get canProceedToConfirm =>
      recipient != null && amount != null && amount! > 0;
  double get total => (amount ?? 0) + fee;
  bool get hasSufficientBalance => availableBalance >= total;

  SendMoneyState copyWith({
    bool? isLoading,
    String? error,
    RecipientInfo? recipient,
    bool clearRecipient = false,
    double? amount,
    String? note,
    TransferResult? result,
    List<RecentRecipient>? recentRecipients,
    double? availableBalance,
    double? fee,
    String? pinToken,
    String? idempotencyKey,
    String? pendingTransferId,
    bool? isSubmitting,
  }) {
    return SendMoneyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      recipient: clearRecipient ? null : recipient ?? this.recipient,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      result: result ?? this.result,
      recentRecipients: recentRecipients ?? this.recentRecipients,
      availableBalance: availableBalance ?? this.availableBalance,
      fee: fee ?? this.fee,
      pinToken: pinToken ?? this.pinToken,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      pendingTransferId: pendingTransferId ?? this.pendingTransferId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  SendMoneyState clearError() => copyWith(error: null);

  SendMoneyState reset() => const SendMoneyState();
}

/// Send Money Notifier
class SendMoneyNotifier extends Notifier<SendMoneyState> {
  @override
  SendMoneyState build() => const SendMoneyState();

  /// Load available balance
  Future<void> loadBalance() async {
    try {
      final walletService = ref.read(walletServiceProvider);
      final balance = await walletService.getBalance();
      state = state.copyWith(availableBalance: balance.availableBalance);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load recent recipients from API
  /// GET /contacts/recents
  Future<void> loadRecentRecipients() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/contacts/recents');

      final recipients = _extractRecentRecipients(response.data);

      state = state.copyWith(isLoading: false, recentRecipients: recipients);
    } on DioException {
      // Non-critical: fall back to empty list
      state = state.copyWith(isLoading: false, recentRecipients: []);
    } catch (e) {
      state = state.copyWith(isLoading: false, recentRecipients: []);
    }
  }

  /// Validate and set recipient
  /// Uses POST /contacts/sync with hashed phone to check if Korido user
  Future<void> setRecipient(String phoneNumber, {String? name}) async {
    state = state.copyWith(isLoading: true, error: null, clearRecipient: true);
    try {
      final dio = ref.read(dioProvider);
      final contactsService = ref.read(contactsServiceProvider);
      final phoneHash = contactsService.hashPhone(
        phoneNumber,
        defaultCountryPrefix: _defaultCountryPrefix(),
      );

      final response = await dio.post(
        '/contacts/sync',
        data: {
          'phoneHashes': [phoneHash],
        },
      );

      final syncData = response.data as Map<String, dynamic>;
      final matches = _extractContactSyncMatches(syncData);
      final isKoridoUser = matches.isNotEmpty;
      if (!isKoridoUser) {
        state = state.copyWith(
          isLoading: false,
          clearRecipient: true,
          error: 'recipient_not_korido_user',
        );
        return;
      }

      String? userId;
      String? displayName = name;
      final match = matches.first;
      userId = match['userId'] as String?;
      displayName =
          displayName ??
          (match['displayName'] as String?) ??
          (match['name'] as String?);

      final recipient = RecipientInfo(
        phoneNumber: phoneNumber,
        name: displayName,
        userId: userId,
        isKoridoUser: isKoridoUser,
      );

      state = state.copyWith(isLoading: false, recipient: recipient);
    } on DioException {
      state = state.copyWith(
        isLoading: false,
        clearRecipient: true,
        error: 'recipient_lookup_unavailable',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearRecipient: true,
        error: e.toString(),
      );
    }
  }

  /// Set transfer amount
  void setAmount(double amount) {
    // Calculate fee (currently 0 for internal transfers)
    const fee = 0.0;
    state = state.copyWith(amount: amount, fee: fee);
  }

  /// Set optional note
  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  /// Restore a queued offline transfer as a draft that requires fresh PIN auth.
  Future<void> resumePendingTransfer({
    required String transferId,
    required String recipientPhone,
    required double amount,
    String? recipientName,
    String? note,
  }) async {
    state = SendMoneyState(
      recipient: RecipientInfo(
        phoneNumber: recipientPhone,
        name: recipientName,
        isKoridoUser: true,
      ),
      amount: amount,
      note: note,
      pendingTransferId: transferId,
    );

    await loadBalance();
  }

  /// Verify PIN and store token for subsequent transfer execution.
  /// Must be called before executeTransfer().
  Future<bool> verifyPin(String pin) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final pinService = ref.read(pinServiceProvider);
      final result = await pinService.verifyPinWithBackend(pin);
      if (result.success && result.pinToken != null) {
        // Generate idempotency key once per user action
        state = state.copyWith(
          isLoading: false,
          pinToken: result.pinToken,
          idempotencyKey: generateIdempotencyKey(),
        );
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        error: result.message ?? 'PIN verification failed',
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Reuse a still-valid backend PIN token, usually after biometric auth.
  Future<bool> useExistingPinToken() async {
    final pinService = ref.read(pinServiceProvider);
    final pinToken = await pinService.getPinToken();
    if (pinToken == null) {
      state = state.copyWith(error: 'PIN is required');
      return false;
    }

    state = state.copyWith(
      pinToken: pinToken,
      idempotencyKey: generateIdempotencyKey(),
      error: null,
    );
    return true;
  }

  /// Execute transfer. Requires verifyPin() to have been called first.
  Future<bool> executeTransfer() async {
    if (!state.canProceedToConfirm) {
      state = state.copyWith(error: 'Invalid transfer details');
      await hapticService.error();
      return false;
    }

    if (!state.hasSufficientBalance) {
      state = state.copyWith(error: 'Insufficient balance');
      await hapticService.warning();
      return false;
    }

    if (state.pinToken == null || state.idempotencyKey == null) {
      state = state.copyWith(error: 'PIN verification required');
      await hapticService.error();
      return false;
    }

    // Prevent double-submit
    if (state.isSubmitting) return false;

    // Payment initiated haptic
    await hapticService.paymentStart();

    state = state.copyWith(isLoading: true, isSubmitting: true, error: null);
    try {
      final transfersService = ref.read(transfersServiceProvider);
      final riskRecipientId =
          state.recipient!.userId ?? state.recipient!.phoneNumber;
      final result = await transfersService.createInternalTransfer(
        recipientPhone: state.recipient!.phoneNumber,
        amount: state.amount!,
        note: state.note,
        riskRecipientId: riskRecipientId,
        pinToken: state.pinToken!,
        idempotencyKey: state.idempotencyKey!,
      );

      state = state.copyWith(
        isLoading: false,
        isSubmitting: false,
        result: result,
      );

      // Immediately refresh balance + transactions
      ref.read(realtimeServiceProvider).refreshAfterTransaction();

      // Payment confirmed haptic
      await hapticService.paymentConfirmed();

      // Analytics: send_money
      ref
          .read(analyticsServiceProvider)
          .trackSendMoney(
            currency: 'USDC',
            recipientType: 'internal',
            success: true,
          );

      // Track successful transaction for app review prompt
      final appReviewService = ref.read(appReviewServiceProvider);
      await appReviewService.trackSuccessfulTransaction();

      if (state.pendingTransferId != null) {
        await ref
            .read(offlineProvider.notifier)
            .cancelPendingTransfer(state.pendingTransferId!);
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSubmitting: false,
        error: e.toString(),
      );
      await hapticService.error();
      return false;
    }
  }

  /// Reset state (e.g., when starting new transfer)
  void reset() {
    state = state.reset();
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }

  String _defaultCountryPrefix() {
    final userCountryCode = ref.read(userStateMachineProvider).countryCode;
    final selectedCountry = ref.read(selectedCountryProvider);
    final country =
        SupportedCountries.findByCode(userCountryCode) ?? selectedCountry;
    return country.prefix;
  }
}

List<Map<String, dynamic>> _extractContactSyncMatches(Object? payload) {
  Object? readKey(Object? source, String key) {
    if (source is Map) {
      return source[key];
    }
    return null;
  }

  var raw = readKey(payload, 'matches');
  raw ??= readKey(readKey(payload, 'data'), 'matches');
  raw ??= readKey(payload, 'users');
  raw ??= readKey(readKey(payload, 'data'), 'users');

  if (raw is! List) {
    return const [];
  }
  return raw.whereType<Map>().map(Map<String, dynamic>.from).toList();
}

List<RecentRecipient> _extractRecentRecipients(Object? payload) {
  Object? readKey(Object? source, String key) {
    if (source is Map) {
      return source[key];
    }
    return null;
  }

  Object? raw = payload is List ? payload : null;
  raw ??= readKey(payload, 'contacts');
  raw ??= readKey(payload, 'recipients');
  raw ??= readKey(payload, 'items');
  raw ??= readKey(readKey(payload, 'data'), 'contacts');
  raw ??= readKey(readKey(payload, 'data'), 'recipients');
  raw ??= readKey(readKey(payload, 'data'), 'items');
  raw ??= readKey(payload, 'data');

  if (raw is! List) return const [];

  return raw.whereType<Map>().map((entry) {
    final map = Map<String, dynamic>.from(entry);
    final phone = _stringValue(map, const [
      'phoneNumber',
      'phone',
      'recipientPhone',
    ]);
    final name =
        _stringValue(map, const ['name', 'displayName', 'recipientName']) ??
        phone;
    final dateValue = map['lastTransferDate'] ?? map['lastTransactionAt'];

    return RecentRecipient(
      phoneNumber: phone ?? '',
      name: name ?? '',
      lastTransferDate: _parseDate(dateValue) ?? DateTime.now(),
      lastAmount: _numValue(map, const ['lastAmount', 'amount']) ?? 0.0,
      isKoridoUser:
          _boolValue(map, const [
            'isKoridoUser',
            'isJoonaPayUser',
            'matched',
          ]) ??
          false,
    );
  }).toList();
}

String? _stringValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

double? _numValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
  }
  return null;
}

bool? _boolValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
  }
  return null;
}

DateTime? _parseDate(Object? value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

/// Send Money Provider
final sendMoneyProvider = NotifierProvider<SendMoneyNotifier, SendMoneyState>(
  SendMoneyNotifier.new,
);
