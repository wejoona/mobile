import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/biometric/biometric_service.dart';

class SecurityView extends ConsumerStatefulWidget {
  const SecurityView({super.key});

  @override
  ConsumerState<SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends ConsumerState<SecurityView> {
  bool _twoFactorEnabled = false;
  bool _transactionPinRequired = true;
  bool _loginNotifications = true;
  bool _newDeviceAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Security',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Score
            _buildSecurityScoreCard(),

            const SizedBox(height: AppSpacing.xxl),

            // Authentication Section
            const AppText(
              'Authentication',
              variant: AppTextVariant.titleMedium,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSecurityOption(
              icon: Icons.lock_outline,
              title: 'Change PIN',
              subtitle: 'Update your 4-digit PIN',
              onTap: () => context.push('/settings/pin'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildBiometricToggle(),
            const SizedBox(height: AppSpacing.sm),
            _buildToggleOption(
              icon: Icons.security,
              title: 'Two-Factor Authentication',
              subtitle: _twoFactorEnabled ? 'Enabled via Authenticator app' : 'Add extra protection',
              value: _twoFactorEnabled,
              onChanged: (value) => _handleTwoFactorToggle(value),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Transaction Security
            const AppText(
              'Transaction Security',
              variant: AppTextVariant.titleMedium,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildToggleOption(
              icon: Icons.pin,
              title: 'Require PIN for Transactions',
              subtitle: 'Confirm all transactions with PIN',
              value: _transactionPinRequired,
              onChanged: (value) => setState(() => _transactionPinRequired = value),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Alerts Section
            const AppText(
              'Security Alerts',
              variant: AppTextVariant.titleMedium,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildToggleOption(
              icon: Icons.login,
              title: 'Login Notifications',
              subtitle: 'Get notified of new logins',
              value: _loginNotifications,
              onChanged: (value) => setState(() => _loginNotifications = value),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildToggleOption(
              icon: Icons.devices,
              title: 'New Device Alerts',
              subtitle: 'Alert when a new device is used',
              value: _newDeviceAlerts,
              onChanged: (value) => setState(() => _newDeviceAlerts = value),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Session Management
            const AppText(
              'Sessions',
              variant: AppTextVariant.titleMedium,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSecurityOption(
              icon: Icons.smartphone,
              title: 'Active Sessions',
              subtitle: '2 devices logged in',
              onTap: () => _showActiveSessions(),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildSecurityOption(
              icon: Icons.logout,
              title: 'Log Out All Devices',
              subtitle: 'Sign out from all other devices',
              onTap: () => _confirmLogoutAll(),
              isDanger: true,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Privacy
            const AppText(
              'Privacy',
              variant: AppTextVariant.titleMedium,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSecurityOption(
              icon: Icons.history,
              title: 'Login History',
              subtitle: 'View recent login activity',
              onTap: () => _showLoginHistory(),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildSecurityOption(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              onTap: () => _confirmDeleteAccount(),
              isDanger: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityScoreCard() {
    final score = _calculateSecurityScore();
    final scoreColor = score >= 80
        ? AppColors.successBase
        : (score >= 60 ? AppColors.warningBase : AppColors.errorBase);

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        backgroundColor: AppColors.borderSubtle,
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      ),
                    ),
                    AppText(
                      '$score',
                      variant: AppTextVariant.headlineSmall,
                      color: scoreColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'Security Score',
                      variant: AppTextVariant.titleMedium,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      _getScoreDescription(score),
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (score < 100) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(color: AppColors.borderSubtle),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.gold500, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppText(
                    _getScoreTip(score),
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDanger
                    ? AppColors.errorBase.withValues(alpha: 0.1)
                    : AppColors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: isDanger ? AppColors.errorBase : AppColors.gold500,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.labelMedium,
                    color: isDanger ? AppColors.errorBase : AppColors.textPrimary,
                  ),
                  AppText(
                    subtitle,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDanger ? AppColors.errorBase : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.gold500, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textPrimary,
                ),
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.gold500,
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricToggle() {
    final biometricAvailable = ref.watch(biometricAvailableProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    return biometricAvailable.when(
      data: (available) {
        if (!available) {
          return _buildToggleOption(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Not available on this device',
            value: false,
            onChanged: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Biometric authentication is not available on this device'),
                  backgroundColor: AppColors.warningBase,
                ),
              );
            },
          );
        }

        return biometricEnabled.when(
          data: (enabled) => _buildToggleOption(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Use Face ID or fingerprint',
            value: enabled,
            onChanged: (value) async {
              final biometricService = ref.read(biometricServiceProvider);
              if (value) {
                // Verify biometric before enabling
                final authenticated = await biometricService.authenticate(
                  reason: 'Verify to enable biometric login',
                );
                if (authenticated) {
                  await biometricService.enableBiometric();
                  ref.invalidate(biometricEnabledProvider);
                }
              } else {
                await biometricService.disableBiometric();
                ref.invalidate(biometricEnabledProvider);
              }
            },
          ),
          loading: () => _buildToggleOption(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Loading...',
            value: false,
            onChanged: (_) {},
          ),
          error: (_, __) => _buildToggleOption(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Error loading state',
            value: false,
            onChanged: (_) {},
          ),
        );
      },
      loading: () => _buildToggleOption(
        icon: Icons.fingerprint,
        title: 'Biometric Login',
        subtitle: 'Checking availability...',
        value: false,
        onChanged: (_) {},
      ),
      error: (_, __) => _buildToggleOption(
        icon: Icons.fingerprint,
        title: 'Biometric Login',
        subtitle: 'Error checking availability',
        value: false,
        onChanged: (_) {},
      ),
    );
  }

  int _calculateSecurityScore() {
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final biometricsOn = biometricEnabled.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );

    int score = 40; // Base score for having account
    if (biometricsOn) score += 20;
    if (_twoFactorEnabled) score += 25;
    if (_transactionPinRequired) score += 10;
    if (_loginNotifications) score += 5;
    return score.clamp(0, 100);
  }

  String _getScoreDescription(int score) {
    if (score >= 90) return 'Excellent! Your account is well protected.';
    if (score >= 70) return 'Good security. A few improvements possible.';
    if (score >= 50) return 'Moderate security. Enable more features.';
    return 'Low security. Please enable protection features.';
  }

  String _getScoreTip(int score) {
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final biometricsOn = biometricEnabled.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );

    if (!_twoFactorEnabled) return 'Enable 2FA to increase your score by 25 points';
    if (!biometricsOn) return 'Enable biometrics for easier secure login';
    if (!_transactionPinRequired) return 'Require PIN for transactions for extra safety';
    return 'Enable all notifications for maximum security';
  }

  void _handleTwoFactorToggle(bool value) {
    if (value) {
      _showTwoFactorSetup();
    } else {
      _confirmDisableTwoFactor();
    }
  }

  void _showTwoFactorSetup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gold500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.security, color: AppColors.gold500, size: 40),
            ),
            const SizedBox(height: AppSpacing.lg),
            const AppText(
              'Set Up Two-Factor Authentication',
              variant: AppTextVariant.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            const AppText(
              'Use an authenticator app like Google Authenticator or Authy for enhanced security.',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Continue Setup',
              onPressed: () {
                Navigator.pop(context);
                setState(() => _twoFactorEnabled = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('2FA enabled successfully'),
                    backgroundColor: AppColors.successBase,
                  ),
                );
              },
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDisableTwoFactor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const AppText(
          'Disable 2FA?',
          variant: AppTextVariant.titleMedium,
        ),
        content: const AppText(
          'This will make your account less secure. Are you sure?',
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('Cancel', color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _twoFactorEnabled = false);
            },
            child: const AppText('Disable', color: AppColors.errorBase),
          ),
        ],
      ),
    );
  }

  void _showActiveSessions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Active Sessions',
              variant: AppTextVariant.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSessionItem(
              device: 'iPhone 15 Pro',
              location: 'San Francisco, CA',
              lastActive: 'Now (This device)',
              isCurrentDevice: true,
            ),
            const Divider(color: AppColors.borderSubtle),
            _buildSessionItem(
              device: 'MacBook Pro',
              location: 'San Francisco, CA',
              lastActive: '2 hours ago',
              isCurrentDevice: false,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Close',
              onPressed: () => Navigator.pop(context),
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem({
    required String device,
    required String location,
    required String lastActive,
    required bool isCurrentDevice,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            device.contains('iPhone') ? Icons.phone_iphone : Icons.laptop_mac,
            color: AppColors.gold500,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppText(
                      device,
                      variant: AppTextVariant.labelMedium,
                    ),
                    if (isCurrentDevice) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successBase.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: const AppText(
                          'Current',
                          variant: AppTextVariant.labelSmall,
                          color: AppColors.successBase,
                        ),
                      ),
                    ],
                  ],
                ),
                AppText(
                  '$location - $lastActive',
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogoutAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const AppText(
          'Log Out All Devices?',
          variant: AppTextVariant.titleMedium,
        ),
        content: const AppText(
          'You will be logged out from all other devices. You will need to log in again on those devices.',
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('Cancel', color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All other devices have been logged out'),
                  backgroundColor: AppColors.successBase,
                ),
              );
            },
            child: const AppText('Log Out All', color: AppColors.errorBase),
          ),
        ],
      ),
    );
  }

