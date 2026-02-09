# UserAvatar - Quick Start Guide

One-page reference for the UserAvatar component.

## Import

```dart
import 'package:joonapay_wallet/design/components/primitives/index.dart';
```

## Common Use Cases

### 1. Transaction List Item

```dart
UserAvatar(
  imageUrl: user.avatarUrl,
  firstName: user.firstName,
  lastName: user.lastName,
  size: UserAvatar.sizeSmall, // 32px
)
```

### 2. Contact List

```dart
UserAvatar(
  imageUrl: contact.avatarUrl,
  firstName: contact.firstName,
  lastName: contact.lastName,
  size: UserAvatar.sizeMedium, // 48px (default)
  showOnlineIndicator: true,
  isOnline: contact.isActive,
)
```

### 3. Profile Header

```dart
UserAvatar(
  imageUrl: user.avatarUrl,
  firstName: user.firstName,
  lastName: user.lastName,
  size: UserAvatar.sizeXLarge, // 96px
  showBorder: user.isPremium,
  borderColor: AppColors.gold500,
  onTap: () => _editProfilePicture(),
)
```

### 4. Group Recipients

```dart
UserAvatarGroup(
  users: recipients.map((r) => UserAvatarData(
    firstName: r.firstName,
    lastName: r.lastName,
    imageUrl: r.avatarUrl,
  )).toList(),
  size: UserAvatar.sizeSmall,
  maxAvatars: 3,
  onTap: () => _showAllRecipients(),
)
```

## Sizes

```dart
UserAvatar.sizeSmall    // 32px - Lists, compact
UserAvatar.sizeMedium   // 48px - Default
UserAvatar.sizeLarge    // 64px - Modals, headers
UserAvatar.sizeXLarge   // 96px - Profile pages
```

## Properties

| Property | Type | Default | Example |
|----------|------|---------|---------|
| `imageUrl` | `String?` | `null` | `"https://..."` |
| `firstName` | `String?` | `null` | `"Amadou"` |
| `lastName` | `String?` | `null` | `"Diallo"` |
| `size` | `double` | `48` | `UserAvatar.sizeLarge` |
| `showBorder` | `bool` | `false` | `true` |
| `borderColor` | `Color?` | gold | `AppColors.gold500` |
| `showOnlineIndicator` | `bool` | `false` | `true` |
| `isOnline` | `bool` | `false` | `user.isActive` |
| `onTap` | `VoidCallback?` | `null` | `() => navigate()` |

## Border Colors (Common)

```dart
AppColors.gold500       // Premium users
AppColors.successBase   // Verified users
AppColors.infoBase      // Special status
```

## Fallback Behavior

1. Has `imageUrl` → Shows image (cached)
2. Loading → Shimmer skeleton
3. Error/No URL + Names → Initials with gradient
4. No Names → Person icon

## Examples in Code

### Minimal

```dart
UserAvatar(
  firstName: 'Amadou',
  lastName: 'Diallo',
)
```

### Full Featured

```dart
UserAvatar(
  imageUrl: 'https://example.com/avatar.jpg',
  firstName: 'Amadou',
  lastName: 'Diallo',
  size: UserAvatar.sizeLarge,
  showBorder: true,
  borderColor: AppColors.gold500,
  showOnlineIndicator: true,
  isOnline: true,
  onTap: () => context.push('/profile'),
)
```

## Files

- **Component**: `/lib/design/components/primitives/user_avatar.dart`
- **Examples**: `/lib/design/components/primitives/user_avatar_example.dart`
- **Tests**: `/test/widgets/user_avatar_test.dart`
- **Docs**: `USER_AVATAR_README.md`
