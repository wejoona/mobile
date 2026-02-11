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
      return (response.data['items'] as List<dynamic>)
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
    String? description,
    String? address,
  }) async {
    try {
      final response = await _dio.post('/sub-businesses', data: {
        'name': name,
        'type': type,
        if (description != null) 'description': description,
        if (address != null) 'address': address,
      });
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

  /// PUT /sub-businesses/:id
  Future<SubBusinessItem> update(String id, {
    String? name,
    String? description,
    String? address,
    bool? isActive,
  }) async {
    try {
      final response = await _dio.put('/sub-businesses/$id', data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (address != null) 'address': address,
        if (isActive != null) 'isActive': isActive,
      });
      return SubBusinessItem.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /sub-businesses/:id/staff
  Future<List<StaffMember>> getStaff(String businessId) async {
    try {
      final response = await _dio.get('/sub-businesses/$businessId/staff');
      return (response.data['staff'] as List<dynamic>)
          .map((e) => StaffMember.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /sub-businesses/:id/staff
  Future<StaffMember> addStaff(String businessId, {
    required String phone,
    required String role,
    String? name,
  }) async {
    try {
      final response = await _dio.post('/sub-businesses/$businessId/staff', data: {
        'phone': phone,
        'role': role,
        if (name != null) 'name': name,
      });
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
    return SubBusinessItem(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      staffCount: json['staffCount'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
      phone: json['phone'] as String,
      role: json['role'] as String,
      isActive: json['isActive'] as bool? ?? true,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}

final subBusinessServiceProvider = Provider<SubBusinessService>((ref) {
  return SubBusinessService(ref.watch(dioProvider));
});
