# File Index - Line Numbers for Quick Access

> Use `Read` with `offset` and `limit` to read only what you need.

## lib/features/auth/views/login_view.dart (285 lines)
- 1-30: Imports, class declaration
- 31-80: build() method
- 81-120: _buildHeader()
- 121-180: _buildForm()
- 181-230: _buildPhoneInput()
- 231-285: _handleSubmit(), _handleBiometric()

## lib/features/wallet/views/home_view.dart (420 lines)
- 1-40: Imports, class
- 41-100: build()
- 101-180: _buildBalanceCard()
- 181-260: _buildQuickActions()
- 261-350: _buildTransactionList()
- 351-420: _buildTransactionItem()

## lib/services/api/api_client.dart (180 lines)
- 1-20: Imports
- 21-50: Provider definitions
- 51-100: Dio setup, interceptors
- 101-140: Auth interceptor
- 141-180: Error handling

## lib/services/sdk/usdc_wallet_sdk.dart (250 lines)
- 1-30: Imports, class
- 31-60: Service getters (auth, wallet, transfers)
- 61-120: AuthService methods
- 121-180: WalletService methods
- 181-250: TransferService methods

## lib/services/pin/pin_service.dart (398 lines)
- 1-30: Imports, constants
- 31-70: hasPin(), setPin()
- 71-130: verifyPinLocally()
- 131-200: verifyPinWithBackend()
- 201-290: _hashPin(), _pbkdf2()
- 291-370: _isWeakPin()
- 371-398: PinVerificationResult class

## lib/services/biometric/biometric_service.dart (220 lines)
- 1-20: Imports, BiometricType enum
- 21-80: BiometricService class, authenticate()
- 81-120: isBiometricEnabled(), enable/disable
- 121-170: BiometricGuard class
- 171-220: Providers

## lib/router/app_router.dart (350 lines)
- 1-30: Imports
- 31-50: Router provider
- 51-100: Auth routes (/login, /otp, /register)
- 101-150: Wallet routes (/home, /transactions)
- 151-200: Transfer routes (/send, /receive)
- 201-250: Settings routes
- 251-300: Onboarding routes
- 301-350: Redirect logic

## lib/design/tokens/colors.dart (80 lines)
- 1-20: Primary colors (gold variants)
- 21-40: Neutral colors (obsidian, charcoal, silver)
- 41-60: Semantic colors (success, error, warning)
- 61-80: Gradient definitions

## lib/design/components/primitives/app_button.dart (150 lines)
- 1-20: Imports, enums (ButtonVariant, ButtonSize)
- 21-60: AppButton class, constructor
- 61-100: build() method
- 101-150: _getColors(), _getSize()

## lib/mocks/mock_config.dart (40 lines)
- 1-15: MockConfig class
- 16-30: useMocks toggle, devOtp
- 31-40: Environment checks

## lib/l10n/app_en.arb (1053 lines)
- 1-50: Common strings (buttons, labels)
- 51-150: Auth strings
- 151-300: Wallet strings
- 301-450: Transfer strings
- 451-600: Settings strings
- 601-750: Error messages
- 751-900: Validation messages
- 901-1053: Miscellaneous

## Common Read Patterns

### Just need imports?
```
Read file_path offset=1 limit=30
```

### Just need a specific method?
```
Read file_path offset=METHOD_START limit=50
```

### Just need class definition?
```
Read file_path offset=CLASS_LINE limit=20
```
