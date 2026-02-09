import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';

/// Mock data for golden tests
/// These provide realistic test data for all screen states
class MockData {
  MockData._();

  /// Sample user for authenticated state
  static final sampleUser = User(
    id: 'user_123',
    phone: '+2250123456789',
    username: 'testuser',
    firstName: 'Test',
    lastName: 'User',
    email: 'test@example.com',
    avatarUrl: null,
    countryCode: 'CI',
    isPhoneVerified: true,
    role: UserRole.user,
    status: UserStatus.active,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime.now(),
  );

  /// User with no KYC
  static final userNoKyc = User(
    id: 'user_456',
    phone: '+2250987654321',
    username: null,
    firstName: null,
    lastName: null,
    email: null,
    avatarUrl: null,
    countryCode: 'CI',
    isPhoneVerified: true,
    role: UserRole.user,
    status: UserStatus.active,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime.now(),
  );

  /// Sample wallet with balance
  static final sampleWallet = Wallet(
    id: 'wallet_123',
    userId: 'user_123',
    circleWalletId: 'circle_wallet_123',
    walletAddress: '0x1234567890abcdef1234567890abcdef12345678',
    blockchain: 'MATIC',
    kycStatus: KycStatus.verified,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime.now(),
  );

  /// Wallet with KYC not verified
  static final walletNoKyc = Wallet(
    id: 'wallet_456',
    userId: 'user_456',
    circleWalletId: null,
    walletAddress: null,
    blockchain: 'MATIC',
    kycStatus: KycStatus.none,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime.now(),
  );

  /// Sample balance
  static const sampleBalance = WalletBalance(
    currency: 'USD',
    available: 1500.00,
    pending: 25.00,
    total: 1525.00,
  );

  /// Empty balance
  static const emptyBalance = WalletBalance(
    currency: 'USD',
    available: 0.0,
    pending: 0.0,
    total: 0.0,
  );

