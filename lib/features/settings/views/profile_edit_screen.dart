import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/profile/providers/profile_provider.dart';
import 'package:usdc_wallet/features/profile/services/profile_picture_service.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:usdc_wallet/services/image_analysis/image_analysis_service.dart';
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;
  String? _avatarUrl;
  String? _avatarThumb;

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
    if (avatarThumb != null &&
        avatarThumb.isNotEmpty &&
        _isProtectedRelativeAvatarUrl(avatarUrl)) {
      return avatarThumb;
    }
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return avatarUrl;
    }
    if (avatarThumb != null && avatarThumb.isNotEmpty) {
      return avatarThumb;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userState = ref.read(userStateMachineProvider);
      setState(() {
        _firstNameController.text = userState.firstName ?? '';
        _lastNameController.text = userState.lastName ?? '';
        _emailController.text = userState.email ?? '';
        _avatarUrl = userState.avatarUrl;
        _avatarThumb = userState.avatarThumb;
      });
    });
  }

  @override
  void dispose() {
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
                        _formatPhone(userState.phone),
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
      child: GestureDetector(
        onTap: _pickProfileImage,
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
            // Edit button
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.colors.gold,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: context.colors.canvas, width: 2),
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
    );
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

    if (action == null) return;
    if (action == _AvatarAction.remove) {
      await _removeProfileImage();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final pictureService = ref.read(profilePictureServiceProvider);
      final picked = action == _AvatarAction.camera
          ? await pictureService.pickFromCamera()
          : await pictureService.pickFromGallery();

      if (picked == null) {
        return;
      }

      final compressed = await pictureService.compressImage(picked);
      final faceCheck = await ref
          .read(imageAnalysisServiceProvider)
          .detectFaces(compressed);
      if (!mounted) return;

      if (!faceCheck.isAvailable || !faceCheck.hasExactlyOneFace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_profilePhotoFaceMessage(faceCheck)),
            backgroundColor: context.colors.error,
          ),
        );
        return;
      }

      setState(() {
        _selectedImage = compressed;
      });

      final uploadResult = await ref
          .read(profileProvider.notifier)
          .uploadAvatar(compressed);
      final profileState = ref.read(profileProvider);
      if (!mounted) return;

      if (profileState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileState.error!),
            backgroundColor: context.colors.error,
          ),
        );
        return;
      }

      final userState = ref.read(userStateMachineProvider);
      setState(() {
        _selectedImage = null;
        _avatarUrl = uploadResult?.avatarUrl ?? userState.avatarUrl;
        _avatarThumb = uploadResult?.avatarThumb ?? userState.avatarThumb;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.settings_profileUpdated),
          backgroundColor: context.colors.success,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    if (phone.startsWith('+') && phone.length > 6) {
      final countryCode = phone.substring(0, 4);
      final number = phone.substring(4);
      final formatted = number.replaceAllMapped(
        RegExp(r'.{2}'),
        (match) => '${match.group(0)} ',
      );
      return '$countryCode $formatted'.trim();
    }
    return phone;
  }

  bool _isProtectedRelativeAvatarUrl(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return value.startsWith('/user/avatar/');
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profile = await ref
          .read(userServiceProvider)
          .updateProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            clearEmail: _emailController.text.trim().isEmpty,
          );

      await ref.read(profileProvider.notifier).applyProfileSnapshot(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.settings_profileUpdated,
            ),
            backgroundColor: context.colors.success,
          ),
        );
        context.safePop(fallbackRoute: '/settings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.settings_failedToUpdateProfile,
            ),
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
}
