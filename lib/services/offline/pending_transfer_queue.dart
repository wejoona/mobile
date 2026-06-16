import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pending Transfer Model
class PendingTransfer {
  final String id;
  final String? recipientId;
  final String recipientPhone;
  final String? recipientName;
  final String? recipientUsername;
  final double amount;
  final String? description;
  final DateTime timestamp;
  final TransferStatus status;
  final String? errorMessage;

  /// Deprecated: PIN tokens are intentionally not persisted.
  final String? pinToken;

  /// Deprecated for draft queue entries; generated again after fresh PIN.
  final String? idempotencyKey;

  const PendingTransfer({
    required this.id,
    this.recipientId,
    required this.recipientPhone,
    this.recipientName,
    this.recipientUsername,
    required this.amount,
    this.description,
    required this.timestamp,
    this.status = TransferStatus.pending,
    this.errorMessage,
    this.pinToken,
    this.idempotencyKey,
  });

  bool get canReplayWithAuthorization =>
      pinToken != null &&
      pinToken!.isNotEmpty &&
      idempotencyKey != null &&
      idempotencyKey!.isNotEmpty;

  bool get hasRecipientIdentifier =>
      recipientId?.trim().isNotEmpty == true ||
      recipientPhone.trim().isNotEmpty ||
      recipientUsername?.trim().isNotEmpty == true;

  String get displayRecipientIdentifier {
    final phone = recipientPhone.trim();
    if (phone.isNotEmpty) return phone;

    final username = recipientUsername?.trim();
    if (username != null && username.isNotEmpty) {
      return username.startsWith('@') ? username : '@$username';
    }

    return recipientId ?? '';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipientId': recipientId,
    'recipientPhone': recipientPhone,
    'recipientName': recipientName,
    'recipientUsername': recipientUsername,
    'amount': amount,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'status': status.name,
    'errorMessage': errorMessage,
  };

  factory PendingTransfer.fromJson(Map<String, dynamic> json) {
    return PendingTransfer(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String?,
      recipientPhone: json['recipientPhone'] as String? ?? '',
      recipientName: json['recipientName'] as String?,
      recipientUsername: json['recipientUsername'] as String?,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: TransferStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransferStatus.pending,
      ),
      errorMessage: json['errorMessage'] as String?,
      pinToken: null,
      idempotencyKey: null,
    );
  }

  PendingTransfer copyWith({
    String? id,
    String? recipientId,
    String? recipientPhone,
    String? recipientName,
    String? recipientUsername,
    double? amount,
    String? description,
    DateTime? timestamp,
    TransferStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? pinToken,
    String? idempotencyKey,
  }) {
    return PendingTransfer(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientName: recipientName ?? this.recipientName,
      recipientUsername: recipientUsername ?? this.recipientUsername,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      pinToken: pinToken ?? this.pinToken,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    );
  }
}

/// Transfer Status
enum TransferStatus {
  /// Waiting to be processed
  pending,

  /// Currently processing
  processing,

  /// Successfully completed
  completed,

  /// Failed to process
  failed,

  /// Saved locally but requires a fresh PIN before it can be submitted.
  needsAuthorization,
}

/// Pending Transfer Queue Service
/// Manages offline transfers and processes them when online
class PendingTransferQueue {
  static const String _keyQueue = 'pending_transfer_queue';

  final SharedPreferences _prefs;

  PendingTransferQueue(this._prefs);

  // ============================================================
  // Queue Management
  // ============================================================

  /// Taille maximale de la file d'attente
  static const int maxQueueSize = 50;

  /// Âge maximum d'un élément (24h)
  static const Duration maxAge = Duration(hours: 24);

  /// Add transfer to queue
  Future<void> enqueue(PendingTransfer transfer) async {
    final queue = getQueue();

    // Expirer les éléments trop anciens
    _expireOldItems(queue);

    // Vérifier la taille maximale
    if (queue.length >= maxQueueSize) {
      throw Exception('File d\'attente pleine ($maxQueueSize éléments max)');
    }

    queue.add(transfer);
    await _saveQueue(queue);
  }

