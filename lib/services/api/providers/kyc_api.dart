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

  /// POST /kyc/upload — upload KYC document
  Future<Response> uploadDocument(File file, {String? type}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      if (type != null) 'type': type,
    });
    return _dio.post('/kyc/upload', data: formData);
  }
}