  void _showLoginHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Login History',
                variant: AppTextVariant.titleMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildLoginHistoryItem(
                      time: 'Today, 10:30 AM',
                      device: 'iPhone 15 Pro',
                      location: 'San Francisco, CA',
                      success: true,
                    ),
                    _buildLoginHistoryItem(
                      time: 'Yesterday, 3:45 PM',
                      device: 'MacBook Pro',
                      location: 'San Francisco, CA',
                      success: true,
                    ),
                    _buildLoginHistoryItem(
                      time: 'Yesterday, 9:12 AM',
                      device: 'Unknown Device',
                      location: 'New York, NY',
                      success: false,
                    ),
                    _buildLoginHistoryItem(
                      time: 'Jan 20, 2:30 PM',
                      device: 'iPhone 15 Pro',
                      location: 'Los Angeles, CA',
                      success: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginHistoryItem({
    required String time,
    required String device,
    required String location,
    required bool success,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: success
                    ? AppColors.successBase.withValues(alpha: 0.1)
                    : AppColors.errorBase.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check : Icons.close,
                color: success ? AppColors.successBase : AppColors.errorBase,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    device,
                    variant: AppTextVariant.labelMedium,
                  ),
                  AppText(
                    '$location - $time',
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            AppText(
              success ? 'Success' : 'Failed',
              variant: AppTextVariant.labelSmall,
              color: success ? AppColors.successBase : AppColors.errorBase,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const AppText(
          'Delete Account?',
          variant: AppTextVariant.titleMedium,
          color: AppColors.errorBase,
        ),
        content: const AppText(
          'This action is permanent and cannot be undone. All your data, transaction history, and funds will be lost.',
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('Cancel', color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Would show another confirmation
            },
            child: const AppText('Delete', color: AppColors.errorBase),
          ),
        ],
      ),
    );
  }
}
