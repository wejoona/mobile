import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/analytics/analytics_service.dart';

/// Run 371: Riverpod provider for analytics service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Analytics screen tracking mixin for ConsumerState
mixin AnalyticsScreenTracker<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  String get screenName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).trackScreen(screenName);
    });
  }
}
