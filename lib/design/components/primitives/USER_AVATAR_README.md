# UserAvatar Component

A reusable, feature-rich avatar component for displaying user profile pictures with intelligent fallbacks and states.

## Features

- **Image Loading**: Efficient image caching with `CachedNetworkImage`
- **Smart Fallbacks**: Automatic initials with gradient backgrounds
- **Loading States**: Shimmer skeleton while loading
- **Error Handling**: Graceful fallback to initials or icon
- **Multiple Sizes**: 4 predefined sizes (small, medium, large, xlarge)
- **Border Support**: Optional borders (gold for premium, green for verified)
- **Online Status**: Green/gray dot indicator
- **Tap Handler**: Navigate to profile on tap
- **Avatar Groups**: Display multiple overlapping avatars
- **Theme Support**: Works in both light and dark themes
- **Accessibility**: Semantic layout for screen readers

## Installation

No additional setup required - component uses existing dependencies:
- `cached_network_image`: Already in `pubspec.yaml`
- `app_skeleton`: Existing shimmer loader
- Design tokens: Colors, spacing, typography

## Basic Usage

### Simple Avatar with Initials

```dart
UserAvatar(
  firstName: 'Amadou',
  lastName: 'Diallo',
)
```

### Avatar with Image URL

```dart
UserAvatar(
  imageUrl: user.avatarUrl,
  firstName: user.firstName,
  lastName: user.lastName,
  size: UserAvatar.sizeMedium,
)
```

### Premium User Avatar (Gold Border)

```dart
UserAvatar(
  imageUrl: user.avatarUrl,
  firstName: user.firstName,
  lastName: user.lastName,
  size: UserAvatar.sizeLarge,
  showBorder: true,
  borderColor: AppColors.gold500,
)
```

### Avatar with Online Status

```dart
UserAvatar(
  imageUrl: user.avatarUrl,
  firstName: user.firstName,
  lastName: user.lastName,
  showOnlineIndicator: true,
  isOnline: user.isActive,
)
```

### Tappable Avatar (Profile Navigation)

```dart
UserAvatar(
  imageUrl: user.avatarUrl,
  firstName: user.firstName,
  lastName: user.lastName,
  size: UserAvatar.sizeLarge,
  onTap: () => context.push('/profile/${user.id}'),
)
```

## Avatar Groups

Display multiple users in a compact, overlapping layout:

```dart
UserAvatarGroup(
  users: [
    UserAvatarData(
      firstName: 'Amadou',
      lastName: 'Diallo',
      imageUrl: 'https://...',
    ),
    UserAvatarData(
      firstName: 'Fatou',
      lastName: 'Traore',
      imageUrl: 'https://...',
    ),
    UserAvatarData(
      firstName: 'Moussa',
      lastName: 'Kone',
      imageUrl: 'https://...',
    ),
  ],
  size: UserAvatar.sizeSmall,
  maxAvatars: 3, // Shows +N badge for overflow
  onTap: () => showParticipantsSheet(),
)
```

## Sizes

Use predefined constants for consistency:

| Constant | Size | Use Case |
|----------|------|----------|
| `UserAvatar.sizeSmall` | 32px | Transaction lists, compact layouts |
| `UserAvatar.sizeMedium` | 48px | Contact lists, messages, default |
| `UserAvatar.sizeLarge` | 64px | Profile headers, modals |
| `UserAvatar.sizeXLarge` | 96px | Full profile pages, settings |

```dart
UserAvatar(
  firstName: 'Amadou',
  lastName: 'Diallo',
  size: UserAvatar.sizeSmall, // 32px
)
```

## Fallback Behavior

The component handles missing/invalid data gracefully:

1. **Valid Image URL**: Shows cached image
2. **Loading**: Shimmer skeleton loader
3. **Error/Invalid URL**: Falls back to initials
4. **No Image + Names**: Shows initials with gradient
5. **No Image + No Names**: Shows person icon

### Initials Generation

- First + Last: "AD" (Amadou Diallo)
- First Only: "A" (Amadou)
- Last Only: "D" (Diallo)
- No Names: Person icon

### Gradient Colors

Initials have consistent gradient backgrounds based on name hash:
- 10 predefined gradient pairs
- Same name = same color (deterministic)
- Colors optimized for dark theme readability

