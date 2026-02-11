/// Beneficiaries Mock Implementation
///
/// Mock handlers for beneficiary endpoints.
library;

import 'package:usdc_wallet/features/beneficiaries/models/beneficiary.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';

/// Beneficiaries Mock State
class BeneficiariesMockState {
  static final List<Beneficiary> _beneficiaries = [
    Beneficiary(
      id: 'ben-1',
      walletId: 'wallet-1',
      name: 'Amadou Diallo',
      phoneE164: '+225 07 12 34 56',
      accountType: AccountType.joonapayUser,
      beneficiaryUserId: 'user-amadou',
      isFavorite: true,
      isVerified: true,
      transferCount: 15,
      totalTransferred: 450000,
      lastTransferAt: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Beneficiary(
      id: 'ben-2',
      walletId: 'wallet-1',
      name: 'Fatou Touré',
      phoneE164: '+225 05 87 65 43',
      accountType: AccountType.joonapayUser,
      beneficiaryUserId: 'user-fatou',
      isFavorite: true,
      isVerified: true,
      transferCount: 8,
      totalTransferred: 125000,
      lastTransferAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Beneficiary(
      id: 'ben-3',
      walletId: 'wallet-1',
      name: 'Kouassi N\'Guessan',
      phoneE164: '+225 01 23 45 67',
      accountType: AccountType.mobileMoney,
      mobileMoneyProvider: 'Orange Money',
      isFavorite: false,
      isVerified: true,
      transferCount: 3,
      totalTransferred: 75000,
      lastTransferAt: DateTime.now().subtract(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Beneficiary(
      id: 'ben-4',
      walletId: 'wallet-1',
      name: 'Crypto Wallet',
      accountType: AccountType.externalWallet,
      beneficiaryWalletAddress: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
      isFavorite: false,
      isVerified: true,
      transferCount: 2,
      totalTransferred: 1500000,
      lastTransferAt: DateTime.now().subtract(const Duration(days: 14)),
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Beneficiary(
      id: 'ben-5',
      walletId: 'wallet-1',
      name: 'Awa Traoré',
      phoneE164: '+225 07 99 88 77',
      accountType: AccountType.joonapayUser,
      beneficiaryUserId: 'user-awa',
      isFavorite: false,
      isVerified: false,
      transferCount: 1,
      totalTransferred: 25000,
      lastTransferAt: DateTime.now().subtract(const Duration(days: 20)),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Beneficiary(
      id: 'ben-6',
      walletId: 'wallet-1',
      name: 'Banque Atlantique',
      phoneE164: '+225 05 44 33 22',
      accountType: AccountType.bankAccount,
      bankCode: 'ATLA',
      bankAccountNumber: 'CI123456789012345',
      isFavorite: false,
      isVerified: true,
      transferCount: 0,
      totalTransferred: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  static List<Beneficiary> get beneficiaries => List.unmodifiable(_beneficiaries);

  static void reset() {
    // Reset to default state if needed
  }

  static Beneficiary? findById(String id) {
    try {
      return _beneficiaries.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  static void addBeneficiary(Beneficiary beneficiary) {
    _beneficiaries.add(beneficiary);
  }

  static void updateBeneficiary(String id, Beneficiary updated) {
    final index = _beneficiaries.indexWhere((b) => b.id == id);
    if (index != -1) {
      _beneficiaries[index] = updated;
    }
  }

  static void removeBeneficiary(String id) {
    _beneficiaries.removeWhere((b) => b.id == id);
  }

  static void toggleFavorite(String id) {
    final index = _beneficiaries.indexWhere((b) => b.id == id);
    if (index != -1) {
      _beneficiaries[index] = _beneficiaries[index].copyWith(
        isFavorite: !_beneficiaries[index].isFavorite,
        updatedAt: DateTime.now(),
      );
    }
  }

  static List<Beneficiary> filterBeneficiaries({
    bool? favorites,
    bool? recent,
    String? type,
  }) {
    var filtered = beneficiaries;

    if (favorites == true) {
      filtered = filtered.where((b) => b.isFavorite).toList();
    }

    if (recent == true) {
      filtered = filtered.where((b) => b.lastTransferAt != null).toList();
      filtered.sort((a, b) => b.lastTransferAt!.compareTo(a.lastTransferAt!));
    }

    if (type != null) {
      filtered = filtered.where((b) => b.accountType.value == type).toList();
    }

    return filtered;
  }
}

/// Beneficiaries Mock Service
class BeneficiariesMock {
  static void register(MockInterceptor interceptor) {
    // GET /api/v1/beneficiaries - Get all beneficiaries
    interceptor.register(
      method: 'GET',
      path: '/api/v1/beneficiaries',
      handler: _handleGetBeneficiaries,
    );

    // GET /api/v1/beneficiaries/:id - Get single beneficiary
    interceptor.register(
      method: 'GET',
      path: '/api/v1/beneficiaries/:id',
      handler: _handleGetBeneficiary,
    );

    // POST /api/v1/beneficiaries - Create beneficiary
    interceptor.register(
      method: 'POST',
      path: '/api/v1/beneficiaries',
      handler: _handleCreateBeneficiary,
    );

    // PUT /api/v1/beneficiaries/:id - Update beneficiary
    interceptor.register(
      method: 'PUT',
      path: '/api/v1/beneficiaries/:id',
      handler: _handleUpdateBeneficiary,
    );

    // DELETE /api/v1/beneficiaries/:id - Delete beneficiary
    interceptor.register(
      method: 'DELETE',
      path: '/api/v1/beneficiaries/:id',
      handler: _handleDeleteBeneficiary,
    );

    // POST /api/v1/beneficiaries/:id/favorite - Toggle favorite
    interceptor.register(
      method: 'POST',
      path: '/api/v1/beneficiaries/:id/favorite',
      handler: _handleToggleFavorite,
    );
  }

  /// Handle GET /api/v1/beneficiaries
  static Future<MockResponse> _handleGetBeneficiaries(options) async {
    final favorites = options.queryParameters['favorites'] == 'true';
    final recent = options.queryParameters['recent'] == 'true';
    final type = options.queryParameters['type'] as String?;

    final filtered = BeneficiariesMockState.filterBeneficiaries(
      favorites: favorites,
      recent: recent,
      type: type,
    );

    return MockResponse.success({
      'beneficiaries': filtered.map((b) => b.toJson()).toList(),
    });
  }

  /// Handle GET /api/v1/beneficiaries/:id
  static Future<MockResponse> _handleGetBeneficiary(options) async {
    final params = options.extractPathParams('/api/v1/beneficiaries/:id');
    final id = params['id'];

    final beneficiary = BeneficiariesMockState.findById(id);

    if (beneficiary == null) {
      return MockResponse(
        statusCode: 404,
        data: {'message': 'Beneficiary not found'},
      );
    }

    return MockResponse.success(beneficiary.toJson());
  }

  /// Handle POST /api/v1/beneficiaries
  static Future<MockResponse> _handleCreateBeneficiary(options) async {
    final data = options.data as Map<String, dynamic>;

    final newBeneficiary = Beneficiary(
      id: 'ben-${DateTime.now().millisecondsSinceEpoch}',
      walletId: 'wallet-1',
      name: data['name'] as String,
      phoneE164: data['phone_e164'] as String?,
      accountType: AccountType.fromString(data['account_type'] as String),
      beneficiaryWalletAddress: data['beneficiary_wallet_address'] as String?,
      bankCode: data['bank_code'] as String?,
      bankAccountNumber: data['bank_account_number'] as String?,
      mobileMoneyProvider: data['mobile_money_provider'] as String?,
      isFavorite: false,
      isVerified: false,
      transferCount: 0,
      totalTransferred: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    BeneficiariesMockState.addBeneficiary(newBeneficiary);

    return MockResponse.created(newBeneficiary.toJson());
  }

  /// Handle PUT /api/v1/beneficiaries/:id
  static Future<MockResponse> _handleUpdateBeneficiary(options) async {
    final params = options.extractPathParams('/api/v1/beneficiaries/:id');
    final id = params['id'];

    final beneficiary = BeneficiariesMockState.findById(id);

    if (beneficiary == null) {
      return MockResponse(
        statusCode: 404,
        data: {'message': 'Beneficiary not found'},
      );
    }

    final data = options.data as Map<String, dynamic>;
    final updated = beneficiary.copyWith(
      name: data['name'] as String? ?? beneficiary.name,
      phoneE164: data['phone_e164'] as String?,
      updatedAt: DateTime.now(),
    );

    BeneficiariesMockState.updateBeneficiary(id, updated);

    return MockResponse.success(updated.toJson());
  }

  /// Handle DELETE /api/v1/beneficiaries/:id
  static Future<MockResponse> _handleDeleteBeneficiary(options) async {
    final params = options.extractPathParams('/api/v1/beneficiaries/:id');
    final id = params['id'];

    final beneficiary = BeneficiariesMockState.findById(id);

    if (beneficiary == null) {
      return MockResponse(
        statusCode: 404,
        data: {'message': 'Beneficiary not found'},
      );
    }

    BeneficiariesMockState.removeBeneficiary(id);

    return MockResponse.success({
      'success': true,
      'message': 'Beneficiary deleted successfully',
    });
  }

  /// Handle POST /api/v1/beneficiaries/:id/favorite
  static Future<MockResponse> _handleToggleFavorite(options) async {
    final params = options.extractPathParams('/api/v1/beneficiaries/:id/favorite');
    final id = params['id'];

    final beneficiary = BeneficiariesMockState.findById(id);

    if (beneficiary == null) {
      return MockResponse(
        statusCode: 404,
        data: {'message': 'Beneficiary not found'},
      );
    }

    BeneficiariesMockState.toggleFavorite(id);
    final updated = BeneficiariesMockState.findById(id)!;

    return MockResponse.success(updated.toJson());
  }
}
