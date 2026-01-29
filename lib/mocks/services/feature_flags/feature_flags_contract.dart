import '../../base/api_contract.dart';

/// Feature Flags API Contract
class FeatureFlagsContract extends ApiContract {
  @override
  String get serviceName => 'Feature Flags';

  @override
  String get basePath => '/feature-flags';

  @override
  List<ApiEndpoint> get endpoints => [
        // Get all flags for current user context
        ApiEndpoint(
          path: '/me',
          method: HttpMethod.get,
          description: 'Get all feature flags evaluated for current user',
          requiresAuth: true,
        ),

        // Check single flag
        ApiEndpoint(
          path: '/check/:key',
          method: HttpMethod.get,
          description: 'Check if specific feature flag is enabled',
          requiresAuth: true,
          pathParams: {
            'key': 'Feature flag key to check',
          },
        ),
      ];
}
