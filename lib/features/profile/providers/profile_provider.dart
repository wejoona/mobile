import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/user.dart';
import '../../../services/api/api_client.dart';

/// User profile state.
class ProfileState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isUploading;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isUploading = false,
  });

  ProfileState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isUploading,
  }) => ProfileState(
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    isUploading: isUploading ?? this.isUploading,
  );
}

/// Profile management notifier.
class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Dio get _dio => ref.read(dioProvider);

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _dio.get('/user/profile');
      final user = User.fromJson(response.data as Map<String, dynamic>);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await _dio.put('/user/profile', data: {'displayName': name});
      state = state.copyWith(
        user: state.user, // Will refresh on next load
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> uploadAvatar(File file) async {
    state = state.copyWith(isUploading: true);
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: 'avatar.jpg',
        ),
      });
      await _dio.post('/user/avatar', data: formData);
      state = state.copyWith(isUploading: false);
      await loadProfile(); // Refresh to get new avatar URL
    } catch (e) {
      state = state.copyWith(isUploading: false, error: e.toString());
    }
  }

  Future<void> removeAvatar() async {
    try {
      await _dio.delete('/user/avatar');
      await loadProfile();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateLocale(String locale) async {
    try {
      await _dio.put('/user/locale', data: {'locale': locale});
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final profileProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
