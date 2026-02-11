import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/user.dart';
import 'package:usdc_wallet/services/service_providers.dart';

/// User profile state.
class ProfileState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isUploading;

  const ProfileState({this.user, this.isLoading = false, this.error, this.isUploading = false});

  ProfileState copyWith({User? user, bool? isLoading, String? error, bool? isUploading}) => ProfileState(
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    isUploading: isUploading ?? this.isUploading,
  );
}

/// Profile management notifier — wired to UserService.
class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(userServiceProvider);
      final profile = await service.getProfile();
      final user = User.fromJson(profile.toJson());
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      final service = ref.read(userServiceProvider);
      await service.updateProfile(firstName: name);
      await loadProfile();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> uploadAvatar(File file) async {
    state = state.copyWith(isUploading: true);
    try {
      final service = ref.read(userServiceProvider);
      await service.uploadAvatar(file.path);
      state = state.copyWith(isUploading: false);
      await loadProfile();
    } catch (e) {
      state = state.copyWith(isUploading: false, error: e.toString());
    }
  }

  Future<void> removeAvatar() async {
    try {
      final service = ref.read(userServiceProvider);
      await service.removeAvatar();
      await loadProfile();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateLocale(String locale) async {
    try {
      final service = ref.read(userServiceProvider);
      await service.updateLocale(locale);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
