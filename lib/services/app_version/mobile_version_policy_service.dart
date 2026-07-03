import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:usdc_wallet/config/api_config.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/utils/logger.dart';

class MobileVersionPolicy {
  const MobileVersionPolicy({
    required this.platform,
    required this.latestVersion,
    required this.minimumSupportedVersion,
    required this.forceUpgrade,
    required this.upgradeRecommended,
    required this.breakingApiChange,
    required this.apiUrl,
    required this.checkedAt,
    this.currentVersion,
    this.currentBuildNumber,
    this.latestBuildNumber,
    this.minimumSupportedBuildNumber,
    this.message,
    this.appUrl,
  });

  final String platform;
  final String? currentVersion;
  final String? currentBuildNumber;
  final String latestVersion;
  final String minimumSupportedVersion;
  final String? latestBuildNumber;
  final String? minimumSupportedBuildNumber;
  final bool forceUpgrade;
  final bool upgradeRecommended;
  final bool breakingApiChange;
  final String? message;
  final String? appUrl;
  final String apiUrl;
  final DateTime checkedAt;

  factory MobileVersionPolicy.fromJson(Map<String, dynamic> json) {
    final currentVersion = _stringValue(json['currentVersion']);
    final latestVersion =
        _stringValue(json['latestVersion']) ?? currentVersion ?? '0.9.0';
    final minimumSupportedVersion =
        _stringValue(json['minimumSupportedVersion']) ?? latestVersion;

    return MobileVersionPolicy(
      platform: _stringValue(json['platform']) ?? 'unknown',
      currentVersion: currentVersion,
      currentBuildNumber: _stringValue(json['currentBuildNumber']),
      latestVersion: latestVersion,
      minimumSupportedVersion: minimumSupportedVersion,
      latestBuildNumber: _stringValue(json['latestBuildNumber']),
      minimumSupportedBuildNumber: _stringValue(
        json['minimumSupportedBuildNumber'],
      ),
      forceUpgrade: json['forceUpgrade'] == true,
      upgradeRecommended: json['upgradeRecommended'] == true,
      breakingApiChange: json['breakingApiChange'] == true,
      message: _stringValue(json['message']),
      appUrl: _stringValue(json['appUrl']),
      apiUrl: _stringValue(json['apiUrl']) ?? ApiConfiguration.baseUrl,
      checkedAt:
          DateTime.tryParse(_stringValue(json['checkedAt']) ?? '') ??
          DateTime.now(),
    );
  }

  static String? _stringValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

class MobileVersionPolicyState {
  const MobileVersionPolicyState({
    this.isChecking = false,
    this.policy,
    this.lastCheckedAt,
    this.error,
  });

  final bool isChecking;
  final MobileVersionPolicy? policy;
  final DateTime? lastCheckedAt;
  final Object? error;

  bool get forceUpgrade => policy?.forceUpgrade ?? false;
  String? get appUrl => policy?.appUrl;
  String? get message => policy?.message;
  String? get latestVersion => policy?.latestVersion;

  MobileVersionPolicyState copyWith({
    bool? isChecking,
    MobileVersionPolicy? policy,
    DateTime? lastCheckedAt,
    Object? error,
    bool clearError = false,
  }) {
    return MobileVersionPolicyState(
      isChecking: isChecking ?? this.isChecking,
      policy: policy ?? this.policy,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class MobileVersionPolicyController extends Notifier<MobileVersionPolicyState> {
  static const _tag = 'MobileVersionPolicy';
  static const _cooldown = Duration(minutes: 5);
  final _log = const AppLogger(_tag);

  @override
  MobileVersionPolicyState build() {
    return const MobileVersionPolicyState();
  }

  Future<MobileVersionPolicy?> check({
    String reason = 'startup',
    bool force = false,
  }) async {
    if (!force && !_shouldCheckAgain()) {
      return state.policy;
    }

    state = state.copyWith(isChecking: true, clearError: true);

    try {
      final packageInfo = await _safePackageInfo();
      final response = await _client().get<Map<String, dynamic>>(
        '/config/mobile-version',
        queryParameters: {
          'platform': _platform,
          'version': _currentVersion(packageInfo),
          'buildNumber': packageInfo?.buildNumber ?? '0',
          'reason': reason,
        },
      );
      final payload = _payload(response.data);
      final policy = MobileVersionPolicy.fromJson(payload);

      state = MobileVersionPolicyState(
        policy: policy,
        lastCheckedAt: DateTime.now(),
      );

      if (policy.forceUpgrade) {
        _log.warn(
          'Force upgrade required: ${policy.currentVersion} -> ${policy.minimumSupportedVersion}',
        );
      }

      return policy;
    } on Object catch (error) {
      state = state.copyWith(
        isChecking: false,
        lastCheckedAt: DateTime.now(),
        error: error,
      );
      _log.warn('Version policy check failed', error);
      return state.policy;
    }
  }

  bool _shouldCheckAgain() {
    if (state.isChecking) return false;
    final lastCheckedAt = state.lastCheckedAt;
    if (lastCheckedAt == null) return true;
    return DateTime.now().difference(lastCheckedAt) >= _cooldown;
  }

  Dio _client() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConfiguration.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConfiguration.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConfiguration.receiveTimeout),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<PackageInfo?> _safePackageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } on Object catch (error) {
      _log.warn('Package info unavailable', error);
      return null;
    }
  }

  String _currentVersion(PackageInfo? packageInfo) {
    if (EnvironmentConfig.versionOverride.isNotEmpty) {
      return EnvironmentConfig.versionOverride;
    }
    return packageInfo?.version ?? '0.0.0';
  }

  String get _platform {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }

  Map<String, dynamic> _payload(Map<String, dynamic>? raw) {
    final data = raw?['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return Map<String, dynamic>.from(raw ?? const <String, dynamic>{});
  }
}

final mobileVersionPolicyProvider =
    NotifierProvider<MobileVersionPolicyController, MobileVersionPolicyState>(
      MobileVersionPolicyController.new,
    );
