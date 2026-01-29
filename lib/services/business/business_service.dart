import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/business_profile.dart';
import '../../domain/enums/account_type.dart';
import '../api/api_client.dart';

/// Business Service - handles business account operations
class BusinessService {
  final Dio _dio;

  BusinessService(this._dio);

  /// Get current account type
  Future<AccountType> getAccountType() async {
    final response = await _dio.get('/users/me/account-type');
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
    await _dio.post('/users/me/account-type', data: {
      'accountType': type == AccountType.business ? 'business' : 'personal',
    });
  }

  /// Create or update business profile
  Future<BusinessProfile> saveBusinessProfile({
    required String businessName,
    String? registrationNumber,
    required BusinessType businessType,
    String? businessAddress,
    String? taxId,
  }) async {
    final response = await _dio.post('/business/profile', data: {
      'businessName': businessName,
      'registrationNumber': registrationNumber,
      'businessType': businessType.name,
      'businessAddress': businessAddress,
      'taxId': taxId,
    });
    return BusinessProfile.fromJson(response.data);
  }
}

/// Provider
final businessServiceProvider = Provider<BusinessService>((ref) {
  final dio = ref.watch(dioProvider);
  return BusinessService(dio);
});
