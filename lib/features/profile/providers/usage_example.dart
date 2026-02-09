// USAGE EXAMPLES - Profile Provider with Avatar Support
// DO NOT import this file in production code - it's for reference only

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_provider.dart';

/// Example 1: Display user avatar in a widget
class UserAvatarWidget extends ConsumerWidget {
  const UserAvatarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return CircleAvatar(
      radius: 40,
      backgroundImage: profileState.hasAvatar
          ? NetworkImage(profileState.avatarUrl!)
          : null,
      child: !profileState.hasAvatar
          ? const Icon(Icons.person, size: 40)
          : null,
    );
  }
}

/// Example 2: Upload avatar from camera or gallery
class AvatarUploadExample extends ConsumerStatefulWidget {
  const AvatarUploadExample({super.key});

  @override
  ConsumerState<AvatarUploadExample> createState() => _AvatarUploadExampleState();
}

class _AvatarUploadExampleState extends ConsumerState<AvatarUploadExample> {
  final _picker = ImagePicker();

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      // Pick image from camera or gallery
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);

        // Upload via profile provider
        final success = await ref.read(profileProvider.notifier).updateAvatar(file);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avatar updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload avatar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Column(
      children: [
        // Display current avatar
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: profileState.hasAvatar
                  ? NetworkImage(profileState.avatarUrl!)
                  : null,
              child: !profileState.hasAvatar
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
            if (profileState.isUploadingAvatar)
              const Positioned.fill(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Upload buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickAndUploadAvatar(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _pickAndUploadAvatar(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),
          ],
        ),

        // Remove avatar button
        if (profileState.hasAvatar)
          TextButton.icon(
            onPressed: () async {
              final success = await ref.read(profileProvider.notifier).removeAvatar();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Avatar removed')),
                );
              }
            },
            icon: const Icon(Icons.delete),
            label: const Text('Remove Avatar'),
          ),
      ],
    );
  }
}

/// Example 3: Update profile information
class ProfileEditExample extends ConsumerStatefulWidget {
  const ProfileEditExample({super.key});

  @override
  ConsumerState<ProfileEditExample> createState() => _ProfileEditExampleState();
}

class _ProfileEditExampleState extends ConsumerState<ProfileEditExample> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileProvider).user;
    _firstNameController = TextEditingController(text: user?.firstName);
    _lastNameController = TextEditingController(text: user?.lastName);
    _emailController = TextEditingController(text: user?.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(profileProvider.notifier).updateProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(labelText: 'First Name'),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(labelText: 'Last Name'),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: profileState.isLoading ? null : _saveProfile,
            child: profileState.isLoading
                ? const CircularProgressIndicator()
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// Example 4: Load profile on screen init
class ProfileScreenExample extends ConsumerStatefulWidget {
  const ProfileScreenExample({super.key});

  @override
  ConsumerState<ProfileScreenExample> createState() => _ProfileScreenExampleState();
}

class _ProfileScreenExampleState extends ConsumerState<ProfileScreenExample> {
  @override
  void initState() {
    super.initState();
    // Load profile when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    if (profileState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${profileState.error}'),
            ElevatedButton(
              onPressed: () => ref.read(profileProvider.notifier).loadProfile(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 50,
          backgroundImage: profileState.hasAvatar
              ? NetworkImage(profileState.avatarUrl!)
              : null,
          child: !profileState.hasAvatar
              ? const Icon(Icons.person, size: 50)
              : null,
        ),
        const SizedBox(height: 16),

        // User info
        Text(
          profileState.displayName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          profileState.user?.phone ?? '',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

/// Example 5: Pull to refresh profile
class ProfileWithRefreshExample extends ConsumerWidget {
  const ProfileWithRefreshExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(profileProvider.notifier).refresh(),
      child: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: profileState.hasAvatar
                  ? NetworkImage(profileState.avatarUrl!)
                  : null,
            ),
            title: Text(profileState.displayName),
            subtitle: Text(profileState.user?.email ?? 'No email'),
          ),
        ],
      ),
    );
  }
}

/// Example 6: Get avatar URL independently
class AvatarUrlExample extends ConsumerWidget {
  const AvatarUrlExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final url = await ref.read(profileProvider.notifier).getAvatarUrl();
        if (url != null) {
          print('Avatar URL: $url');
        } else {
          print('No avatar set');
        }
      },
      child: const Text('Get Avatar URL'),
    );
  }
}
