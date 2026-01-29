/// Beneficiaries API Contract
///
/// Defines the API contract for beneficiary endpoints.
library;

import '../../base/api_contract.dart';

/// Beneficiaries API Contract
class BeneficiariesContract extends ApiContract {
  @override
  String get basePath => '/api/v1/beneficiaries';

  @override
  String get serviceName => 'Beneficiaries';

  @override
  List<ApiEndpoint> get endpoints => [
        const ApiEndpoint(
          method: HttpMethod.get,
          path: '',
          description: 'Get all beneficiaries',
          queryParams: {
            'favorites': 'Filter by favorites (boolean)',
            'recent': 'Filter by recently used (boolean)',
            'type': 'Filter by account type',
          },
        ),
        const ApiEndpoint(
          method: HttpMethod.get,
          path: '/:id',
          description: 'Get beneficiary by ID',
        ),
        const ApiEndpoint(
          method: HttpMethod.post,
          path: '',
          description: 'Create a new beneficiary',
        ),
        const ApiEndpoint(
          method: HttpMethod.put,
          path: '/:id',
          description: 'Update beneficiary',
        ),
        const ApiEndpoint(
          method: HttpMethod.delete,
          path: '/:id',
          description: 'Delete beneficiary',
        ),
        const ApiEndpoint(
          method: HttpMethod.post,
          path: '/:id/favorite',
          description: 'Toggle favorite status',
        ),
      ];
}
