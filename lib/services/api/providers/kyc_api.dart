/// KYC API — status, submit, upload
library;

import 'dart:io';
import 'package:dio/dio.dart';

class KycApi {
  KycApi(this._dio);
  final Dio _dio;

  /// GET /kyc/status
  Future<Response> getStatus() => _dio.get('/kyc/status');

  /// POST /kyc/submit
  Future<Response> submit(Map<String, dynamic> data) =>
      _dio.post('/kyc/submit', data: data);

  /// POST /kyc/documents — upload KYC document
  Future<Response> uploadDocument(File file, {String? type}) async {
    final fieldName = _fieldNameForType(type);
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(file.path),
    });
    return _dio.post('/kyc/documents', data: formData);
  }

  String _fieldNameForType(String? type) {
    switch ((type ?? 'idFront').replaceAll('_', '').toLowerCase()) {
      case 'idfront':
      case 'front':
        return 'idFront';
      case 'idback':
      case 'back':
        return 'idBack';
      case 'selfie':
        return 'selfie';
      case 'video':
        return 'video';
      default:
        throw ArgumentError('Unsupported KYC document type: $type');
    }
  }
}
