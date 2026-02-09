# Profile Provider with Avatar Support - Implementation Summary

## Overview
Created a complete profile management system with avatar upload/update/delete functionality integrated with the existing auth system.

## Files Created

### 1. Profile Provider
**Path:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/profile/providers/profile_provider.dart`

**Features:**
- Complete profile state management with Riverpod Notifier pattern
- Avatar upload from File (works with image_picker)
- Avatar removal
- Profile updates (firstName, lastName, email)
- Offline avatar URL caching
- Auto-sync with auth provider
- Error handling and loading states

**State Properties:**
```dart
class ProfileState {
  final User? user;
  final String? avatarUrl;
  final bool isLoading;
  final String? error;
  final bool isUploadingAvatar;
}
```

**Methods:**
- `loadProfile()` - Load full profile from backend
- `updateProfile({firstName, lastName, email})` - Update profile info
- `updateAvatar(File)` - Upload new avatar
- `removeAvatar()` - Delete avatar
- `getAvatarUrl()` - Get avatar URL with offline fallback
- `refresh()` - Pull to refresh
- `clearError()` - Clear error state

### 2. Provider Index
**Path:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/profile/providers/index.dart`

Exports the profile provider for clean imports.

### 3. Usage Examples
**Path:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/profile/providers/usage_example.dart`

**Contains:**
- Avatar display widget
- Avatar upload from camera/gallery
- Profile edit form
- Pull to refresh example
- Error handling patterns
- Loading state management

### 4. Documentation
**Path:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/profile/README.md`

Complete documentation including:
- API endpoints specification
- Usage examples
- State properties
- Best practices
- Error handling
- Offline support
- Testing guidance

## Files Updated

### 1. User Entity Model
**Path:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/domain/entities/user.dart`

**Changes:**
- Added `avatarUrl` field (nullable String)
- Updated `fromJson()` to parse avatarUrl
- Updated `toJson()` to serialize avatarUrl
- Added `copyWith()` method for immutable updates

```dart
class User {
  final String? avatarUrl;  // NEW
  // ... other fields

  User copyWith({String? avatarUrl, ...}) // NEW
}
```

### 2. User Service
**Path:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/user/user_service.dart`

**Changes:**
- Added `uploadAvatar(String filePath)` method
- Added `removeAvatar()` method
- Added `getAvatarUrl()` method
- Updated `UserProfile` DTO to include avatarUrl

**New Methods:**
```dart
// Upload avatar (multipart/form-data)
Future<UserProfile> uploadAvatar(String filePath)

// Remove avatar
Future<UserProfile> removeAvatar()

// Get avatar URL
Future<String?> getAvatarUrl()
```

### 3. Storage Keys
**Path:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/api/api_client.dart`

**Changes:**
- Added `avatarUrl = 'avatar_url'` to StorageKeys class for offline caching

```dart
class StorageKeys {
  static const String avatarUrl = 'avatar_url';  // NEW
  // ... existing keys
}
```

### 4. Auth Provider
**Path:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/auth/providers/auth_provider.dart`

**Changes:**
- Added `updateUser(User user)` method for profile sync

```dart
/// Update user data (called from profile updates)
void updateUser(User user) {
  state = state.copyWith(user: user);
}
```

## Integration Points

### Auth Provider Sync
When profile is updated, auth provider is automatically updated:
```dart
ref.read(authProvider.notifier).updateUser(updatedUser);
```

This ensures:
- Auth state always has latest user data
- Avatar is accessible throughout the app
- No need to reload auth after profile changes

### Offline Cache
Avatar URLs are cached in secure storage:
- Cached on successful upload/load
- Used as fallback if backend unreachable
- Cleared on avatar removal

### Error Handling
Consistent error handling pattern:
- ApiException for backend errors
- Generic Exception for unexpected errors
- Error state cleared after handling

## Usage Quick Start

### 1. Import
```dart
import 'package:usdc_wallet/features/profile/providers/profile_provider.dart';
```

### 2. Watch State
```dart
final profileState = ref.watch(profileProvider);
```

### 3. Upload Avatar
```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Pick image
final picker = ImagePicker();
final image = await picker.pickImage(source: ImageSource.gallery);

// Upload
if (image != null) {
  final success = await ref.read(profileProvider.notifier)
    .updateAvatar(File(image.path));
}
```

### 4. Display Avatar
```dart
CircleAvatar(
  backgroundImage: profileState.hasAvatar
    ? NetworkImage(profileState.avatarUrl!)
    : null,
  child: !profileState.hasAvatar ? Icon(Icons.person) : null,
);
```

## Backend Requirements

The following endpoints must be implemented in the backend:

### 1. GET /user/profile
Get user profile with avatar URL.

### 2. PUT /user/profile
Update user profile (firstName, lastName, email).

### 3. POST /user/avatar
Upload avatar image (multipart/form-data with 'avatar' field).

### 4. DELETE /user/avatar
Remove current avatar.

### 5. GET /user/avatar
Get current avatar URL.

See `README.md` for detailed API specifications.

## Testing

Run analysis:
```bash
cd mobile
flutter analyze lib/features/profile/
```

**Results:** No errors, only info-level suggestions (style preferences).

## Dependencies

Required packages (add to pubspec.yaml if not present):
```yaml
dependencies:
  image_picker: ^1.0.0  # For selecting images from camera/gallery
```

Already included:
- flutter_riverpod
- flutter_secure_storage
- dio

## Next Steps

### 1. Add to Existing Screens
Update profile screens to use the new provider:
- `/lib/features/settings/views/profile_view.dart`
- `/lib/features/settings/views/profile_edit_screen.dart`

### 2. Add Image Optimization (Optional)
Consider adding:
- Image compression before upload
- Image cropping UI
- File size validation
- Format validation (JPG, PNG, WebP)

### 3. Add Caching (Recommended)
For better performance, use cached_network_image:
```yaml
dependencies:
  cached_network_image: ^3.3.0
```

```dart
CachedNetworkImage(
  imageUrl: profileState.avatarUrl!,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.person),
)
```

### 4. Add Mock Support
Create mock for testing:
- `/lib/mocks/services/user/user_service_mock.dart`

Add endpoints:
- `POST /user/avatar` - Return success with fake avatar URL
- `DELETE /user/avatar` - Return success
- `GET /user/avatar` - Return fake avatar URL

### 5. Add Localization
Add to `lib/l10n/app_en.arb`:
```json
{
  "profile_uploadAvatar": "Upload Avatar",
  "profile_removeAvatar": "Remove Avatar",
  "profile_avatarUpdated": "Avatar updated successfully",
  "profile_avatarRemoved": "Avatar removed",
  "profile_avatarUploadFailed": "Failed to upload avatar",
  "profile_selectSource": "Select photo source",
  "profile_camera": "Camera",
  "profile_gallery": "Gallery"
}
```

## Notes

- All avatar operations are async and show loading states
- Errors are captured and exposed in state
- Auth provider is kept in sync automatically
- Offline cache provides fallback for poor connectivity
- File uploads use multipart/form-data
- Maximum file size should be enforced (recommend 5MB)
- Supported formats should be validated (JPG, PNG, WebP)

## Support

For questions or issues:
1. Check `README.md` for detailed documentation
2. See `usage_example.dart` for code examples
3. Review backend API specifications
4. Check error messages in profileState.error

---

**Implementation Date:** 2026-01-30
**Status:** Complete and ready for integration
**Testing:** Passed static analysis
