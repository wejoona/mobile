import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../../settings/widgets/settings_section.dart';
import '../../kyc/providers/kyc_provider.dart';

/// Profile screen with user info, settings shortcuts, and KYC status.
class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final kycVerified = ref.watch(isKycVerifiedProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          if (profileState.user != null)
            ProfileHeader(
              user: profileState.user!,
              onEditAvatar: () => _pickAvatar(context, ref),
            ),
          const SizedBox(height: 8),

          SettingsSection(
            title: 'Account',
            items: [
              SettingsItem(leading: const Icon(Icons.person_outline_rounded), title: 'Personal Info', onTap: () {}),
              SettingsItem(
                leading: Icon(Icons.verified_user_rounded, color: kycVerified ? Colors.green : null),
                title: 'KYC Verification',
                subtitle: kycVerified ? 'Verified' : 'Complete to increase limits',
                onTap: () {},
              ),
              SettingsItem(leading: const Icon(Icons.translate_rounded), title: 'Language', subtitle: 'Francais', onTap: () {}),
            ],
          ),

          SettingsSection(
            title: 'Security',
            items: [
              SettingsItem(leading: const Icon(Icons.lock_outline_rounded), title: 'Security Settings', onTap: () {}),
              SettingsItem(leading: const Icon(Icons.devices_rounded), title: 'Active Devices', onTap: () {}),
            ],
          ),

          SettingsSection(
            title: 'About',
            items: [
              SettingsItem(leading: const Icon(Icons.description_outlined), title: 'Terms of Service', onTap: () {}),
              SettingsItem(leading: const Icon(Icons.privacy_tip_outlined), title: 'Privacy Policy', onTap: () {}),
              SettingsItem(leading: const Icon(Icons.help_outline_rounded), title: 'Help & Support', onTap: () {}),
            ],
          ),

          SettingsSection(
            items: [
              SettingsItem(leading: const Icon(Icons.logout_rounded), title: 'Log Out', isDestructive: true, onTap: () {}),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 80);
    if (image != null) {
      ref.read(profileProvider.notifier).uploadAvatar(File(image.path));
    }
  }
}
