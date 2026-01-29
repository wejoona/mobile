# Architecture Decisions Log

> Past decisions. Don't re-discuss or re-research.

## State Management: Riverpod
- **Choice:** Riverpod with Notifier (not StateNotifier - deprecated)
- **Why:** Type-safe, testable, no BuildContext needed in providers
- **Pattern:** `NotifierProvider<MyNotifier, MyState>`

## Navigation: GoRouter
- **Choice:** GoRouter with typed routes
- **Why:** Deep linking support, declarative routing, web compatibility
- **Pattern:** `context.push('/route')`, `context.go('/route')`

## HTTP: Dio
- **Choice:** Dio with interceptors
- **Why:** Interceptor chain, request/response transformation
- **Order:** Mock → Dedupe → Cache → Auth → Logging

## Localization: Flutter gen-l10n
- **Choice:** ARB files with code generation
- **Why:** Type-safe, IDE support, pluralization
- **Files:** `app_en.arb`, `app_fr.arb`
- **Usage:** `AppLocalizations.of(context)!.key`

## Storage: flutter_secure_storage
- **Choice:** flutter_secure_storage for sensitive data
- **Why:** Keychain (iOS), EncryptedSharedPreferences (Android)
- **Used for:** PIN, tokens, biometric settings

## PIN Security
- **Hashing:** PBKDF2-HMAC-SHA256, 100,000 iterations
- **Salt:** Random 32 bytes per user
- **Transmission:** Hashed before sending to backend
- **Lockout:** 5 attempts, 15 min lockout

## Biometric
- **Package:** local_auth
- **Fallback:** PIN always available
- **Storage:** Preference stored in secure storage

## Design System
- **Approach:** Custom primitives wrapping Material
- **Components:** AppButton, AppText, AppInput, AppCard, AppSelect
- **Tokens:** AppColors, AppTypography, AppSpacing, AppRadius
- **Why:** Consistent styling, easy theming

## Colors
- **Primary:** Gold (#FFD700 variants)
- **Background:** Obsidian (dark)
- **Cards:** Charcoal
- **Text:** White primary, Silver secondary

## API Structure
- **SDK Pattern:** Single entry point `UsdcWalletSdk`
- **Services:** Mirror backend modules
- **Why:** Centralized API management, easy mocking

## Mocking
- **Approach:** Dio interceptor-based
- **Toggle:** `MockConfig.useMocks`
- **Dev OTP:** `123456`
- **Why:** Mobile-first development, offline testing

## Session Management
- **Timeout:** 5 minutes inactive
- **Lock:** PIN/biometric required to unlock
- **Background:** App locks when backgrounded

## Security Checks
- **Root/Jailbreak:** Detected, configurable policy
- **Debug:** Skipped in debug mode
- **Attestation:** Play Integrity (Android), App Attest (iOS)

## Error Handling
- **API Errors:** Caught in service layer, propagated as state
- **UI Errors:** Shown via toast/dialog
- **Pattern:** Try-catch in notifiers, error state in state class

## Deep Linking
- **Scheme:** `joonapay://`
- **HTTPS:** `https://app.joonapay.com`
- **Handled by:** GoRouter redirect

## Feature Flags
- **Location:** `lib/services/feature_flags/`
- **Pattern:** Provider-based, checked in router redirect

## Testing
- **Unit:** flutter_test
- **Mocking:** Mocktail for dependencies
- **Coverage:** Focus on services and notifiers
