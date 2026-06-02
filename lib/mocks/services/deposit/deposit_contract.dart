/// Deposits API Contract
///
/// Canonical mobile money deposit endpoints.
library;

import 'package:usdc_wallet/mocks/base/api_contract.dart';

class DepositProviderInfo {
  final String code;
  final String name;
  final String paymentMethodType;

  const DepositProviderInfo({
    required this.code,
    required this.name,
    required this.paymentMethodType,
  });
}

class DepositInitiateRequest {
  final num amount;
  final String currency;
  final String providerCode;
  final String? phoneNumber;

  const DepositInitiateRequest({
    required this.amount,
    required this.currency,
    required this.providerCode,
    this.phoneNumber,
  });
}

class DepositConfirmRequest {
  final String depositId;
  final String? otp;

  const DepositConfirmRequest({required this.depositId, this.otp});
}

class DepositInitiateContractResponse {
  final String depositId;
  final String token;
  final String paymentMethodType;
  final String status;

  const DepositInitiateContractResponse({
    required this.depositId,
    required this.token,
    required this.paymentMethodType,
    required this.status,
  });
}

class DepositStatusContractResponse {
  final String id;
  final String status;
  final num amount;
  final String currency;
  final String providerCode;

  const DepositStatusContractResponse({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    required this.providerCode,
  });
}

class DepositListContractResponse {
  final List<DepositStatusContractResponse> deposits;
  final int total;
  final bool hasMore;

  const DepositListContractResponse({
    required this.deposits,
    required this.total,
    required this.hasMore,
  });
}

class DepositContract extends ApiContract {
  @override
  String get serviceName => 'Deposits';

  @override
  String get basePath => '/deposits';

  static const providers = ApiEndpoint(
    path: '/providers',
    method: HttpMethod.get,
    description: 'List available mobile money deposit providers',
    responseType: DepositProviderInfo,
    requiresAuth: true,
  );

  static const initiate = ApiEndpoint(
    path: '/initiate',
    method: HttpMethod.post,
    description: 'Initiate a mobile money deposit',
    requestType: DepositInitiateRequest,
    responseType: DepositInitiateContractResponse,
    requiresAuth: true,
  );

  static const confirm = ApiEndpoint(
    path: '/confirm',
    method: HttpMethod.post,
    description: 'Confirm a pending deposit',
    requestType: DepositConfirmRequest,
    responseType: DepositStatusContractResponse,
    requiresAuth: true,
  );

  static const getStatus = ApiEndpoint(
    path: '/:id',
    method: HttpMethod.get,
    description: 'Get deposit status',
    responseType: DepositStatusContractResponse,
    pathParams: {'id': 'Deposit ID'},
    requiresAuth: true,
  );

  static const list = ApiEndpoint(
    path: '',
    method: HttpMethod.get,
    description: 'List user deposits',
    responseType: DepositListContractResponse,
    queryParams: {
      'status': 'Optional status filter',
      'limit': 'Results per page',
      'offset': 'Number of results to skip',
    },
    requiresAuth: true,
  );

  @override
  List<ApiEndpoint> get endpoints => [
    providers,
    initiate,
    confirm,
    getStatus,
    list,
  ];
}
