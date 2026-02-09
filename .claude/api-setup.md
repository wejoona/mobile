# API Client Setup - Quick Reference

## Status: ✅ Properly Configured

The mobile API client is correctly set up to connect to the backend.

## Quick Start

### Run with Real Backend
```bash
# 1. Ensure backend is running
cd /Users/macbook/JoonaPay/USDC-Wallet/usdc-wallet
npm run start:dev

# 2. Disable mocks in mobile/lib/mocks/mock_config.dart
MockConfig.useMocks = false;

# 3. Run mobile app with dev config
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter run --dart-define-from-file=env.dev.json
```

### Run with Mocks (No Backend)
```bash
# Set in mobile/lib/mocks/mock_config.dart
MockConfig.useMocks = true;

# Run normally
flutter run
```

## Configuration Files

| File | Purpose |
|------|---------|
| `lib/services/api/api_client.dart` | Main API configuration |
| `lib/mocks/mock_config.dart` | Mock mode toggle |
| `env.dev.json` | Development environment |
| `env.prod.json.example` | Production template |

## How It Works

### 1. Base URL Configuration
- **Default Dev:** `http://192.168.1.115:3000/api/v1`
- **Default Prod:** `https://api.joonapay.com/api/v1`
- **Configurable via:** `--dart-define=API_URL=...`

### 2. Path Handling
Services use relative paths:
```dart
await _dio.post('/auth/register', data: {...});
// Calls: http://192.168.1.115:3000/api/v1/auth/register
```

Base URL already includes `/api/v1` prefix - do NOT add it to service calls.

### 3. Mock Interceptor
When `MockConfig.useMocks = false`:
- Mock interceptor **automatically bypasses** requests
- All calls go to real backend
- Auth tokens required
- Certificate pinning enabled (production only)

### 4. Auth Token Injection
- Automatically adds `Authorization: Bearer <token>` header
- Skips for public endpoints: `/auth/register`, `/auth/login`, etc.
- Auto-refreshes token on 401 errors

### 5. Error Handling
- Converts `DioException` to `ApiException` with friendly messages
- Handles timeouts, network errors, 4xx/5xx responses

## Verification

Check console logs on app startup:
```
[API] API URL: http://192.168.1.115:3000/api/v1
[API] Environment: Development
[API] Mock Mode: Disabled
```

## Updated Files

1. ✅ `/mobile/lib/services/api/api_client.dart`
   - Added environment-based configuration
   - Added logging for API URL and mode
   - Fixed certificate pinning (production only)

2. ✅ `/mobile/lib/services/session/session_service.dart`
   - Replaced hardcoded URL with `ApiConfig.baseUrl`

3. ✅ `/mobile/env.dev.json` (created)
   - Development environment config

4. ✅ `/mobile/env.prod.json.example` (created)
   - Production environment template

## Troubleshooting

### Cannot Connect
1. Check backend is running: `cd usdc-wallet && npm run start:dev`
2. Verify IP address in `env.dev.json` matches your machine
3. iOS simulator: Use IP, not `localhost`
4. Android emulator: Use `10.0.2.2` for host machine

### Mock Mode Issues
- Check `MockConfig.useMocks` in `lib/mocks/mock_config.dart`
- Set to `false` to connect to real backend
- Set to `true` for offline development

### 401 Errors
- Tokens may be expired or invalid
- Try logging in again
- Check auth interceptor is working

## Next Steps

To use the real backend:
1. Start backend: `cd usdc-wallet && npm run start:dev`
2. Set `MockConfig.useMocks = false`
3. Run: `flutter run --dart-define-from-file=env.dev.json`
4. Test login/registration flows