  /// Sample transactions
  static final sampleTransactions = [
    Transaction(
      id: 'tx_001',
      walletId: 'wallet_123',
      type: TransactionType.deposit,
      status: TransactionStatus.completed,
      amount: 100.00,
      currency: 'USD',
      fee: 2.50,
      description: 'Mobile Money Deposit',
      externalReference: 'MM-2024-001',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Transaction(
      id: 'tx_002',
      walletId: 'wallet_123',
      type: TransactionType.transferInternal,
      status: TransactionStatus.completed,
      amount: 50.00,
      currency: 'USD',
      fee: 0.50,
      description: 'Sent to Alice',
      recipientPhone: '+2250712345678',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: 'tx_003',
      walletId: 'wallet_123',
      type: TransactionType.transferInternal,
      status: TransactionStatus.pending,
      amount: 200.00,
      currency: 'USD',
      fee: 2.00,
      description: 'Transfer from Bob',
      createdAt: DateTime.now().subtract(const Duration(hours: 30)),
    ),
    Transaction(
      id: 'tx_004',
      walletId: 'wallet_123',
      type: TransactionType.withdrawal,
      status: TransactionStatus.failed,
      amount: 75.00,
      currency: 'USD',
      fee: 1.50,
      description: 'Withdrawal to bank',
      failureReason: 'Insufficient balance',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: 'tx_005',
      walletId: 'wallet_123',
      type: TransactionType.transferExternal,
      status: TransactionStatus.processing,
      amount: 500.00,
      currency: 'USD',
      fee: 5.00,
      description: 'USDC transfer to external wallet',
      recipientAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  /// Sample deposit channels
  static final sampleDepositChannels = [
    const DepositChannel(
      id: 'channel_mtn',
      name: 'MTN Mobile Money',
      type: 'mobile_money',
      provider: 'MTN',
      country: 'CI',
      minAmount: 1.00,
      maxAmount: 5000.00,
      fee: 2.5,
      feeType: 'percentage',
      currency: 'XOF',
    ),
    const DepositChannel(
      id: 'channel_orange',
      name: 'Orange Money',
      type: 'mobile_money',
      provider: 'Orange',
      country: 'CI',
      minAmount: 1.00,
      maxAmount: 5000.00,
      fee: 2.0,
      feeType: 'percentage',
      currency: 'XOF',
    ),
    const DepositChannel(
      id: 'channel_wave',
      name: 'Wave',
      type: 'mobile_money',
      provider: 'Wave',
      country: 'CI',
      minAmount: 1.00,
      maxAmount: 10000.00,
      fee: 1.5,
      feeType: 'percentage',
      currency: 'XOF',
    ),
  ];

  /// Sample contact/beneficiaries
  static final sampleContacts = [
    Contact(
      id: 'contact_001',
      name: 'Alice Johnson',
      phone: '+2250712345678',
      username: 'alice',
      isFavorite: true,
      transactionCount: 5,
      lastTransactionAt: DateTime.now().subtract(const Duration(days: 2)),
      isJoonaPayUser: true,
    ),
    Contact(
      id: 'contact_002',
      name: 'Bob Smith',
      phone: '+2250798765432',
      username: 'bobsmith',
      isFavorite: false,
      transactionCount: 12,
      lastTransactionAt: DateTime.now().subtract(const Duration(hours: 5)),
      isJoonaPayUser: true,
    ),
    Contact(
      id: 'contact_003',
      name: 'Charlie Brown',
      phone: '+2250755555555',
      username: null,
      isFavorite: false,
      transactionCount: 0,
      isJoonaPayUser: false,
    ),
    Contact(
      id: 'contact_004',
      name: 'Diana Prince',
      walletAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
      username: 'diana',
      isFavorite: true,
      transactionCount: 3,
      lastTransactionAt: DateTime.now().subtract(const Duration(days: 7)),
      isJoonaPayUser: true,
    ),
  ];

  /// Sample notifications
  static final sampleNotifications = [
    AppNotification(
      id: 'notif_001',
      userId: 'user_123',
      type: NotificationType.transactionComplete,
      title: 'Payment Received',
      body: 'You received \$100 from Alice',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      data: {'transactionId': 'tx_001'},
    ),
    AppNotification(
      id: 'notif_002',
      userId: 'user_123',
      type: NotificationType.securityAlert,
      title: 'New Device Login',
      body: 'Your account was accessed from a new device',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      data: {'deviceId': 'device_123'},
    ),
    AppNotification(
      id: 'notif_003',
      userId: 'user_123',
      type: NotificationType.promotion,
      title: 'Limited Time Offer',
      body: 'Get 50% off transfer fees this weekend!',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      data: {},
    ),
  ];

  /// Sample exchange rate
  static final sampleExchangeRate = ExchangeRate(
    sourceCurrency: 'XOF',
    targetCurrency: 'USD',
    rate: 0.0016,
    sourceAmount: 10000.0,
    targetAmount: 16.0,
    fee: 0.25,
    expiresAt: DateTime.now().add(const Duration(minutes: 5)),
  );
}

/// Screen test state configuration
enum TestScreenState {
  initial,
  loading,
  loaded,
  empty,
  error,
  refreshing,
  authenticated,
  unauthenticated,
  kycRequired,
  kycPending,
  kycVerified,
  featureFlagged,
}

extension TestScreenStateExtension on TestScreenState {
  String get displayName {
    switch (this) {
      case TestScreenState.initial:
        return 'initial';
      case TestScreenState.loading:
        return 'loading';
      case TestScreenState.loaded:
        return 'loaded';
      case TestScreenState.empty:
        return 'empty';
      case TestScreenState.error:
        return 'error';
      case TestScreenState.refreshing:
        return 'refreshing';
      case TestScreenState.authenticated:
        return 'authenticated';
      case TestScreenState.unauthenticated:
        return 'unauthenticated';
      case TestScreenState.kycRequired:
        return 'kyc_required';
      case TestScreenState.kycPending:
        return 'kyc_pending';
      case TestScreenState.kycVerified:
        return 'kyc_verified';
      case TestScreenState.featureFlagged:
        return 'feature_flagged';
    }
  }
}
