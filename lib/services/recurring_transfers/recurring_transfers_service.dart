import 'package:dio/dio.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/recurring_transfer.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/create_recurring_transfer_request.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/update_recurring_transfer_request.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/execution_history.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/upcoming_execution.dart';

class RecurringTransfersService {
  final Dio _dio;

  RecurringTransfersService(this._dio);

  /// Get all recurring transfers for the current user
  Future<List<RecurringTransfer>> getRecurringTransfers() async {
    final response = await _dio.get('/recurring-transfers');
    final data = response.data;
    // Backend returns { transfers: [...] }; handle both wrapped and direct list
    final List items;
    if (data is Map && data.containsKey('transfers')) {
      items = data['transfers'] as List? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      items = [];
    }
    return items.map((json) => RecurringTransfer.fromJson(json)).toList();
  }

  /// Get a single recurring transfer by ID
  Future<RecurringTransfer> getRecurringTransfer(String id) async {
    final response = await _dio.get('/recurring-transfers/$id');
    return RecurringTransfer.fromJson(response.data);
  }

  /// Create a new recurring transfer
  Future<RecurringTransfer> createRecurringTransfer(
    CreateRecurringTransferRequest request,
  ) async {
    final response = await _dio.post(
      '/recurring-transfers',
      data: request.toJson(),
    );
    return RecurringTransfer.fromJson(response.data);
  }

  /// Update an existing recurring transfer
  Future<RecurringTransfer> updateRecurringTransfer(
    String id,
    UpdateRecurringTransferRequest request,
  ) async {
    final response = await _dio.patch(
      '/recurring-transfers/$id',
      data: request.toJson(),
    );
    return RecurringTransfer.fromJson(response.data);
  }

  /// Pause a recurring transfer
  /// Backend returns partial { id, status, updatedAt }, so re-fetch full transfer
  Future<RecurringTransfer> pauseRecurringTransfer(String id) async {
    await _dio.post('/recurring-transfers/$id/pause');
    return getRecurringTransfer(id);
  }

  /// Resume a paused recurring transfer
  /// Backend returns partial { id, status, updatedAt }, so re-fetch full transfer
  Future<RecurringTransfer> resumeRecurringTransfer(String id) async {
    await _dio.post('/recurring-transfers/$id/resume');
    return getRecurringTransfer(id);
  }

  /// Cancel a recurring transfer
  Future<void> cancelRecurringTransfer(String id) async {
    await _dio.delete('/recurring-transfers/$id');
  }

  /// Get execution history for a recurring transfer
  Future<List<ExecutionHistory>> getExecutionHistory(String id) async {
    final response = await _dio.get('/recurring-transfers/$id/history');
    final data = response.data;
    final List items = (data is Map ? data['history'] : data) as List? ?? [];
    return items.map((json) => ExecutionHistory.fromJson(json)).toList();
  }

  /// Get upcoming executions (next 7 days)
  Future<List<UpcomingExecution>> getUpcomingExecutions() async {
    final response = await _dio.get('/recurring-transfers/upcoming');
    final data = response.data;
    final List items = (data is Map ? data['upcoming'] : data) as List? ?? [];
    return items.map((json) => UpcomingExecution.fromJson(json)).toList();
  }

  /// Get next 3 scheduled dates for a specific recurring transfer
  Future<List<DateTime>> getNextExecutionDates(String id, {int count = 3}) async {
    final response = await _dio.get(
      '/recurring-transfers/$id/next-dates',
      queryParameters: {'count': count},
    );
    final data = response.data;
    final List items = (data is Map ? data['dates'] : data) as List? ?? [];
    return items.map((date) => DateTime.parse(date as String)).toList();
  }
}
