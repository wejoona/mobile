import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pending Transfer Model
class PendingTransfer {
  final String id;
  final String recipientPhone;
  final String? recipientName;
  final double amount;
  final String? description;
  final DateTime timestamp;
  final TransferStatus status;
  final String? errorMessage;

  const PendingTransfer({
    required this.id,
    required this.recipientPhone,
    this.recipientName,
    required this.amount,
    this.description,
    required this.timestamp,
    this.status = TransferStatus.pending,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipientPhone': recipientPhone,
        'recipientName': recipientName,
        'amount': amount,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'errorMessage': errorMessage,
      };

  factory PendingTransfer.fromJson(Map<String, dynamic> json) {
    return PendingTransfer(
      id: json['id'] as String,
      recipientPhone: json['recipientPhone'] as String,
      recipientName: json['recipientName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: TransferStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransferStatus.pending,
      ),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  PendingTransfer copyWith({
    String? id,
    String? recipientPhone,
    String? recipientName,
    double? amount,
    String? description,
    DateTime? timestamp,
    TransferStatus? status,
    String? errorMessage,
  }) {
    return PendingTransfer(
      id: id ?? this.id,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientName: recipientName ?? this.recipientName,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
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
    queue.removeWhere((t) =>
        t.status == TransferStatus.pending && t.timestamp.isBefore(cutoff));
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
        .where((t) =>
            t.status == TransferStatus.pending ||
            t.status == TransferStatus.processing)
        .length;
  }

  /// Update transfer status
  Future<void> updateTransferStatus(
    String transferId,
    TransferStatus status, {
    String? errorMessage,
  }) async {
    final queue = getQueue();
    final index = queue.indexWhere((t) => t.id == transferId);

    if (index != -1) {
      queue[index] = queue[index].copyWith(
        status: status,
        errorMessage: errorMessage,
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

    queue.removeWhere((t) =>
        t.status == TransferStatus.completed &&
        t.timestamp.isBefore(cutoffDate));

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
    return getQueue()
        .where((t) => t.status == TransferStatus.pending)
        .toList();
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
final pendingTransferQueueFutureProvider =
    FutureProvider<PendingTransferQueue>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return PendingTransferQueue(prefs);
});

/// Pending count provider (reactive)
final pendingTransferCountProvider = Provider<int>((ref) {
  // This will be updated by the offline provider
  return 0;
});
