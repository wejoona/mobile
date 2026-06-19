import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/profile/providers/profile_provider.dart';
import 'package:usdc_wallet/features/profile/services/profile_picture_service.dart';
import 'package:usdc_wallet/features/settings/utils/profile_phone_formatter.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/image_analysis/image_analysis_service.dart';
import 'package:usdc_wallet/services/user/avatar_multipart.dart';
import 'package:usdc_wallet/services/user/user_service.dart';
import 'package:usdc_wallet/state/index.dart';

enum _AvatarAction { camera, gallery, remove }

/// Profile Edit Screen
/// Allows users to update their personal information
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;
  String? _avatarUrl;
  String? _avatarThumb;
  String? _profilePhotoStatus;

  bool get _hasAvatar =>
      _selectedImage != null ||
      (_avatarUrl != null && _avatarUrl!.isNotEmpty) ||
      (_avatarThumb != null && _avatarThumb!.isNotEmpty);

  String? get _effectiveAvatarImage {
    if (_selectedImage != null) {
      return _selectedImage!.path;
    }

    final avatarUrl = _avatarUrl?.trim();
    final avatarThumb = _avatarThumb?.trim();
    if (avatarThumb != null && avatarThumb.isNotEmpty) {
      return avatarThumb;
    }
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return avatarUrl;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userState = ref.read(userStateMachineProvider);
      _hydrateFormFromUserState(userState);
      unawaited(_recoverLostProfileImage());
      unawaited(_refreshProfileSnapshot());
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userState = ref.watch(userStateMachineProvider);

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.settings_profile,
          variant: AppTextVariant.titleLarge,
          color: context.colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.gold),
          onPressed: () => context.safePop(fallbackRoute: '/settings'),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              // Avatar section
              _buildAvatarSection(userState),

              const SizedBox(height: AppSpacing.xxxl),

              // Username
              AppInput(
                label: _usernameLabel(context),
                controller: _usernameController,
                hint: '@ben_ouattara',
                keyboardType: TextInputType.text,
                validator: (value) {
                  final normalized = _normalizeUsername(value);
                  if (normalized == null) return null;
                  if (normalized.length < 3 || normalized.length > 20) {
                    return _usernameLengthError(context);
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(normalized)) {
                    return _usernameFormatError(context);
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // First Name
              AppInput(
                label: l10n.profile_firstName,
                controller: _firstNameController,
                hint: l10n.onboarding_profile_firstNameHint,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.onboarding_profile_firstNameRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Last Name
              AppInput(
                label: l10n.profile_lastName,
                controller: _lastNameController,
                hint: l10n.onboarding_profile_lastNameHint,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.onboarding_profile_lastNameRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Email (Optional)
              AppInput(
                label: l10n.onboarding_profile_email,
                controller: _emailController,
                hint: l10n.onboarding_profile_emailHint,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return l10n.onboarding_profile_emailInvalid;
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Phone Number (Read-only)
              AppText(
                l10n.profile_phoneNumber,
                variant: AppTextVariant.labelMedium,
                color: context.colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: context.colors.textSecondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      color: context.colors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppText(
                        formatProfilePhone(userState.phone),
                        variant: AppTextVariant.bodyLarge,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    Icon(
                      Icons.lock_outline,
                      color: context.colors.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                l10n.profile_phoneCannotChange,
                variant: AppTextVariant.bodySmall,
                color: context.colors.textSecondary,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Save Button
              AppButton(
                label: l10n.action_save,
                onPressed: _isLoading ? null : _handleSave,
                isLoading: _isLoading,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(UserState userState) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _isLoading ? null : _pickProfileImage,
            child: Stack(
              children: [
                UserAvatar(
                  imageUrl: _effectiveAvatarImage,
                  firstName: userState.firstName,
                  lastName: userState.lastName,
                  size: UserAvatar.sizeXLarge,
                ),
                if (_isLoading)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.34),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.colors.goldLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.colors.gold,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: context.colors.canvas,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: context.colors.textInverse,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _profilePhotoStatus == null
                ? const SizedBox(height: AppSpacing.md)
                : Padding(
                    key: ValueKey(_profilePhotoStatus),
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: AppText(
                      _profilePhotoStatus!,
                      variant: AppTextVariant.bodySmall,
                      color: context.colors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _setProfilePhotoBusy(String? message) {
    if (!mounted) return;
    setState(() {
      _isLoading = message != null;
      _profilePhotoStatus = message;
    });
  }

  void _hydrateFormFromUserState(UserState userState) {
    if (!mounted) return;
    setState(() {
      _usernameController.text = userState.username ?? '';
      _firstNameController.text = userState.firstName ?? '';
      _lastNameController.text = userState.lastName ?? '';
      _emailController.text = userState.email ?? '';
      _avatarUrl = userState.avatarUrl;
      _avatarThumb = userState.avatarThumb;
    });
  }

  Future<void> _refreshProfileSnapshot() async {
    await ref.read(profileProvider.notifier).loadProfile();
    if (!mounted || _selectedImage != null || _profilePhotoStatus != null) {
      return;
    }

    _hydrateFormFromUserState(ref.read(userStateMachineProvider));
  }

  void _showProfilePhotoSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? context.colors.error
            : context.colors.success,
      ),
    );
  }

  String _profilePhotoPickErrorMessage(Object error) {
    if (error is PlatformException) {
      final code = error.code.toLowerCase();
      if (code.contains('denied') || code.contains('restricted')) {
        return 'Camera or photo permission is needed to update your profile photo.';
      }
      return error.message ??
          'Unable to use this photo. Please choose another clear selfie.';
    }
    return 'Unable to use this photo. Please choose another clear selfie.';
  }

  Future<void> _pickProfileImage() async {
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.md,
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
          ),
          child: Wrap(
            runSpacing: AppSpacing.sm,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                variant: AppCardVariant.flat,
                onTap: () => Navigator.pop(ctx, _AvatarAction.camera),
                child: Row(
                  children: [
                    Icon(Icons.camera_alt, color: context.colors.gold),
                    const SizedBox(width: AppSpacing.md),
                    AppText(
                      AppLocalizations.of(context)!.settings_takePhoto,
                      variant: AppTextVariant.bodyLarge,
                    ),
                  ],
                ),
              ),
              AppCard(
                variant: AppCardVariant.flat,
                onTap: () => Navigator.pop(ctx, _AvatarAction.gallery),
                child: Row(
                  children: [
                    Icon(Icons.photo_library, color: context.colors.gold),
                    const SizedBox(width: AppSpacing.md),
                    AppText(
                      AppLocalizations.of(context)!.settings_chooseFromGallery,
                      variant: AppTextVariant.bodyLarge,
                    ),
                  ],
                ),
              ),
              if (_hasAvatar)
                AppCard(
                  variant: AppCardVariant.flat,
                  onTap: () => Navigator.pop(ctx, _AvatarAction.remove),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: context.colors.error),
                      const SizedBox(width: AppSpacing.md),
                      AppText(
                        AppLocalizations.of(context)!.settings_removePhoto,
                        variant: AppTextVariant.bodyLarge,
                        color: context.colors.errorText,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await _handleAvatarAction(action);
  }

  Future<void> _handleAvatarAction(_AvatarAction? action) async {
    if (action == null) return;
    if (action == _AvatarAction.remove) {
      await _removeProfileImage();
      return;
    }

    _setProfilePhotoBusy('Opening photo picker...');
    try {
      final pictureService = ref.read(profilePictureServiceProvider);
      final picked = action == _AvatarAction.camera
          ? await pictureService.pickFromCamera()
          : await pictureService.pickFromGallery();

      if (picked == null) {
        return;
      }

      await _processProfileImage(picked);
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() => _selectedImage = null);
      _showProfilePhotoSnack(
        _profilePhotoPickErrorMessage(error),
        isError: true,
      );
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _selectedImage = null);
      _showProfilePhotoSnack(
        _profilePhotoPickErrorMessage(error),
        isError: true,
      );
    } finally {
      _setProfilePhotoBusy(null);
    }
  }

  Future<void> _recoverLostProfileImage() async {
    try {
      final recovered = await ref
          .read(profilePictureServiceProvider)
          .retrieveLostImage();
      if (!mounted || recovered == null) {
        return;
      }
      await _processProfileImage(recovered);
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showProfilePhotoSnack(
        _profilePhotoPickErrorMessage(error),
        isError: true,
      );
    } on Exception catch (error) {
      if (!mounted) return;
      _showProfilePhotoSnack(
        _profilePhotoPickErrorMessage(error),
        isError: true,
      );
    } finally {
      _setProfilePhotoBusy(null);
    }
  }

  Future<void> _processProfileImage(File picked) async {
    final pictureService = ref.read(profilePictureServiceProvider);
    _setProfilePhotoBusy('Preparing photo...');
    final compressed = await pictureService.compressImage(picked);
    var uploadImage = compressed;
    _setProfilePhotoBusy('Checking face on this device...');
    var faceDetection = await ref
        .read(imageAnalysisServiceProvider)
        .detectFaces(compressed);
    if (!mounted) return;

    if (_shouldRetryProfileFaceCheck(faceDetection)) {
      _setProfilePhotoBusy('Retrying face check on a clearer photo...');
      final faceCheckImage = await pictureService.prepareForFaceDetection(
        compressed,
      );
      uploadImage = faceCheckImage;
      faceDetection = await ref
          .read(imageAnalysisServiceProvider)
          .detectFaces(faceCheckImage);
      if (!mounted) return;
    }

    if (!faceDetection.isAvailable || !faceDetection.hasExactlyOneFace) {
      setState(() => _selectedImage = null);
      _showProfilePhotoSnack(
        _profilePhotoFaceMessage(faceDetection),
        isError: true,
      );
      return;
    }
    final faceCheck = AvatarDeviceFaceCheck.fromDeviceAnalysis(
      isAvailable: faceDetection.isAvailable,
      faceCount: faceDetection.faceCount,
    );

    _setProfilePhotoBusy('Uploading photo...');
    setState(() {
      _selectedImage = uploadImage;
    });

    final uploadResult = await ref
        .read(profileProvider.notifier)
        .uploadAvatar(uploadImage, faceCheck: faceCheck);
    final profileState = ref.read(profileProvider);
    if (!mounted) return;

    final uploadedAvatar = uploadResult;
    if (uploadedAvatar == null ||
        !((uploadedAvatar.avatarUrl?.isNotEmpty ?? false) ||
            (uploadedAvatar.avatarThumb?.isNotEmpty ?? false))) {
      setState(() => _selectedImage = null);
      _showProfilePhotoSnack(
        profileState.error ??
            'Unable to upload your photo. Please try another image.',
        isError: true,
      );
      return;
    }

    final userState = ref.read(userStateMachineProvider);
    setState(() {
      _selectedImage = null;
      _avatarUrl = uploadedAvatar.avatarUrl ?? userState.avatarUrl;
      _avatarThumb = uploadedAvatar.avatarThumb ?? userState.avatarThumb;
    });

    _showProfilePhotoSnack(
      AppLocalizations.of(context)!.settings_profileUpdated,
      isError: false,
    );
  }

  bool _shouldRetryProfileFaceCheck(FaceDetectionResult result) =>
      !result.isAvailable || result.faceCount == 0;

  String _profilePhotoFaceMessage(FaceDetectionResult result) {
    if (!result.isAvailable) {
      return result.message ??
          'Unable to check the face on this device. Please try again or use a clearer selfie.';
    }
    if (result.faceCount == 0) {
      return 'No face detected. Please choose a clear photo of your face.';
    }
    return 'Please use a photo with only your face visible.';
  }

  Future<void> _removeProfileImage() async {
    final hadRemoteAvatar =
        (_avatarUrl != null && _avatarUrl!.isNotEmpty) ||
        (_avatarThumb != null && _avatarThumb!.isNotEmpty);

    setState(() => _isLoading = true);

    try {
      if (hadRemoteAvatar) {
        await ref.read(profileProvider.notifier).removeAvatar();
      } else {
        await ref.read(userStateMachineProvider.notifier).clearAvatar();
      }

      if (!mounted) return;
      setState(() {
        _selectedImage = null;
        _avatarUrl = null;
        _avatarThumb = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.settings_photoRemoved),
          backgroundColor: context.colors.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.settings_failedToRemovePhoto,
          ),
          backgroundColor: context.colors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _normalizeUsername(String? value) {
    final normalized = value?.trim().replaceFirst(RegExp(r'^@+'), '');
    if (normalized == null || normalized.isEmpty) return null;
    return normalized.toLowerCase();
  }

  String _usernameLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'fr' ? "Nom d'utilisateur" : 'Username';
  }

  String _usernameLengthError(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'fr'
        ? 'Le nom d’utilisateur doit contenir 3 à 20 caractères.'
        : 'Username must be 3 to 20 characters.';
  }

  String _usernameFormatError(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'fr'
        ? 'Utilisez uniquement lettres, chiffres et underscore.'
        : 'Use only letters, numbers, and underscores.';
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final previousEmail = ref
        .read(userStateMachineProvider)
        .email
        ?.trim()
        .toLowerCase();
    final submittedEmail = _emailController.text.trim();
    final submittedEmailKey = submittedEmail.toLowerCase();
    final changedEmail =
        submittedEmail.isNotEmpty && submittedEmailKey != previousEmail;

    setState(() => _isLoading = true);

    try {
      final profile = await ref
          .read(userServiceProvider)
          .updateProfile(
            username: _normalizeUsername(_usernameController.text),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            clearEmail: _emailController.text.trim().isEmpty,
          );

      await ref.read(profileProvider.notifier).applyProfileSnapshot(profile);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.settings_profileUpdated),
          backgroundColor: context.colors.success,
        ),
      );

      final savedEmail = profile.email?.trim();
      if (changedEmail &&
          savedEmail != null &&
          savedEmail.isNotEmpty &&
          !profile.emailVerified) {
        final successRoute = Uri.encodeComponent('/settings/profile');
        context.go('/profile/verify-email?successRoute=$successRoute');
      } else {
        context.safePop(fallbackRoute: '/settings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_profileSaveErrorMessage(e)),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _profileSaveErrorMessage(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 401) {
        return AppLocalizations.of(context)!.error_sessionExpired;
      }
      if (error.message.trim().isNotEmpty) {
        return error.message;
      }
    }
    return AppLocalizations.of(context)!.settings_failedToUpdateProfile;
  }
}