## API Reference

### UserAvatar

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `imageUrl` | `String?` | `null` | Profile picture URL |
| `firstName` | `String?` | `null` | User's first name |
| `lastName` | `String?` | `null` | User's last name |
| `size` | `double` | `sizeMedium` (48) | Avatar diameter |
| `showBorder` | `bool` | `false` | Show border ring |
| `borderColor` | `Color?` | `AppColors.gold500` | Border color |
| `showOnlineIndicator` | `bool` | `false` | Show status dot |
| `isOnline` | `bool` | `false` | Online status (green/gray) |
| `onTap` | `VoidCallback?` | `null` | Tap handler |

### UserAvatarGroup

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `users` | `List<UserAvatarData>` | required | User data list |
| `size` | `double` | `sizeSmall` (32) | Avatar diameter |
| `maxAvatars` | `int` | `3` | Max visible avatars |
| `showBorder` | `bool` | `true` | Show borders |
| `onTap` | `VoidCallback?` | `null` | Tap handler |

### UserAvatarData

| Parameter | Type | Description |
|-----------|------|-------------|
| `imageUrl` | `String?` | Profile picture URL |
| `firstName` | `String?` | User's first name |
| `lastName` | `String?` | User's last name |

## Real-World Examples

### Transaction List Item

```dart
ListTile(
  leading: UserAvatar(
    imageUrl: transaction.recipientAvatar,
    firstName: transaction.recipientFirstName,
    lastName: transaction.recipientLastName,
    size: UserAvatar.sizeSmall,
  ),
  title: AppText(transaction.recipientName),
  subtitle: AppText('Sent ${transaction.amount} XOF'),
  trailing: AppText(transaction.timestamp),
)
```

### Contact List with Online Status

```dart
ListView.builder(
  itemBuilder: (context, index) {
    final contact = contacts[index];
    return ListTile(
      leading: UserAvatar(
        imageUrl: contact.avatarUrl,
        firstName: contact.firstName,
        lastName: contact.lastName,
        size: UserAvatar.sizeMedium,
        showOnlineIndicator: true,
        isOnline: contact.isOnline,
      ),
      title: AppText(contact.displayName),
      subtitle: AppText(contact.phoneNumber),
      onTap: () => context.push('/contact/${contact.id}'),
    );
  },
)
```

### Profile Header

```dart
Column(
  children: [
    UserAvatar(
      imageUrl: user.avatarUrl,
      firstName: user.firstName,
      lastName: user.lastName,
      size: UserAvatar.sizeXLarge,
      showBorder: user.isPremium,
      borderColor: user.isPremium ? AppColors.gold500 : null,
      onTap: () => _showEditProfilePicture(),
    ),
    SizedBox(height: AppSpacing.md),
    AppText(user.displayName, style: AppTypography.headlineMedium),
    AppText(user.phoneNumber, color: AppColors.textSecondary),
  ],
)
```

### Group Transfer Recipients

```dart
Row(
  children: [
    UserAvatarGroup(
      users: transfer.recipients.map((r) => UserAvatarData(
        firstName: r.firstName,
        lastName: r.lastName,
        imageUrl: r.avatarUrl,
      )).toList(),
      size: UserAvatar.sizeSmall,
      maxAvatars: 3,
      onTap: () => _showAllRecipients(),
    ),
    SizedBox(width: AppSpacing.sm),
    Expanded(
      child: AppText(
        transfer.recipients.length == 1
          ? transfer.recipients.first.name
          : '${transfer.recipients.length} people',
      ),
    ),
  ],
)
```

### Message Thread Header

```dart
AppBar(
  leading: BackButton(),
  title: Row(
    children: [
      UserAvatar(
        imageUrl: conversation.recipientAvatar,
        firstName: conversation.recipientFirstName,
        lastName: conversation.recipientLastName,
        size: UserAvatar.sizeSmall,
        showOnlineIndicator: true,
        isOnline: conversation.isRecipientOnline,
      ),
      SizedBox(width: AppSpacing.sm),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(conversation.recipientName, fontSize: 16),
          if (conversation.isRecipientOnline)
            AppText(
              'Active now',
              fontSize: 12,
              color: AppColors.successText,
            ),
        ],
      ),
    ],
  ),
)
```

## Performance Optimization

### Image Caching

