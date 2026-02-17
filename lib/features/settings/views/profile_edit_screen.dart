import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

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

  @override
  void initState() {
    super.initState();
    // Pre-fill with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(userStateMachineProvider);
      _firstNameController.text = userState.firstName ?? '';
      _lastNameController.text = userState.lastName ?? '';
      _emailController.text = userState.email ?? '';
      // Load existing avatar
      if (userState.avatarUrl != null && userState.avatarUrl!.startsWith('/')) {
        final file = File(userState.avatarUrl!);
        if (file.existsSync()) {
          setState(() => _selectedImage = file);
        }
      }
      _avatarUrl = userState.avatarUrl;
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
          'Modifier le profil',
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
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Avatar section
              _buildAvatarSection(userState),

              const SizedBox(height: AppSpacing.xxxl),

              // First Name
              AppText(
                'Prénom',
                variant: AppTextVariant.labelMedium,
                color: context.colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppInput(
                controller: _firstNameController,
                hint: 'Enter your first name',
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'First name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Last Name
              AppText(
                'Nom de famille',
                variant: AppTextVariant.labelMedium,
                color: context.colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppInput(
                controller: _lastNameController,
                hint: 'Enter your last name',
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Last name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Last name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Email (Optional)
              AppText(
                'E-mail (optionnel)',
                variant: AppTextVariant.labelMedium,
                color: context.colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppInput(
                controller: _emailController,
                hint: 'your@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Phone Number (Read-only)
              AppText(
                'Numéro de téléphone',
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
                'Le numéro de téléphone ne peut pas être modifié',
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
            // Avatar
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: _selectedImage == null
                    ? LinearGradient(
                        colors: context.colors.goldGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: AppShadows.goldGlow,
                image: _selectedImage != null
                    ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : _avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
              ),
              child: _selectedImage == null && _avatarUrl == null
                  ? Center(
                      child: AppText(
                        _getInitials(userState),
                        variant: AppTextVariant.displaySmall,
                        color: context.colors.textInverse,
                      ),
                    )
                  : null,
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
    );
  }

  Future<void> _pickProfileImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.settings_takePhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.settings_chooseFromGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadProfileImage(File image) async {
    try {
      final dio = ref.read(dioProvider);
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          image.path,
          filename: 'avatar.jpg',
        ),
      });

      final response = await dio.post('/user/avatar', data: formData);

      // ignore: avoid_dynamic_calls
      if (response.data['success'] == true) {
        // ignore: avoid_dynamic_calls
        return response.data['data']?['avatarUrl'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _getInitials(UserState userState) {
    final firstName = userState.firstName;
    final lastName = userState.lastName;

    if (firstName != null && firstName.isNotEmpty && lastName != null && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName != null && firstName.isNotEmpty) {
      return firstName.substring(0, firstName.length >= 2 ? 2 : 1).toUpperCase();
    } else if (userState.phone != null && userState.phone!.length >= 2) {
      return userState.phone!.substring(userState.phone!.length - 2);
    }
    return 'U';
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? savedAvatarUrl;

      // Save profile image locally + attempt backend upload
      if (_selectedImage != null) {
        // Save to app documents for persistence
        final appDir = await getApplicationDocumentsDirectory();
        final savedPath = '${appDir.path}/profile_avatar.jpg';
        await _selectedImage!.copy(savedPath);
        savedAvatarUrl = savedPath;

        // Persist local path for app restart
        const storage = FlutterSecureStorage();
        await storage.write(key: 'local_avatar_path', value: savedPath);

        // Also try uploading to backend (best-effort)
        final url = await _uploadProfileImage(_selectedImage!);
        if (url != null) {
          savedAvatarUrl = url; // Prefer server URL if available
        }
      }

      // Update backend profile (best-effort)
      final dio = ref.read(dioProvider);
      try {
        await dio.put('/user/profile', data: {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          if (_emailController.text.trim().isNotEmpty)
            'email': _emailController.text.trim(),
        });
      } catch (_) {
        // Backend update failed — still save locally
      }

      // Update local state (including avatar)
      ref.read(userStateMachineProvider.notifier).updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        avatarUrl: savedAvatarUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.settings_profileUpdated),
            backgroundColor: context.colors.success,
          ),
        );
        context.safePop(fallbackRoute: '/settings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.settings_failedToUpdateProfile),
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
