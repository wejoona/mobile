import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/analytics/analytics_service.dart';

// analyticsServiceProvider est défini dans analytics_service.dart

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
