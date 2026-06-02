/// Sub-business API service - mirrors backend SubBusinessController.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

class SubBusinessService {
  final Dio _dio;

  SubBusinessService(this._dio);

  /// GET /sub-businesses
  Future<List<SubBusinessItem>> getSubBusinesses() async {
    try {
      final response = await _dio.get('/sub-businesses');
      final data = response.data;
      final items = data is List
          ? data
          : data is Map
          ? (data['items'] ?? data['data'] ?? data['subBusinesses']) as List? ??
                []
          : const [];
      return items
          .map((e) => SubBusinessItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /sub-businesses
  Future<SubBusinessItem> create({
    required String name,
    required String type,
    String? walletId,
    String? description,
    String? address,
  }) async {
    try {
      final resolvedWalletId = walletId ?? await _currentWalletId();
      final response = await _dio.post(
        '/sub-businesses',
        data: {
          'name': name,
          'type': _backendSubBusinessType(type),
          'walletId': resolvedWalletId,
          if (description != null) 'description': description,
        },
      );
      return SubBusinessItem.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /sub-businesses/:id
  Future<SubBusinessItem> getById(String id) async {
    try {
      final response = await _dio.get('/sub-businesses/$id');
      return SubBusinessItem.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// PATCH /sub-businesses/:id
  Future<SubBusinessItem> update(
    String id, {
    String? name,
    String? description,
    String? address,
    bool? isActive,
  }) async {
    try {
      final response = await _dio.patch(
        '/sub-businesses/$id',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
        },
      );
      return SubBusinessItem.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /sub-businesses/:id/staff
  Future<List<StaffMember>> getStaff(String businessId) async {
    try {
      final response = await _dio.get('/sub-businesses/$businessId/staff');
      // ignore: avoid_dynamic_calls
      return (response.data['staff'] as List<dynamic>)
          .map((e) => StaffMember.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (_isMissingEndpoint(e)) return const [];
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /sub-businesses/:id/staff
  Future<StaffMember> addStaff(
    String businessId, {
    required String phone,
    required String role,
    String? name,
  }) async {
    try {
      final response = await _dio.post(
        '/sub-businesses/$businessId/staff',
        data: {'phone': phone, 'role': role, if (name != null) 'name': name},
      );
      return StaffMember.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// DELETE /sub-businesses/:id/staff/:staffId
  Future<void> removeStaff(String businessId, String staffId) async {
    try {
      await _dio.delete('/sub-businesses/$businessId/staff/$staffId');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<String> _currentWalletId() async {
    final response = await _dio.get('/wallet');
    final data = response.data;
    if (data is Map) {
      final walletId = data['walletId'] as String? ?? data['id'] as String?;
      if (walletId != null && walletId.isNotEmpty) return walletId;
    }
    throw const FormatException('Current wallet id is required');
  }
}

bool _isMissingEndpoint(DioException e) {
  final statusCode = e.response?.statusCode;
  return statusCode == 404 || statusCode == 405;
}

// Models

class SubBusinessItem {
  final String id;
  final String name;
  final String type;
  final String? description;
  final String? address;
  final bool isActive;
  final int staffCount;
  final double totalRevenue;
  final DateTime createdAt;

  const SubBusinessItem({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.address,
    required this.isActive,
    required this.staffCount,
    required this.totalRevenue,
    required this.createdAt,
  });

  factory SubBusinessItem.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? json['_status'] as String?;
    return SubBusinessItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['_name'] as String? ?? '',
      type: json['type'] as String? ?? json['_type'] as String? ?? '',
      description:
          json['description'] as String? ?? json['_description'] as String?,
      address: json['address'] as String?,
      isActive: json['isActive'] as bool? ?? status == 'active',
      staffCount: json['staffCount'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

class StaffMember {
  final String id;
  final String name;
  final String phone;
  final String role;
  final bool isActive;
  final DateTime joinedAt;

  const StaffMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.joinedAt,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? 'viewer',
      isActive: json['isActive'] as bool? ?? true,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
    );
  }
}

String _backendSubBusinessType(String type) {
  return type == 'subsidiary' ? 'branch' : type;
}

final subBusinessServiceProvider = Provider<SubBusinessService>((ref) {
  return SubBusinessService(ref.watch(dioProvider));
});
