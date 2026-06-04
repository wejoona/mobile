import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      recipient: recipient ?? this.recipient,
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

      final responseData = response.data as Map<String, dynamic>;
      final contactsJson = (responseData['contacts'] as List?) ?? [];
      final recipients = contactsJson.map((json) {
        final c = json as Map<String, dynamic>;
        return RecentRecipient(
          phoneNumber: c['phone'] as String? ?? '',
          name: c['name'] as String? ?? '',
          lastTransferDate: c['lastTransferDate'] != null
              ? DateTime.parse(c['lastTransferDate'] as String)
              : DateTime.now(),
          lastAmount: (c['lastAmount'] as num?)?.toDouble() ?? 0.0,
          isKoridoUser:
              (c['isKoridoUser'] ?? c['isJoonaPayUser']) as bool? ?? false,
        );
      }).toList();

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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final contactsService = ref.read(contactsServiceProvider);
      final phoneHash = contactsService.hashPhone(phoneNumber);

      final response = await dio.post(
        '/contacts/sync',
        data: {
          'phoneHashes': [phoneHash],
        },
      );

      final syncData = response.data as Map<String, dynamic>;
      final matches = _extractContactSyncMatches(syncData);
      final isKoridoUser = matches.isNotEmpty;

      String? userId;
      String? displayName = name;
      if (isKoridoUser) {
        final match = matches.first;
        userId = match['userId'] as String?;
        displayName =
            displayName ??
            (match['displayName'] as String?) ??
            (match['name'] as String?);
      }

      final recipient = RecipientInfo(
        phoneNumber: phoneNumber,
        name: displayName,
        userId: userId,
        isKoridoUser: isKoridoUser,
      );

      state = state.copyWith(isLoading: false, recipient: recipient);
    } on DioException {
      // If sync fails, still allow setting recipient but mark as unknown
      final recipient = RecipientInfo(
        phoneNumber: phoneNumber,
        name: name,
        isKoridoUser: false,
      );
      state = state.copyWith(isLoading: false, recipient: recipient);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
      final result = await transfersService.createInternalTransfer(
        recipientPhone: state.recipient!.phoneNumber,
        amount: state.amount!,
        note: state.note,
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

/// Send Money Provider
final sendMoneyProvider = NotifierProvider<SendMoneyNotifier, SendMoneyState>(
  SendMoneyNotifier.new,
);
