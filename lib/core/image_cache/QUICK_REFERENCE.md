# Image Cache - Quick Reference

## Import

```dart
import 'package:usdc_wallet/core/image_cache/index.dart';
```

## Widgets (Copy-Paste Ready)

### Profile Photo

```dart
ProfilePhotoWidget(
  imageUrl: user.photoUrl,
  size: 48,
  fallbackInitials: 'AB',
)
```

### Bank Logo

```dart
BankLogoWidget(
  imageUrl: bank.logoUrl,
  size: 40,
  showBorder: true,
)
```

### QR Code

```dart
QRCodeWidget(
  imageUrl: qrCodeUrl,
  size: 200,
)
```

### Merchant Logo

```dart
MerchantLogoWidget(
  imageUrl: merchant.logoUrl,
  size: 56,
)
```

### Custom Image

```dart
CachedImageWidget(
  imageUrl: imageUrl,
  cacheType: ImageCacheType.profilePhoto,
  width: 100,
  height: 100,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(8),
)
```

## Preloading

### Profile Photos

```dart
@override
void initState() {
  super.initState();
  _preloadPhotos();
}

Future<void> _preloadPhotos() async {
  final contacts = ref.read(contactsProvider);
  await ImagePreloader.preloadProfilePhotos(
    context: context,
    photoUrls: contacts.map((c) => c.photoUrl).toList(),
  );
}
```

### Bank Logos

```dart
await ImagePreloader.preloadBankLogos(
  context: context,
  logoUrls: banks.map((b) => b.logoUrl).toList(),
);
```

### Merchant Logos

```dart
await ImagePreloader.preloadMerchantLogos(
  context: context,
  logoUrls: merchants.map((m) => m.logoUrl).toList(),
);
```

### Single Image

```dart
await ImagePreloader.preloadImage(
  context: context,
  imageUrl: imageUrl,
  cacheType: ImageCacheType.profilePhoto,
);
```

## Cache Management

### Clear All

```dart
await ImageCacheConfig.clearAllCaches();
```

### Clear Specific Type

```dart
await ImageCacheConfig.clearCache(ImageCacheType.profilePhoto);
await ImageCacheConfig.clearCache(ImageCacheType.bankLogo);
await ImageCacheConfig.clearCache(ImageCacheType.qrCode);
```

### Get Stats

```dart
final stats = await ImageCacheManagerService.getCacheStats();
final profileStats = stats[ImageCacheType.profilePhoto];
print('Files: ${profileStats?.fileCount}');
print('Size: ${profileStats?.totalSizeMB} MB');
```

### Get Total Size

```dart
final stats = await ImageCacheManagerService.getCacheStats();
final totalSize = stats.values.fold<int>(
  0,
  (sum, stat) => sum + stat.totalSizeBytes,
);
print('Total: ${ImageCacheManagerService.formatBytes(totalSize)}');
```

### Format Bytes

```dart
final formatted = ImageCacheManagerService.formatBytes(1024 * 1024);
// Returns: "1.0 MB"
```

### Auto-Cleanup

```dart
// Clear if total exceeds 200 MB
await ImageCacheManagerService.clearIfExceedsSize(200);
```

## Advanced Operations

### Check if Cached

```dart
final isCached = await ImagePreloader.isImageCached(
  imageUrl: imageUrl,
  cacheType: ImageCacheType.profilePhoto,
);
```

### Force Refresh

```dart
await ImagePreloader.refreshImage(
  context: context,
  imageUrl: imageUrl,
  cacheType: ImageCacheType.profilePhoto,
);
```

### Remove from Cache

```dart
await ImagePreloader.removeFromCache(
  imageUrl: imageUrl,
  cacheType: ImageCacheType.profilePhoto,
);
```

## Cache Types

```dart
enum ImageCacheType {
  profilePhoto,   // 7 days, 200 max
  bankLogo,       // 30 days, 50 max
  qrCode,         // 1 hour, 20 max
  merchantLogo,   // 14 days, 100 max
  receipt,        // 3 days, 50 max
  kycDocument,    // 7 days, 30 max
}
```

## Common Patterns

### List with Profile Photos

```dart
class ContactsList extends ConsumerStatefulWidget {
  @override
  ConsumerState<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends ConsumerState<ContactsList> {
  @override
  void initState() {
    super.initState();
    // Preload in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadPhotos();
    });
  }

  Future<void> _preloadPhotos() async {
    final contacts = ref.read(contactsProvider);
    await ImagePreloader.preloadProfilePhotos(
      context: context,
      photoUrls: contacts.map((c) => c.photoUrl).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactsProvider);

    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          leading: ProfilePhotoWidget(
            imageUrl: contact.photoUrl,
            size: 48,
            fallbackInitials: contact.initials,
          ),
          title: Text(contact.name),
        );
      },
    );
  }
}
```

