/// Realistic test data for West African context
class TestData {
  // Test users (Côte d'Ivoire, Senegal, Mali)
  static const testUsers = [
    {
      'firstName': 'Amadou',
      'lastName': 'Diallo',
      'phone': '0700000000',
      'countryCode': '+225',
      'country': 'Côte d\'Ivoire',
    },
    {
      'firstName': 'Fatou',
      'lastName': 'Traore',
      'phone': '+221 77 123 45 67',
      'countryCode': '+221',
      'country': 'Senegal',
    },
    {
      'firstName': 'Ibrahim',
      'lastName': 'Keita',
      'phone': '+223 70 12 34 56',
      'countryCode': '+223',
      'country': 'Mali',
    },
  ];

  static Map<String, dynamic> get defaultUser => testUsers[0];

  // Mobile money providers
  static const mobileMoneyProviders = [
    'Orange Money',
    'MTN Mobile Money',
    'Wave',
    'Moov Money',
  ];

  // Test credentials
  static const String testPin = '123456';
  static const String testOtp = '123456';
  static const String newPin = '654321';

  // Test amounts (XOF - West African CFA Franc)
  static const double smallAmount = 1000.0; // ~$1.60
  static const double mediumAmount = 10000.0; // ~$16
  static const double largeAmount = 100000.0; // ~$160
  static const double veryLargeAmount = 1000000.0; // ~$1600

  // Currency
  static const String currency = 'XOF';
  static const String currencySymbol = 'FCFA';

  // USDC wallet addresses (test)
  static const testWalletAddresses = [
    '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1',
    '0x1234567890AbcdEF1234567890aBcdef12345678',
    '0xaBcDeF1234567890ABcdEf1234567890abCDEf12',
  ];

  // Beneficiaries
  static const testBeneficiaries = [
    {
      'name': 'Mariam Cisse',
      'phone': '+225 07 11 22 33 44',
      'isFavorite': true,
    },
    {
      'name': 'Ousmane Bamba',
      'phone': '+225 07 55 66 77 88',
      'isFavorite': false,
    },
    {
      'name': 'Aissata Kone',
      'phone': '+221 77 99 88 77 66',
      'isFavorite': true,
    },
  ];

  // Bill payment providers
  static const billProviders = [
    {
      'name': 'CIE (Electricity)',
      'category': 'Utilities',
      'icon': 'electricity',
    },
    {
      'name': 'SODECI (Water)',
      'category': 'Utilities',
      'icon': 'water',
    },
    {
      'name': 'Orange Telecom',
      'category': 'Telecom',
      'icon': 'phone',
    },
    {
      'name': 'Canal+ Abonnement',
      'category': 'TV',
      'icon': 'tv',
    },
  ];

  // KYC document types
  static const kycDocumentTypes = [
    'National ID Card',
    'Passport',
    'Driver\'s License',
    'Residence Permit',
  ];

  // Transaction types
  static const transactionTypes = [
    'send',
    'receive',
    'deposit',
    'withdraw',
    'bill_payment',
    'airtime',
  ];

  // Transaction statuses
  static const transactionStatuses = [
    'pending',
    'completed',
    'failed',
    'cancelled',
  ];

  // Sample transactions
  static List<Map<String, dynamic>> getSampleTransactions() {
    return [
      {
        'id': 'tx_001',
        'type': 'receive',
        'amount': 25000,
        'currency': currency,
        'from': 'Fatou Traore',
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'status': 'completed',
      },
      {
        'id': 'tx_002',
        'type': 'send',
        'amount': -5000,
        'currency': currency,
        'to': 'Amadou Diallo',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'status': 'completed',
      },
      {
        'id': 'tx_003',
        'type': 'deposit',
        'amount': 50000,
        'currency': currency,
        'provider': 'Orange Money',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'status': 'completed',
      },
      {
        'id': 'tx_004',
        'type': 'bill_payment',
        'amount': -8500,
        'currency': currency,
        'provider': 'CIE',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'status': 'completed',
      },
      {
        'id': 'tx_005',
        'type': 'send',
        'amount': -15000,
        'currency': currency,
        'to': 'Ibrahim Keita',
        'date': DateTime.now().subtract(const Duration(days: 14)),
        'status': 'completed',
      },
    ];
  }

  // Countries supported
  static const countries = [
    {
      'name': 'Côte d\'Ivoire',
      'code': 'CI',
      'dialCode': '+225',
      'flag': '🇨🇮',
    },
    {
      'name': 'Senegal',
      'code': 'SN',
      'dialCode': '+221',
      'flag': '🇸🇳',
    },
    {
      'name': 'Mali',
      'code': 'ML',
      'dialCode': '+223',
      'flag': '🇲🇱',
    },
    {
      'name': 'Burkina Faso',
      'code': 'BF',
      'dialCode': '+226',
      'flag': '🇧🇫',
    },
    {
      'name': 'Niger',
      'code': 'NE',
      'dialCode': '+227',
      'flag': '🇳🇪',
    },
    {
      'name': 'Togo',
      'code': 'TG',
      'dialCode': '+228',
      'flag': '🇹🇬',
    },
    {
      'name': 'Benin',
      'code': 'BJ',
      'dialCode': '+229',
      'flag': '🇧🇯',
    },
  ];

  // Languages
  static const languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
  ];

  // Notification preferences
  static const notificationTypes = [
    'transaction',
    'security',
    'marketing',
    'account',
  ];

  // Security settings
  static const securityOptions = [
    'biometric',
    'pin',
    'two_factor',
    'device_authorization',
  ];

  // App settings
  static const themes = ['light', 'dark', 'system'];

  // Limits by KYC tier
  static const limits = {
    'tier1': {
      'daily': 100000.0,
      'monthly': 500000.0,
      'perTransaction': 50000.0,
    },
    'tier2': {
      'daily': 500000.0,
      'monthly': 2000000.0,
      'perTransaction': 200000.0,
    },
    'tier3': {
      'daily': 2000000.0,
      'monthly': 10000000.0,
      'perTransaction': 1000000.0,
    },
  };

  // Error messages
  static const errorMessages = {
    'insufficientFunds': 'Insufficient balance',
    'invalidPin': 'Invalid PIN',
    'invalidOtp': 'Invalid OTP code',
    'networkError': 'Network error. Please try again.',
    'sessionExpired': 'Session expired. Please login again.',
    'limitExceeded': 'Transaction limit exceeded',
  };

  // Success messages
  static const successMessages = {
    'transferSuccess': 'Transfer completed successfully',
    'depositSuccess': 'Deposit initiated successfully',
    'withdrawSuccess': 'Withdrawal initiated successfully',
    'pinChanged': 'PIN changed successfully',
    'profileUpdated': 'Profile updated successfully',
    'beneficiaryAdded': 'Beneficiary added successfully',
  };
}
