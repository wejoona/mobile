import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Manages API version negotiation and deprecation warnings.
class ApiVersioningManager {
  static const _tag = 'ApiVersion';
  final AppLogger _log = AppLogger(_tag);
  final String currentVersion;
  String? _serverMinVersion;

  ApiVersioningManager({this.currentVersion = 'v1'});

  /// Check if the current client version is still supported.
  bool isSupported() {
    if (_serverMinVersion == null) return true;
    return currentVersion.compareTo(_serverMinVersion!) >= 0;
  }

  /// Update server's minimum version from response header.
  void updateFromHeader(String? minVersion) {
    if (minVersion != null) {
      _serverMinVersion = minVersion;
      if (!isSupported()) {
        _log.warn('Client version $currentVersion is deprecated. Min: $_serverMinVersion');
      }
    }
  }

  String get versionHeader => 'X-API-Version: $currentVersion';
}

final apiVersioningManagerProvider = Provider<ApiVersioningManager>((ref) {
  return ApiVersioningManager();
});