### Grid with Bank Logos

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
  itemCount: banks.length,
  itemBuilder: (context, index) {
    final bank = banks[index];
    return Column(
      children: [
        BankLogoWidget(
          imageUrl: bank.logoUrl,
          size: 48,
        ),
        SizedBox(height: 8),
        Text(bank.name),
      ],
    );
  },
)
```

### Settings Screen

```dart
ListTile(
  title: Text('Clear Image Cache'),
  subtitle: FutureBuilder<String>(
    future: _getCacheSize(),
    builder: (context, snapshot) {
      return Text(snapshot.data ?? 'Calculating...');
    },
  ),
  trailing: Icon(Icons.delete_outline),
  onTap: () => _clearCache(context),
)

Future<String> _getCacheSize() async {
  final stats = await ImageCacheManagerService.getCacheStats();
  final totalSize = stats.values.fold<int>(
    0,
    (sum, stat) => sum + stat.totalSizeBytes,
  );
  return ImageCacheManagerService.formatBytes(totalSize);
}

Future<void> _clearCache(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Clear Cache?'),
      content: Text('This will remove all cached images.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Clear'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await ImageCacheConfig.clearAllCaches();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cache cleared')),
      );
    }
  }
}
```

### Logout Flow

```dart
Future<void> logout() async {
  // Clear session
  await sessionManager.clearSession();

  // Clear image caches for privacy
  await ImageCacheConfig.clearAllCaches();

  // Navigate to login
  context.go('/login');
}
```

## Widget Properties

### ProfilePhotoWidget

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| imageUrl | String? | null | Photo URL |
| size | double | 48.0 | Circle diameter |
| fallbackInitials | String? | '?' | Initials to show |
| backgroundColor | Color? | null | Background color |

### BankLogoWidget

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| imageUrl | String | required | Logo URL |
| size | double | 40.0 | Width/height |
| showBorder | bool | true | Show border |

### QRCodeWidget

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| imageUrl | String | required | QR code URL |
| size | double | 200.0 | Width/height |

### MerchantLogoWidget

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| imageUrl | String | required | Logo URL |
| size | double | 56.0 | Width/height |

### CachedImageWidget

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| imageUrl | String | required | Image URL |
| cacheType | ImageCacheType | required | Cache type |
| width | double? | null | Width |
| height | double? | null | Height |
| fit | BoxFit | cover | How to fit |
| borderRadius | BorderRadius? | null | Rounded corners |
| placeholder | Widget? | null | Loading widget |
| errorWidget | Widget? | null | Error widget |
| backgroundColor | Color? | null | Background |
| showLoadingIndicator | bool | true | Show loading |

## Performance Tips

1. **Preload before navigation**
   ```dart
   await ImagePreloader.preloadProfilePhotos(...);
   context.push('/contacts');
   ```

2. **Use appropriate cache types**
   - Profile photos: 7-day cache
   - Bank logos: 30-day cache (static)
   - QR codes: 1-hour cache (dynamic)

3. **Clear on logout**
   ```dart
   await ImageCacheConfig.clearAllCaches();
   ```

4. **Monitor cache size**
   ```dart
   await ImageCacheManagerService.clearIfExceedsSize(200);
   ```

5. **Provide fallbacks**
   ```dart
   ProfilePhotoWidget(
     imageUrl: user.photoUrl,
     fallbackInitials: user.initials, // Always provide
   )
   ```

## Troubleshooting

**Images not loading?**
```dart
// Check if URL is valid
print('Image URL: $imageUrl');

// Check if cached
final isCached = await ImagePreloader.isImageCached(
  imageUrl: imageUrl,
  cacheType: ImageCacheType.profilePhoto,
);
print('Is cached: $isCached');
```

**Cache too large?**
```dart
// Get stats
final info = await ImageCacheManagerService.getCacheInfoString();
print(info);

// Force cleanup
await ImageCacheManagerService.clearIfExceedsSize(100);
```

**Need fresh image?**
```dart
// Force refresh
await ImagePreloader.refreshImage(
  context: context,
  imageUrl: imageUrl,
  cacheType: ImageCacheType.profilePhoto,
);
```

## Testing

```dart
testWidgets('ProfilePhotoWidget shows fallback', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ProfilePhotoWidget(
        imageUrl: null,
        fallbackInitials: 'AB',
      ),
    ),
  );

  expect(find.text('AB'), findsOneWidget);
});
```

## Migration

### Before
```dart
Image.network(user.photoUrl, width: 48, height: 48)
```

### After
```dart
ProfilePhotoWidget(imageUrl: user.photoUrl, size: 48, fallbackInitials: user.initials)
```

---

**Full Documentation**: See README.md
**Examples**: See USAGE_EXAMPLES.md
**Integration**: See INTEGRATION_GUIDE.md
