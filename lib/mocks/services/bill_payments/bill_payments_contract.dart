/// Bill Payments API Contract
///
/// Defines the API contract for bill payment endpoints.
library;

import '../../base/api_contract.dart';

/// Bill Payments API Contract
class BillPaymentsContract extends ApiContract {
  @override
  String get basePath => '/bill-payments';

  @override
  String get serviceName => 'Bill Payments';

  @override
  List<ApiEndpoint> get endpoints => [
        const ApiEndpoint(
          method: HttpMethod.get,
          path: '/providers',
          description: 'Get all bill providers',
          queryParams: {
            'country': 'Filter by country code (e.g., CI, SN)',
            'category': 'Filter by category',
          },
        ),
        const ApiEndpoint(
          method: HttpMethod.get,
          path: '/categories',
          description: 'Get all bill categories',
          queryParams: {
            'country': 'Filter by country code',
          },
        ),
        const ApiEndpoint(
          method: HttpMethod.post,
          path: '/validate',
          description: 'Validate bill account',
        ),
        const ApiEndpoint(
          method: HttpMethod.post,
          path: '/pay',
          description: 'Pay a bill',
        ),
        const ApiEndpoint(
          method: HttpMethod.get,
          path: '/history',
          description: 'Get bill payment history',
          queryParams: {
            'page': 'Page number (default: 1)',
            'limit': 'Items per page (default: 20)',
            'category': 'Filter by category',
            'status': 'Filter by status',
          },
        ),
        const ApiEndpoint(
          method: HttpMethod.get,
          path: '/:id/receipt',
          description: 'Get payment receipt',
          pathParams: {
            'id': 'Payment ID',
          },
        ),
      ];
}
