import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/business_profile.dart';
import 'package:usdc_wallet/domain/enums/account_type.dart';
import 'package:usdc_wallet/services/business/business_service.dart';

/// Business State
class BusinessState {
  final bool isLoading;
  final String? error;
  final AccountType accountType;
  final BusinessProfile? businessProfile;

  const BusinessState({
    this.isLoading = false,
    this.error,
    this.accountType = AccountType.personal,
    this.businessProfile,
  });

  BusinessState copyWith({
    bool? isLoading,
    String? error,
    AccountType? accountType,
    BusinessProfile? businessProfile,
  }) {
    return BusinessState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      accountType: accountType ?? this.accountType,
      businessProfile: businessProfile ?? this.businessProfile,
    );
  }

  bool get isBusinessAccount => accountType == AccountType.business;
}

/// Business Notifier
class BusinessNotifier extends Notifier<BusinessState> {
  @override
  BusinessState build() {
    _loadAccountType();
    return const BusinessState();
  }

  BusinessService get _businessService => ref.read(businessServiceProvider);

  /// Load account type from backend
  Future<void> _loadAccountType() async {
    state = state.copyWith(isLoading: true);

    try {
      final accountType = await _businessService.getAccountType();
      state = state.copyWith(
        isLoading: false,
        accountType: accountType,
      );

      // If business account, load profile
      if (accountType == AccountType.business) {
        await loadBusinessProfile();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load business profile
  Future<void> loadBusinessProfile() async {
    state = state.copyWith(isLoading: true);

    try {
      final profile = await _businessService.getBusinessProfile();
      state = state.copyWith(
        isLoading: false,
        businessProfile: profile,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Switch account type
  Future<bool> switchAccountType(AccountType newType) async {
    state = state.copyWith(isLoading: true);

    try {
      await _businessService.switchAccountType(newType);
      state = state.copyWith(
        isLoading: false,
        accountType: newType,
      );

      // Load business profile if switching to business
      if (newType == AccountType.business) {
        await loadBusinessProfile();
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Create or update business profile
  Future<bool> saveBusinessProfile({
    required String businessName,
    String? registrationNumber,
    required BusinessType businessType,
    String? businessAddress,
    String? taxId,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final profile = await _businessService.saveBusinessProfile(
        businessName: businessName,
        registrationNumber: registrationNumber,
        businessType: businessType,
        businessAddress: businessAddress,
        taxId: taxId,
      );

      state = state.copyWith(
        isLoading: false,
        businessProfile: profile,
        accountType: AccountType.business,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

/// Provider
final businessProvider = NotifierProvider<BusinessNotifier, BusinessState>(
  BusinessNotifier.new,
);
