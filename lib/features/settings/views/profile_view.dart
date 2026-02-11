import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/state/index.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final userState = ref.watch(userStateMachineProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.profile_title,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.safePop(fallbackRoute: '/home'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: colors.gold),
            onPressed: () => context.push('/settings/profile/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.goldGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.goldGlow,
                ),
                child: Center(
                  child: AppText(
                    _getInitials(userState),
                    variant: AppTextVariant.headlineLarge,
                    color: AppColors.textInverse,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Phone (non-editable)
            _buildInfoCard(
              label: l10n.profile_phoneNumber,
              value: userState.phone ?? l10n.profile_notSet,
              icon: Icons.phone,
              isVerified: true,
            ),

            const SizedBox(height: AppSpacing.md),

            // First Name
            _buildInfoCard(
              label: l10n.profile_firstName,
              value: userState.firstName ?? l10n.profile_notSet,
              icon: Icons.person,
            ),

            const SizedBox(height: AppSpacing.md),

            // Last Name
            _buildInfoCard(
              label: l10n.profile_lastName,
              value: userState.lastName ?? l10n.profile_notSet,
              icon: Icons.person_outline,
            ),

            const SizedBox(height: AppSpacing.md),

            // Email
            _buildInfoCard(
              label: l10n.profile_email,
              value: userState.email ?? l10n.profile_notSet,
              icon: Icons.email,
            ),

            const SizedBox(height: AppSpacing.md),

            // KYC Status
            _buildInfoCard(
              label: l10n.profile_kycStatus,
              value: _getKycStatusText(userState.kycStatus, l10n),
              icon: Icons.verified_user,
              valueColor: _getKycStatusColor(userState.kycStatus),
              trailing: userState.kycStatus != KycStatus.verified
                  ? TextButton(
                      onPressed: () => context.push('/settings/kyc'),
                      child: AppText(
                        l10n.profile_verify,
                        variant: AppTextVariant.labelMedium,
                        color: AppColors.gold500,
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: AppSpacing.md),

            // Country
            _buildInfoCard(
              label: l10n.profile_country,
              value: _getCountryName(userState.countryCode, l10n),
              icon: Icons.public,
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
    bool isVerified = false,
    Widget? trailing,
  }) {
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.subtle,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: colors.textSecondary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        value,
                        variant: AppTextVariant.bodyLarge,
                        color: valueColor ?? colors.textPrimary,
                      ),
                    ),
                    if (isVerified)
                      const Icon(
                        Icons.verified,
                        color: AppColors.successBase,
                        size: 18,
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  String _getInitials(UserState userState) {
    final firstName = userState.firstName;
    final lastName = userState.lastName;

    if (firstName != null && lastName != null) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName != null) {
      return firstName.substring(0, firstName.length >= 2 ? 2 : 1).toUpperCase();
    } else if (userState.phone != null) {
      return userState.phone!.substring(userState.phone!.length - 2);
    }
    return 'U';
  }

  String _getKycStatusText(KycStatus status, AppLocalizations l10n) {
    switch (status) {
      case KycStatus.none:
        return l10n.profile_kycNotVerified;
      case KycStatus.pending:
      case KycStatus.documentsPending:
        return l10n.profile_kycPending;
      case KycStatus.submitted:
        return l10n.profile_kycPending;
      case KycStatus.verified:
        return l10n.profile_kycVerified;
      case KycStatus.rejected:
        return l10n.profile_kycRejected;
      case KycStatus.additionalInfoNeeded:
        return l10n.profile_kycPending;
    }
  }

  Color _getKycStatusColor(KycStatus status) {
    switch (status) {
      case KycStatus.none:
        return AppColors.textSecondary;
      case KycStatus.pending:
      case KycStatus.documentsPending:
      case KycStatus.submitted:
      case KycStatus.additionalInfoNeeded:
        return AppColors.warningBase;
      case KycStatus.verified:
        return AppColors.successBase;
      case KycStatus.rejected:
        return AppColors.errorBase;
    }
  }

  String _getCountryName(String countryCode, AppLocalizations l10n) {
    switch (countryCode) {
      case 'CI':
        return l10n.profile_countryIvoryCoast;
      case 'NG':
        return l10n.profile_countryNigeria;
      case 'GH':
        return l10n.profile_countryGhana;
      case 'SN':
        return l10n.profile_countrySenegal;
      default:
        return countryCode;
    }
  }

}