- **Memory Cache**: 2x size for retina displays
- **Disk Cache**: Automatic via `cached_network_image`
- **Placeholder**: Shimmer skeleton (no blank flash)
- **Fade Animations**: 300ms fade in, 200ms fade out

### Rendering

- Efficient `ClipOval` for circular clipping
- Gradient generation cached by name hash
- No unnecessary rebuilds (stateless where possible)

## Accessibility

The component is designed for accessibility:

1. **Semantic Structure**: Proper widget hierarchy
2. **Tap Targets**: Minimum 48px for touch areas
3. **Visual Feedback**: Border highlights on tap
4. **Fallbacks**: Always shows something (never blank)

To add semantic labels:

```dart
Semantics(
  label: '${user.firstName} ${user.lastName} profile picture',
  button: onTap != null,
  child: UserAvatar(
    imageUrl: user.avatarUrl,
    firstName: user.firstName,
    lastName: user.lastName,
    onTap: onTap,
  ),
)
```

## Testing

### Widget Tests

```dart
testWidgets('shows initials when no image', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: UserAvatar(
          firstName: 'Amadou',
          lastName: 'Diallo',
        ),
      ),
    ),
  );

  expect(find.text('AD'), findsOneWidget);
});

testWidgets('calls onTap when tapped', (tester) async {
  bool tapped = false;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: UserAvatar(
          firstName: 'Amadou',
          onTap: () => tapped = true,
        ),
      ),
    ),
  );

  await tester.tap(find.byType(UserAvatar));
  expect(tapped, isTrue);
});
```

### Mock Data

```dart
// Test with West African names
const testUsers = [
  UserAvatarData(firstName: 'Amadou', lastName: 'Diallo'),
  UserAvatarData(firstName: 'Fatou', lastName: 'Traore'),
  UserAvatarData(firstName: 'Moussa', lastName: 'Kone'),
  UserAvatarData(firstName: 'Aissata', lastName: 'Bah'),
];
```

## Design Decisions

### Why CachedNetworkImage?

- Already in dependencies (no bloat)
- Production-proven caching
- Built-in error handling
- Memory efficient

### Why Initials Fallback?

- More personal than generic icon
- Recognizable in lists
- Consistent colors aid memory

### Why Gradient Backgrounds?

- Visual hierarchy (not flat)
- Luxury aesthetic alignment
- Better readability vs solid colors

### Why Hash-Based Colors?

- Deterministic (same name = same color)
- No database storage needed
- Cross-session consistency

## Troubleshooting

### Image Not Loading

1. Check network connectivity
2. Verify URL is valid and accessible
3. Check CORS headers (web)
4. Review CachedNetworkImage logs

### Initials Not Showing

1. Verify firstName or lastName is provided
2. Check for whitespace-only strings
3. Ensure strings are not empty

### Border Not Visible

1. Set `showBorder: true`
2. Verify `borderColor` contrast
3. Check size is large enough (>32px recommended)

### Online Indicator Misaligned

1. Ensure parent has enough space
2. Check `showOnlineIndicator: true`
3. Verify size is appropriate (>32px)

## Future Enhancements

Potential features for future versions:

- [ ] Custom badge overlays (verified, premium icons)
- [ ] Animated transitions (online status pulse)
- [ ] Multiple border styles (dashed, dotted)
- [ ] Image editing/cropping (in-app)
- [ ] Stacked animations for groups
- [ ] Video avatar support
- [ ] Lottie animations for premium users

## Related Components

- `AppSkeleton`: Loading placeholder used internally
- `AppCard`: Container for avatar sections
- `AppText`: Typography for labels
- Design Tokens: Colors, spacing, typography

## File Location

```
/Users/macbook/JoonaPay/USDC-Wallet/mobile/
└── lib/
    └── design/
        └── components/
            └── primitives/
                ├── user_avatar.dart          # Component
                ├── user_avatar_example.dart  # Examples
                └── USER_AVATAR_README.md     # This file
```

## Import

```dart
import 'package:your_app/design/components/primitives/user_avatar.dart';

// Or via index
import 'package:your_app/design/components/primitives/index.dart';
```

## Support

For issues or questions:
1. Check this README
2. Review `user_avatar_example.dart`
3. Check existing usage in codebase
4. Consult design system docs
