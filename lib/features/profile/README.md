# Profile Feature - Avatar Support

User profile management with avatar upload/update/delete functionality.

## Files Created/Updated

### 1. User Model (Updated)
**Location:** `/lib/domain/entities/user.dart`

Added `avatarUrl` field to User entity:
```dart
class User {
  final String? avatarUrl;
  // ... other fields
}
```

### 2. User Service (Updated)
**Location:** `/lib/services/user/user_service.dart`

Added avatar management methods:
- `uploadAvatar(String filePath)` - Upload new avatar
- `removeAvatar()` - Delete current avatar
- `getAvatarUrl()` - Get avatar URL

### 3. Profile Provider (New)
**Location:** `/lib/features/profile/providers/profile_provider.dart`

Complete profile state management with avatar support.

### 4. Storage Keys (Updated)
**Location:** `/lib/services/api/api_client.dart`

Added `avatarUrl` key for offline caching.

### 5. Auth Provider (Updated)
**Location:** `/lib/features/auth/providers/auth_provider.dart`

Added `updateUser()` method for profile sync.

## Usage

### Import
```dart
import 'package:your_app/features/profile/providers/profile_provider.dart';
```

### Watch Profile State
```dart
final profileState = ref.watch(profileProvider);
```

### Load Profile
```dart
// On screen init
ref.read(profileProvider.notifier).loadProfile();

// Pull to refresh
ref.read(profileProvider.notifier).refresh();
```

### Update Profile
```dart
final success = await ref.read(profileProvider.notifier).updateProfile(
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
);
```

### Avatar Management

#### Upload Avatar
```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Pick image
final picker = ImagePicker();
final XFile? image = await picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 800,
  maxHeight: 800,
  imageQuality: 85,
);

// Upload
if (image != null) {
  final file = File(image.path);
  final success = await ref.read(profileProvider.notifier).updateAvatar(file);
}
```

#### Display Avatar
```dart
final profileState = ref.watch(profileProvider);

CircleAvatar(
  radius: 40,
  backgroundImage: profileState.hasAvatar
      ? NetworkImage(profileState.avatarUrl!)
      : null,
  child: !profileState.hasAvatar
      ? const Icon(Icons.person, size: 40)
      : null,
);
```

#### Remove Avatar
```dart
final success = await ref.read(profileProvider.notifier).removeAvatar();
```

## State Properties

```dart
class ProfileState {
  final User? user;              // Current user data
  final String? avatarUrl;       // Avatar URL (cached)
  final bool isLoading;          // Profile loading state
  final String? error;           // Error message
  final bool isUploadingAvatar;  // Avatar upload state
}
```

### Helper Getters
- `hasUser` - Whether user is loaded
- `hasAvatar` - Whether avatar is set
- `displayName` - User's display name
- `fullName` - User's full name

## API Endpoints

The profile provider expects these backend endpoints:

### GET /user/profile
Get user profile data.

**Response:**
```json
{
  "id": "user-id",
  "phone": "+225...",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "avatarUrl": "https://cdn.example.com/avatars/user-id.jpg",
  "countryCode": "CI",
  "phoneVerified": true,
  "kycStatus": "verified",
  "role": "user",
  "status": "active",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-15T00:00:00Z"
}
```

### PUT /user/profile
Update user profile.

**Request:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com"
}
```

### POST /user/avatar
Upload avatar image.

**Request:** multipart/form-data with `avatar` file field

**Response:** Same as GET /user/profile

### DELETE /user/avatar
Remove avatar.

**Response:** Same as GET /user/profile (with avatarUrl = null)

### GET /user/avatar
Get current avatar URL.

**Response:**
```json
{
  "avatarUrl": "https://cdn.example.com/avatars/user-id.jpg"
}
```

## Offline Support

Avatar URLs are cached in secure storage for offline access:
- Cached on successful upload/load
- Cleared on avatar removal
- Used as fallback if backend is unreachable

## Error Handling

```dart
final profileState = ref.watch(profileProvider);

if (profileState.error != null) {
  // Show error UI
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(profileState.error!)),
  );

  // Clear error after showing
  ref.read(profileProvider.notifier).clearError();
}
```

## Auth Sync

Profile updates automatically sync with auth provider:
```dart
// When profile is updated, auth provider is notified
ref.read(authProvider.notifier).updateUser(updatedUser);

// Auth state now has the latest user data
final authUser = ref.watch(authProvider).user;
```

## Loading States

### Profile Loading
```dart
if (profileState.isLoading) {
  return CircularProgressIndicator();
}
```

### Avatar Upload Loading
```dart
if (profileState.isUploadingAvatar) {
  return Stack(
    children: [
      CircleAvatar(...),
      Positioned.fill(
        child: CircularProgressIndicator(),
      ),
    ],
  );
}
```

## Best Practices

### 1. Image Optimization
```dart
final image = await picker.pickImage(
  source: source,
  maxWidth: 800,      // Limit width
  maxHeight: 800,     // Limit height
  imageQuality: 85,   // Compress
);
```

### 2. Image Size Validation
```dart
final file = File(image.path);
final bytes = await file.length();

if (bytes > 5 * 1024 * 1024) { // 5MB limit
  // Show error: "Image too large"
  return;
}
```

### 3. Loading States
Always show loading indicators during async operations:
```dart
if (profileState.isUploadingAvatar) {
  // Show spinner over avatar
}

if (profileState.isLoading) {
  // Show loading screen
}
```

### 4. Error Recovery
Provide retry mechanism for failed operations:
```dart
if (profileState.error != null) {
  ElevatedButton(
    onPressed: () => ref.read(profileProvider.notifier).loadProfile(),
    child: Text('Retry'),
  );
}
```

### 5. Cache Invalidation
Refresh profile after critical operations:
```dart
// After KYC verification
await ref.read(profileProvider.notifier).refresh();
```

## Complete Example

See `/lib/features/profile/providers/usage_example.dart` for:
- Avatar display widget
- Avatar upload from camera/gallery
- Profile edit form
- Pull to refresh
- Error handling
- Loading states

## Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  image_picker: ^1.0.0  # For avatar upload

  # Already included:
  flutter_riverpod: ^2.4.0
  flutter_secure_storage: ^9.0.0
  dio: ^5.4.0
```

## Testing

Mock the profile provider in tests:
```dart
final mockProfileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  () => ProfileNotifier()
);

// Override in tests
final container = ProviderContainer(
  overrides: [
    profileProvider.overrideWith(() => MockProfileNotifier()),
  ],
);
```

## Notes

- Avatar URLs should be CDN URLs for performance
- Images are uploaded as multipart/form-data
- Max file size should be enforced on both client and server
- Support common formats: JPG, PNG, WebP
- Consider image cropping UI before upload
- Cache avatar images using Flutter's `CachedNetworkImage` package
