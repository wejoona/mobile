import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/business_profile.dart';
import 'package:usdc_wallet/domain/enums/account_type.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Business Service - handles business account operations
class BusinessService {
  BusinessService(this._dio);

  final Dio _dio;

  /// Get current account type
  Future<AccountType> getAccountType() async {
    final response = await _dio.get('/user/active-account-type');
    // ignore: avoid_dynamic_calls
    final type = response.data['accountType'] as String;
    return type == 'business' ? AccountType.business : AccountType.personal;
  }

  /// Get business profile
  Future<BusinessProfile> getBusinessProfile() async {
    final response = await _dio.get('/business/profile');
    return BusinessProfile.fromJson(response.data);
  }

  /// Switch account type
  Future<void> switchAccountType(AccountType type) async {
    await _dio.put(
      '/user/active-account-type',
      data: {
        'accountType': type == AccountType.business ? 'business' : 'personal',
      },
    );
  }

  /// Create or update business profile
  Future<BusinessProfile> saveBusinessProfile({
    required String businessName,
    required BusinessType businessType,
    String? registrationNumber,
    String? businessAddress,
    String? taxId,
  }) async {
    final response = await _dio.post(
      '/business/profile',
      data: {
        'businessName': businessName,
        'registrationNumber': registrationNumber,
        'businessType': businessType.name,
        'businessAddress': businessAddress,
        'taxId': taxId,
      },
    );
    return BusinessProfile.fromJson(response.data);
  }
}

/// Provider
final businessServiceProvider = Provider<BusinessService>((ref) {
  final dio = ref.watch(dioProvider);
  return BusinessService(dio);
});
