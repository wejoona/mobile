import 'package:package_info_plus/package_info_plus.dart';

/// Cached app info singleton
class AppInfo {
  static PackageInfo? _instance;

  static Future<PackageInfo> get instance async {
    _instance ??= await PackageInfo.fromPlatform();
    return _instance!;
  }

  static String get versionSync => _instance?.version ?? '0.0.0';
  static String get buildSync => _instance?.buildNumber ?? '0';
  static String get fullVersion => '${versionSync}+${buildSync}';
  static Future<String> getVersion() async {
    final info = await instance;
    return '${info.version}+${info.buildNumber}';
  }
}
