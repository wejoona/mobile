# Mobile API Configuration Guide

## Overview

The mobile app API client is configured to connect to the backend NestJS server. It supports multiple environments and can be configured via compile-time flags.

## Configuration Files

### Location: `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/api/api_client.dart`

## Base URL Configuration

The API client uses a configurable base URL with the following priority:

1. **Explicit `--dart-define` flag** (highest priority)
2. **Environment-based defaults** (development/staging/production)
3. **Debug mode fallback**

### Current Defaults

| Environment | Base URL |
|-------------|----------|
| Development | `http://192.168.1.115:3000/api/v1` |
| Staging | `https://staging-api.joonapay.com/api/v1` |
| Production | `https://api.joonapay.com/api/v1` |

**Note:** iOS simulator cannot connect to `localhost` - use your machine's IP address.

## Usage

### Method 1: Environment Config Files (Recommended)

#### Development (Already Created)
```bash
flutter run --dart-define-from-file=env.dev.json
```

Content of `env.dev.json`:
```json
{
  "ENV": "development",
  "API_URL": "http://192.168.1.115:3000/api/v1"
}
```

#### Production
```bash
flutter build apk --release --dart-define-from-file=env.prod.json
```

Create `env.prod.json` (do NOT commit):
```json
{
  "ENV": "production",
  "API_URL": "https://api.joonapay.com/api/v1",
  "CERT_PIN_1": "your_certificate_fingerprint_1",
  "CERT_PIN_2": "your_certificate_fingerprint_2"
}
```

### Method 2: Command-Line Flags

```bash
# Development
flutter run --dart-define=API_URL=http://192.168.1.115:3000/api/v1

# Production
flutter run --dart-define=ENV=production --dart-define=API_URL=https://api.joonapay.com/api/v1
```

### Method 3: VS Code Launch Configuration

Add to `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Dev",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define-from-file=env.dev.json"
      ]
    },
    {
      "name": "Flutter Prod",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define-from-file=env.prod.json"
      ]
    }
  ]
}
```

## Mock Mode

The app can run in mock mode for development without a backend connection.

### Enable Mocks
In `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/mocks/mock_config.dart`:
```dart
static bool useMocks = true;
```

### Disable Mocks (Use Real Backend)
```dart
static bool useMocks = false;
```

When mocks are disabled:
- All API calls go to the configured base URL
- The mock interceptor automatically bypasses requests
- Certificate pinning is enabled in production
- Auth tokens are required

**Development OTP:** When mocks are enabled, use `123456` as the OTP code.

## API Client Features

### 1. Base URL Configuration
- ✅ Configurable via `--dart-define`
- ✅ Environment-aware defaults
- ✅ Proper `/api/v1` prefix handling

### 2. Authentication
- ✅ JWT bearer token auto-injection
- ✅ Token refresh on 401 errors
- ✅ Secure token storage (Flutter Secure Storage)
- ✅ Race condition protection on token refresh

### 3. Error Handling
- ✅ Comprehensive DioException handling
- ✅ User-friendly error messages
- ✅ Proper timeout handling
- ✅ Network connectivity errors

### 4. Performance
- ✅ Request deduplication (prevents duplicate in-flight requests)
- ✅ HTTP response caching
- ✅ Configurable timeouts (30s connect/receive)

### 5. Security
- ✅ Certificate pinning (production only)
- ✅ HTTPS enforcement in production
- ✅ Secure token storage
- ✅ No sensitive data in logs (production)

### 6. Mock Support
- ✅ Mock interceptor for offline development
- ✅ Automatic bypass when mocks disabled
- ✅ Contract-based API mocking

## Verification

Run the app and check logs for:

```
[API] API URL: http://192.168.1.115:3000/api/v1
[API] Environment: Development
[API] Mock Mode: Disabled
```

## Troubleshooting

### Issue: Cannot connect to backend

1. **Check backend is running:**
   ```bash
   cd /Users/macbook/JoonaPay/USDC-Wallet/usdc-wallet
   npm run start:dev
   ```

2. **Verify base URL:**
   - iOS simulator: Cannot use `localhost`, use IP address (e.g., `192.168.1.115`)
   - Android emulator: Can use `10.0.2.2` for host machine
   - Physical device: Use machine's network IP address

3. **Check mock mode:**
   - If `MockConfig.useMocks = true`, API calls won't reach backend
   - Set to `false` to test real API

4. **Check logs:**
   - Look for "API URL" in console output
   - Check for network errors

### Issue: 401 Unauthorized

- Ensure tokens are valid
- Check auth interceptor is adding Bearer token
- Verify backend auth endpoints match

### Issue: Timeout errors

- Increase timeout in `ApiConfig`:
  ```dart
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  ```

## API Path Structure

All service calls use relative paths (without `/api/v1` prefix):

```dart
// ✅ Correct
await _dio.post('/auth/register', data: {...});

// ❌ Wrong - would result in /api/v1/api/v1/auth/register
await _dio.post('/api/v1/auth/register', data: {...});
```

The base URL (`http://192.168.1.115:3000/api/v1`) + path (`/auth/register`) = full URL.

## Backend API Endpoints

All endpoints expect `/api/v1` prefix:

| Endpoint | Full URL |
|----------|----------|
| Register | `POST /api/v1/auth/register` |
| Login | `POST /api/v1/auth/login` |
| Verify OTP | `POST /api/v1/auth/verify-otp` |
| Get Balance | `GET /api/v1/wallet/balance` |
| Get Transactions | `GET /api/v1/transactions` |

## Files Modified

1. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/api/api_client.dart`
   - Added environment-based configuration
   - Added `--dart-define` support
   - Added logging for API URL and mock status
   - Fixed certificate pinning to only run in production

2. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/session/session_service.dart`
   - Fixed hardcoded API URL to use `ApiConfig.baseUrl`
   - Added import for `ApiConfig`

3. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/env.dev.json`
   - Created development environment configuration

4. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/env.prod.json.example`
   - Created production environment template

## Security Notes

- **Never commit** `env.prod.json` with real credentials
- **Always use HTTPS** in production
- **Enable certificate pinning** in production builds
- **Disable logging** in release builds (already handled)
- **Store tokens securely** (already using FlutterSecureStorage)
