import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/kyc_profile.dart';
import '../../../services/api/api_client.dart';

/// KYC profile provider.
final kycProfileProvider = FutureProvider<KycProfile>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();

  Timer(const Duration(minutes: 5), () => link.close());

  final response = await dio.get('/kyc/status');
  return KycProfile.fromJson(response.data as Map<String, dynamic>);
});

/// Whether KYC is verified.
final isKycVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(kycProfileProvider).valueOrNull?.isVerified ?? false;
});

/// KYC level for limit display.
final kycLevelProvider = Provider<KycLevel>((ref) {
  return ref.watch(kycProfileProvider).valueOrNull?.level ?? KycLevel.none;
});

/// KYC submission actions.
class KycActions {
  final Dio _dio;

  KycActions(this._dio);

  Future<void> submitBasic({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String nationality,
  }) async {
    await _dio.post('/kyc/submit/basic', data: {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'nationality': nationality,
    });
  }

  Future<void> submitDocument({
    required String documentType,
    required String frontImagePath,
    String? backImagePath,
  }) async {
    final formData = FormData.fromMap({
      'documentType': documentType,
      'front': await MultipartFile.fromFile(frontImagePath),
      if (backImagePath != null)
        'back': await MultipartFile.fromFile(backImagePath),
    });
    await _dio.post('/kyc/submit/document', data: formData);
  }

  Future<void> submitSelfie(String imagePath) async {
    final formData = FormData.fromMap({
      'selfie': await MultipartFile.fromFile(imagePath),
    });
    await _dio.post('/kyc/submit/selfie', data: formData);
  }
}

final kycActionsProvider = Provider<KycActions>((ref) {
  return KycActions(ref.watch(dioProvider));
});
