import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';
import 'package:usdc_wallet/features/send_external/models/external_transfer_request.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// External Transfer Service - handles crypto transfers to wallet addresses
class ExternalTransferService {
  final Dio _dio;

  ExternalTransferService(this._dio);

  /// Validate USDC wallet address
  AddressValidationResult validateAddress(String address) {
    // Remove whitespace
    final trimmed = address.trim();

    // Check if starts with 0x
    if (!trimmed.startsWith('0x')) {
      return AddressValidationResult.invalid('Address must start with 0x');
    }

    // Check length (0x + 40 hex characters = 42 total)
    if (trimmed.length != 42) {
      return AddressValidationResult.invalid(
        'Address must be 42 characters (0x + 40 hex)',
      );
    }

    // Check if all characters after 0x are valid hex
    final hexPart = trimmed.substring(2);
    final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
    if (!hexRegex.hasMatch(hexPart)) {
      return AddressValidationResult.invalid(
        'Address contains invalid characters',
      );
    }

    return AddressValidationResult.valid();
  }

  /// Estimate fee for network transfer
  Future<double> estimateFee(double amount, NetworkOption network) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.transfersEstimateFee,
        queryParameters: {'network': network.value, 'amount': amount},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return (data['estimatedFee'] as num?)?.toDouble() ??
            network.estimatedFee;
      }
      return network.estimatedFee;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Execute external transfer
  /// [pinToken] — required by backend PinVerificationGuard
  /// [idempotencyKey] — required by backend IdempotencyGuard
  Future<ExternalTransferResult> sendExternal(
    ExternalTransferRequest request, {
    required String pinToken,
    required String idempotencyKey,
    String? stepUpToken,
  }) async {
    try {
      final data = request.toJson();
      final recipientAddress = data.remove('recipientAddress');
      data['toAddress'] = data['toAddress'] ?? recipientAddress;
      data['amount'] = request.amount;

      final response = await _dio.post(
        ApiEndpoints.transfersExternal,
        data: data,
        options: Options(
          headers: transactionHeaders(
            pinToken: pinToken,
            idempotencyKey: idempotencyKey,
            stepUpToken: stepUpToken,
          ),
        ),
      );
      return ExternalTransferResult.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Parse address from QR code (supports plain address or ethereum: URI)
  String? parseAddressFromQr(String qrData) {
    // Plain address
    if (qrData.startsWith('0x') && qrData.length == 42) {
      return qrData;
    }

    // ethereum: URI format
    if (qrData.startsWith('ethereum:')) {
      final uri = Uri.tryParse(qrData);
      if (uri != null) {
        // Extract address from path
        final address = uri.path;
        if (address.startsWith('0x') && address.length == 42) {
          return address;
        }
      }
    }

    return null;
  }

  Exception _handleError(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      // ignore: avoid_dynamic_calls
      final message = e.response!.data['message'] ?? 'Transfer failed';
      return Exception(message);
    }
    return Exception('Network error. Please try again.');
  }
}

/// External Transfer Service Provider
final externalTransferServiceProvider = Provider<ExternalTransferService>((
  ref,
) {
  return ExternalTransferService(ref.watch(dioProvider));
});
