import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/features/limits/models/transaction_limits.dart';
import 'package:usdc_wallet/features/limits/utils/money_flow_limit_errors.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';
import 'package:usdc_wallet/services/limits/limits_service.dart';
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
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

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
  final bool isBalanceLoading;
  final bool hasVerifiedBalance;
  final String? balanceError;
  final double fee;
  final String? pinToken;
  final String? idempotencyKey;
  final String? stepUpChallengeToken;
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
    this.isBalanceLoading = false,
    this.hasVerifiedBalance = false,
    this.balanceError,
    this.fee = 0.0,
    this.pinToken,
    this.idempotencyKey,
    this.stepUpChallengeToken,
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
    bool? isBalanceLoading,
    bool? hasVerifiedBalance,
    String? balanceError,
    bool clearBalanceError = false,
    double? fee,
    String? pinToken,
    String? idempotencyKey,
    String? stepUpChallengeToken,
    bool clearStepUpChallengeToken = false,
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
      isBalanceLoading: isBalanceLoading ?? this.isBalanceLoading,
      hasVerifiedBalance: hasVerifiedBalance ?? this.hasVerifiedBalance,
      balanceError: clearBalanceError
          ? null
          : balanceError ?? this.balanceError,
      fee: fee ?? this.fee,
      pinToken: pinToken ?? this.pinToken,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      stepUpChallengeToken: clearStepUpChallengeToken
          ? null
          : stepUpChallengeToken ?? this.stepUpChallengeToken,
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
    state = state.copyWith(
      isBalanceLoading: true,
      hasVerifiedBalance: false,
      clearBalanceError: true,
    );
    try {
      final walletService = ref.read(walletServiceProvider);
      final balance = await walletService.getBalance();
      state = state.copyWith(
        isBalanceLoading: false,
        hasVerifiedBalance: true,
        availableBalance: balance.availableBalance,
        clearBalanceError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isBalanceLoading: false,
        hasVerifiedBalance: false,
        balanceError: e.toString(),
      );
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
    state = state.copyWith(
      isLoading: true,
      error: null,
      clearRecipient: true,
      clearStepUpChallengeToken: true,
    );
    try {
      if (_isCurrentUserPhone(phoneNumber)) {
        state = state.copyWith(
          isLoading: false,
          clearRecipient: true,
          error: 'recipient_is_current_user',
        );
        return;
      }

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

      String? displayName = name;
      final match = matches.first;
      final userId = _stringValue(match, const [
        'userId',
        'koridoUserId',
        'joonaPayUserId',
        'id',
      ]);
      displayName =
          displayName ??
          _displayNameValue(match) ??
          _stringValue(match, const ['username', 'handle']);

      final recipient = RecipientInfo(
        phoneNumber: phoneNumber,
        name: displayName,
        userId: userId,
        username: _stringValue(match, const ['username', 'handle']),
        isKoridoUser: isKoridoUser,
      );
      if (_isCurrentUserRecipient(recipient)) {
        state = state.copyWith(
          isLoading: false,
          clearRecipient: true,
          error: 'recipient_is_current_user',
        );
        return;
      }

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

  Future<void> setKnownKoridoRecipient({
    String? phoneNumber,
    String? username,
    String? name,
    String? userId,
  }) async {
    final normalizedPhone = _canonicalRecipientPhone(phoneNumber);
    final normalizedUsername = _normalizeUsername(username);
    if (normalizedPhone.isEmpty &&
        (userId == null || userId.trim().isEmpty) &&
        (normalizedUsername == null || normalizedUsername.isEmpty)) {
      state = state.copyWith(
        clearRecipient: true,
        error: 'recipient_identifier_required',
      );
      return;
    }

    final recipient = RecipientInfo(
      phoneNumber: normalizedPhone,
      name: name,
      userId: userId,
      username: normalizedUsername,
      isKoridoUser: true,
    );
    if (_isCurrentUserRecipient(recipient)) {
      state = state.copyWith(
        isLoading: false,
        clearRecipient: true,
        error: 'recipient_is_current_user',
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      error: null,
      recipient: recipient,
      clearStepUpChallengeToken: true,
    );
  }

  String _canonicalRecipientPhone(String? phoneNumber) {
    final rawPhone = phoneNumber?.trim();
    if (rawPhone == null || rawPhone.isEmpty) {
      return '';
    }

    final phoneValue = PhoneNumberValue.tryFromAny(
      phoneNumber: rawPhone,
      countryCode: '+${_defaultCountryPrefix()}',
    );
    return phoneValue?.e164 ?? rawPhone;
  }

  /// Set transfer amount
  void setAmount(double amount) {
    // Calculate fee (currently 0 for internal transfers)
    const fee = 0.0;
    state = state.copyWith(
      amount: amount,
      fee: fee,
      clearStepUpChallengeToken: true,
    );
  }

  /// Set optional note
  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  /// Restore a queued offline transfer as a draft that requires fresh PIN auth.
  Future<void> resumePendingTransfer({
    required String transferId,
    String? recipientId,
    required String recipientPhone,
    required double amount,
    String? recipientName,
    String? recipientUsername,
    String? note,
  }) async {
    state = SendMoneyState(
      recipient: RecipientInfo(
        phoneNumber: recipientPhone,
        name: recipientName,
        userId: recipientId,
        username: recipientUsername,
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
    if (state.isLoading || state.isSubmitting) {
      return false;
    }

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
      state = state.copyWith(isLoading: false, error: _friendlySendError(e));
      return false;
    }
  }

  /// Reuse a still-valid backend PIN token, usually after biometric auth.
  Future<bool> useExistingPinToken() async {
    if (state.isLoading || state.isSubmitting) {
      return false;
    }

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

  void clearStepUpAuthorization() {
    state = state.copyWith(clearStepUpChallengeToken: true);
  }

  void markStepUpAuthorized(String? challengeToken) {
    final token = challengeToken?.trim();
    if (token == null || token.isEmpty) {
      state = state.copyWith(clearStepUpChallengeToken: true);
      return;
    }

    state = state.copyWith(stepUpChallengeToken: token, error: null);
  }

  /// Execute transfer. Requires verifyPin() to have been called first.
  Future<bool> executeTransfer() async {
    if (!state.canProceedToConfirm) {
      state = state.copyWith(error: 'Invalid transfer details');
      await hapticService.error();
      return false;
    }

    if (!state.hasVerifiedBalance) {
      state = state.copyWith(error: 'balance_unverified');
      await hapticService.warning();
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

    if (_isCurrentUserRecipient(state.recipient!)) {
      state = state.copyWith(error: 'recipient_is_current_user');
      await hapticService.warning();
      return false;
    }

    final limitError = await _verifySendLimitsBeforeSubmission();
    if (limitError != null) {
      state = state.copyWith(error: limitError);
      await hapticService.warning();
      return false;
    }

    // Prevent double-submit
    if (state.isSubmitting) return false;

    // Payment initiated haptic
    await hapticService.paymentStart();

    state = state.copyWith(isLoading: true, isSubmitting: true, error: null);
    try {
      final transfersService = ref.read(transfersServiceProvider);
      final result = await transfersService.createInternalTransfer(
        recipientId: state.recipient!.userId,
        recipientPhone: state.recipient!.phoneNumber.isNotEmpty
            ? state.recipient!.phoneNumber
            : null,
        recipientUsername: state.recipient!.username,
        amount: state.amount!,
        note: state.note,
        pinToken: state.pinToken!,
        idempotencyKey: state.idempotencyKey!,
        stepUpToken: state.stepUpChallengeToken,
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
      final moneyFlowError = moneyFlowLimitExceptionFromError(
        e,
        operation: TransactionLimitOperation.send,
      );
      state = state.copyWith(
        isLoading: false,
        isSubmitting: false,
        error: moneyFlowError?.message ?? _friendlySendError(e),
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

  Future<String?> _verifySendLimitsBeforeSubmission() async {
    final amount = state.amount;
    if (amount == null || amount <= 0) {
      return 'Invalid transfer details';
    }

    try {
      final limits = await ref.read(limitsServiceProvider).getLimits();
      final limitHit = limits.limitHitByFor(
        TransactionLimitOperation.send,
        amount,
      );
      if (limitHit == null) {
        return null;
      }
      return moneyFlowLimitErrorFor(
        limitHit,
        limits,
        TransactionLimitOperation.send,
      );
    } on DioException {
      return 'Unable to verify transfer limits. Please try again.';
    } catch (_) {
      return 'Unable to verify transfer limits. Please try again.';
    }
  }

  String _defaultCountryPrefix() {
    final userCountryCode = ref.read(userStateMachineProvider).countryCode;
    final selectedCountry = ref.read(selectedCountryProvider);
    final country =
        SupportedCountries.findByCode(userCountryCode) ?? selectedCountry;
    return country.prefix;
  }

  String? _normalizeUsername(String? username) {
    final trimmed = username?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    final withoutPrefix = trimmed.startsWith('@')
        ? trimmed.substring(1)
        : trimmed;
    return withoutPrefix.toLowerCase();
  }

  bool _isCurrentUserRecipient(RecipientInfo recipient) {
    final authState = ref.read(authProvider);
    final userState = ref.read(userStateMachineProvider);
    final currentUserId = authState.user?.id ?? userState.userId;
    final currentPhone = authState.user?.phone ?? userState.phone;
    final currentUsername = _normalizeUsername(authState.user?.username);

    final recipientUserId = recipient.userId?.trim();
    if (recipientUserId != null &&
        recipientUserId.isNotEmpty &&
        currentUserId != null &&
        recipientUserId == currentUserId) {
      return true;
    }

    if (_isCurrentUserPhone(
      recipient.phoneNumber,
      currentPhone: currentPhone,
    )) {
      return true;
    }

    final recipientUsername = _normalizeUsername(recipient.username);
    return recipientUsername != null &&
        currentUsername != null &&
        recipientUsername.toLowerCase() == currentUsername.toLowerCase();
  }

  bool _isCurrentUserPhone(String phoneNumber, {String? currentPhone}) {
    final phone = currentPhone ?? ref.read(userStateMachineProvider).phone;
    if (phone == null || phone.trim().isEmpty) {
      return false;
    }
    final dialCode = '+${_defaultCountryPrefix()}';
    return localPhoneDigits(dialCode: dialCode, phoneNumber: phoneNumber) ==
        localPhoneDigits(dialCode: dialCode, phoneNumber: phone);
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
      userId: _stringValue(map, const [
        'userId',
        'recipientId',
        'contactUserId',
        'koridoUserId',
        'joonaPayUserId',
      ]),
      username: _stringValue(map, const [
        'username',
        'recipientUsername',
        'handle',
      ]),
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

String? _displayNameValue(Map<String, dynamic> map) {
  final explicit = _stringValue(map, const ['displayName', 'name']);
  if (explicit != null) {
    return explicit;
  }

  final first = _stringValue(map, const ['firstName', 'first_name']);
  final last = _stringValue(map, const ['lastName', 'last_name']);
  final fullName = [
    first,
    last,
  ].where((part) => part != null && part.trim().isNotEmpty).join(' ').trim();
  return fullName.isEmpty ? null : fullName;
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

String _friendlySendError(Object error) {
  if (error is DioException) {
    return ApiException.fromDioError(error).message;
  }
  if (error is ApiException) {
    return error.message;
  }
  return 'Transfer could not be completed. Please try again.';
}

/// Send Money Provider
final sendMoneyProvider = NotifierProvider<SendMoneyNotifier, SendMoneyState>(
  SendMoneyNotifier.new,
);
