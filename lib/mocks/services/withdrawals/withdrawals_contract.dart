/// Mobile Money Cash-Out API Contract
///
/// Canonical USDC to mobile money cash-out endpoints.
library;

import 'package:usdc_wallet/mocks/base/api_contract.dart';

class WithdrawalInitiateRequest {
  final num amount;
  final String currency;
  final String providerCode;
  final String phoneNumber;

  const WithdrawalInitiateRequest({
    required this.amount,
    required this.currency,
    required this.providerCode,
    required this.phoneNumber,
  });
}

class WithdrawalContractResponse {
  final String id;
  final String status;
  final num amount;
  final String currency;
  final String providerCode;
  final String phoneNumber;

  const WithdrawalContractResponse({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    required this.providerCode,
    required this.phoneNumber,
  });
}

class WithdrawalListContractResponse {
  final List<WithdrawalContractResponse> withdrawals;
  final int total;
  final bool hasMore;

  const WithdrawalListContractResponse({
    required this.withdrawals,
    required this.total,
    required this.hasMore,
  });
}

class WithdrawalsContract extends ApiContract {
  @override
  String get serviceName => 'MobileMoneyCashOut';

  @override
  String get basePath => '/wallet/cash-out/mobile-money';

  static const initiate = ApiEndpoint(
    path: '',
    method: HttpMethod.post,
    description: 'Initiate a mobile money cash-out',
    requestType: WithdrawalInitiateRequest,
    responseType: WithdrawalContractResponse,
    requiresAuth: true,
  );

  static const getStatus = ApiEndpoint(
    path: '/:id',
    method: HttpMethod.get,
    description: 'Get mobile money cash-out status',
    responseType: WithdrawalContractResponse,
    pathParams: {'id': 'Withdrawal ID'},
    requiresAuth: true,
  );

  static const list = ApiEndpoint(
    path: '',
    method: HttpMethod.get,
    description: 'List user withdrawals',
    responseType: WithdrawalListContractResponse,
    queryParams: {
      'status': 'Optional status filter',
      'limit': 'Results per page',
      'offset': 'Number of results to skip',
    },
    requiresAuth: true,
  );

  @override
  List<ApiEndpoint> get endpoints => [initiate, getStatus, list];
}
