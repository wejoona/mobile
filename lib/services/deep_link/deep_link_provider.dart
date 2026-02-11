/// Riverpod provider for deep link handling.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'deep_link_service.dart';

/// Provides a stream of deep link actions as they arrive.
final deepLinkStreamProvider = StreamProvider<DeepLinkAction>((ref) {
  return _DeepLinkStreamController.instance.stream;
});

/// Holds the pending deep link that triggered app open (cold start).
final pendingDeepLinkProvider = StateProvider<DeepLinkAction?>((ref) => null);

/// Singleton controller for deep link stream.
class _DeepLinkStreamController {
  _DeepLinkStreamController._();
  static final instance = _DeepLinkStreamController._();

  final _controller = StreamController<DeepLinkAction>.broadcast();
  Stream<DeepLinkAction> get stream => _controller.stream;

  void add(DeepLinkAction action) {
    if (kDebugMode) debugPrint('[DeepLink] Stream event: $action');
    _controller.add(action);
  }

  void dispose() {
    _controller.close();
  }
}

/// Call this from the app's deep link listener to emit actions.
void emitDeepLinkAction(DeepLinkAction action) {
  _DeepLinkStreamController.instance.add(action);
}
