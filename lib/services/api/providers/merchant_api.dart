/// Merchant API — QR payments, dashboard
library;

import 'package:dio/dio.dart';

class MerchantApi {
  MerchantApi(this._dio);
  final Dio _dio;

  /// POST /merchant/payments
  Future<Response> pay(Map<String, dynamic> data) =>
      _dio.post('/merchant/payments', data: data);

  /// GET /merchant/qr
  Future<Response> getQr() => _dio.get('/merchant/qr');

  /// GET /merchant/dashboard
  Future<Response> dashboard() => _dio.get('/merchant/dashboard');
}