  /// Supprimer les éléments expirés (> 24h)
  void _expireOldItems(List<PendingTransfer> queue) {
    final cutoff = DateTime.now().subtract(maxAge);
    queue.removeWhere(
      (t) => t.status == TransferStatus.pending && t.timestamp.isBefore(cutoff),
    );
  }

  /// Get all pending transfers
  List<PendingTransfer> getQueue() {
    final jsonString = _prefs.getString(_keyQueue);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => PendingTransfer.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get pending transfers count
  int getPendingCount() {
    return getQueue()
        .where(
          (t) =>
              t.status == TransferStatus.pending ||
              t.status == TransferStatus.processing ||
              t.status == TransferStatus.needsAuthorization,
        )
        .length;
  }

  /// Update transfer status
  Future<void> updateTransferStatus(
    String transferId,
    TransferStatus status, {
    String? errorMessage,
    bool clearErrorMessage = false,
  }) async {
    final queue = getQueue();
    final index = queue.indexWhere((t) => t.id == transferId);

    if (index != -1) {
      queue[index] = queue[index].copyWith(
        status: status,
        errorMessage: errorMessage,
        clearErrorMessage: clearErrorMessage,
      );
      await _saveQueue(queue);
    }
  }

  /// Remove transfer from queue
  Future<void> removeTransfer(String transferId) async {
    final queue = getQueue();
    queue.removeWhere((t) => t.id == transferId);
    await _saveQueue(queue);
  }

  /// Clear completed transfers older than N days
  Future<void> clearCompleted({int olderThanDays = 7}) async {
    final queue = getQueue();
    final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));

    queue.removeWhere(
      (t) =>
          t.status == TransferStatus.completed &&
          t.timestamp.isBefore(cutoffDate),
    );

    await _saveQueue(queue);
  }

  /// Clear all transfers
  Future<void> clearAll() async {
    await _prefs.remove(_keyQueue);
  }

  // ============================================================
  // Processing
  // ============================================================

  /// Get transfers ready to process
  List<PendingTransfer> getTransfersToProcess() {
    final staleProcessingCutoff = DateTime.now().subtract(
      const Duration(minutes: 2),
    );
    return getQueue().where((t) {
      if (!t.canReplayWithAuthorization) return false;
      return t.status == TransferStatus.pending ||
          t.status == TransferStatus.processing &&
              t.timestamp.isBefore(staleProcessingCutoff);
    }).toList();
  }

  /// Mark transfer as processing
  Future<void> markProcessing(String transferId) async {
    await updateTransferStatus(transferId, TransferStatus.processing);
  }

  /// Mark transfer as completed
  Future<void> markCompleted(String transferId) async {
    await updateTransferStatus(transferId, TransferStatus.completed);
  }

  /// Mark transfer as failed
  Future<void> markFailed(String transferId, String errorMessage) async {
    await updateTransferStatus(
      transferId,
      TransferStatus.failed,
      errorMessage: errorMessage,
    );
  }

  // ============================================================
  // Private Helpers
  // ============================================================

  Future<void> _saveQueue(List<PendingTransfer> queue) async {
    final jsonList = queue.map((t) => t.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(_keyQueue, jsonString);
  }
}

/// Pending Transfer Queue Provider
final pendingTransferQueueProvider = Provider<PendingTransferQueue>((ref) {
  throw UnimplementedError('Must be overridden with SharedPreferences');
});

/// Provider for PendingTransferQueue with SharedPreferences
final pendingTransferQueueFutureProvider = FutureProvider<PendingTransferQueue>(
  (ref) async {
    final prefs = await SharedPreferences.getInstance();
    return PendingTransferQueue(prefs);
  },
);

/// Pending count provider (reactive)
final pendingTransferCountProvider = Provider<int>((ref) {
  // This will be updated by the offline provider
  return 0;
});
