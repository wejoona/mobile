# Image Cache Module

Optimized image caching configuration for JoonaPay mobile app, designed for West African network conditions (slower 3G/4G).

## Features

- **Type-specific cache policies** - Different TTLs for profile photos, bank logos, QR codes
- **Memory optimization** - Automatic downsampling for display size
- **Preloading support** - Preload images before screen navigation
- **Cache management** - Size limits, cleanup, statistics
- **Optimized widgets** - Pre-configured components for common use cases

## Cache Types

| Type | TTL | Max Objects | Use Case |
|------|-----|-------------|----------|
| Profile Photos | 7 days | 200 | User avatars, contact photos |
| Bank Logos | 30 days | 50 | Bank/mobile money provider logos |
| QR Codes | 1 hour | 20 | Payment QR codes (dynamic) |
| Merchant Logos | 14 days | 100 | Merchant brand images |
| Receipts | 3 days | 50 | Transaction receipts, screenshots |
| KYC Documents | 7 days | 30 | Identity verification photos |

## Usage

### 1. Pre-built Widgets (Recommended)

```dart
// Profile photo with circular crop
ProfilePhotoWidget(
  imageUrl: user.photoUrl,
  size: 48,
  fallbackInitials: 'AB',
)

// Bank logo with standardized sizing
BankLogoWidget(
  imageUrl: bank.logoUrl,
  size: 40,
  showBorder: true,
)

// QR code
QRCodeWidget(
  imageUrl: qrCodeUrl,
  size: 200,
)

// Merchant logo
MerchantLogoWidget(
  imageUrl: merchant.logoUrl,
  size: 56,
)
```

### 2. Custom Cached Image

```dart
CachedImageWidget(
  imageUrl: imageUrl,
  cacheType: ImageCacheType.profilePhoto,
  width: 100,
  height: 100,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(8),
  placeholder: MyCustomLoader(),
  errorWidget: MyCustomError(),
)
```

### 3. Preloading

Preload images before navigating to a screen for instant display:

```dart
// Before navigating to contacts screen
await ImagePreloader.preloadProfilePhotos(
  context: context,
  photoUrls: contacts.map((c) => c.photoUrl).toList(),
);
context.push('/contacts');

// Before navigating to bank selection
await ImagePreloader.preloadBankLogos(
  context: context,
  logoUrls: banks.map((b) => b.logoUrl).toList(),
);
```

### 4. Cache Management

```dart
// Clear all caches (on logout)
await ImageCacheConfig.clearAllCaches();

// Clear specific cache type
await ImageCacheConfig.clearCache(ImageCacheType.qrCode);

// Get cache statistics
final stats = await ImageCacheManagerService.getCacheStats();
print('Profile photos: ${stats[ImageCacheType.profilePhoto]?.totalSizeMB} MB');

// Clear if exceeds size limit
await ImageCacheManagerService.clearIfExceedsSize(200); // 200 MB

// Get human-readable cache info
final info = await ImageCacheManagerService.getCacheInfoString();
print(info);
```

### 5. Advanced Operations

```dart
// Check if image is cached
final isCached = await ImagePreloader.isImageCached(
  imageUrl: imageUrl,
  cacheType: ImageCacheType.profilePhoto,
);

// Force refresh (remove and re-download)
await ImagePreloader.refreshImage(
  context: context,
  imageUrl: imageUrl,
  cacheType: ImageCacheType.profilePhoto,
);

// Remove specific image
await ImagePreloader.removeFromCache(
  imageUrl: imageUrl,
  cacheType: ImageCacheType.profilePhoto,
);
```

## Integration Examples

### Profile Screen

```dart
class ProfileView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      body: Column(
        children: [
          ProfilePhotoWidget(
            imageUrl: user.photoUrl,
            size: 100,
            fallbackInitials: user.initials,
          ),
          AppText(user.name),
        ],
      ),
    );
  }
}
```

### Bank Selection Screen

```dart
class BankSelectionView extends ConsumerStatefulWidget {
  @override
  ConsumerState<BankSelectionView> createState() => _BankSelectionViewState();
}

class _BankSelectionViewState extends ConsumerState<BankSelectionView> {
  @override
  void initState() {
    super.initState();
    _preloadBankLogos();
  }

  Future<void> _preloadBankLogos() async {
    final banks = ref.read(banksProvider);
    await ImagePreloader.preloadBankLogos(
      context: context,
      logoUrls: banks.map((b) => b.logoUrl).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final banks = ref.watch(banksProvider);

    return ListView.builder(
      itemCount: banks.length,
      itemBuilder: (context, index) {
        final bank = banks[index];
        return ListTile(
          leading: BankLogoWidget(
            imageUrl: bank.logoUrl,
            size: 40,
          ),
          title: AppText(bank.name),
        );
      },
    );
  }
}
```

### Settings Screen

```dart
class SettingsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          ListTile(
            title: AppText(l10n.settings_clearImageCache),
            subtitle: AppText(l10n.settings_clearImageCacheDesc),
            trailing: Icon(Icons.cleaning_services),
            onTap: () => _clearImageCache(context),
          ),
          ListTile(
            title: AppText(l10n.settings_cacheInfo),
            trailing: Icon(Icons.info_outline),
            onTap: () => _showCacheInfo(context),
          ),
        ],
      ),
    );
  }

  Future<void> _clearImageCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText('Clear Image Cache?'),
        content: AppText('This will remove all cached images.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText('Cancel'),
          ),
          AppButton(
            label: 'Clear',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ImageCacheConfig.clearAllCaches();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    }
  }

  Future<void> _showCacheInfo(BuildContext context) async {
    final info = await ImageCacheManagerService.getCacheInfoString();
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: AppText('Cache Information'),
          content: SingleChildScrollView(
            child: AppText(info, style: TextStyle(fontFamily: 'monospace')),
          ),
          actions: [
            AppButton(
              label: 'Close',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }
}
```

## Performance Optimizations

1. **Memory Caching**: Images are automatically downsampled to 2x display size
2. **Disk Caching**: Persistent cache across app sessions
3. **Deduplication**: Same image URL won't be fetched twice
4. **Lazy Loading**: Images load on-demand, not eagerly
5. **Fade Animations**: Smooth 300ms fade-in for perceived performance

## Network Optimization

Designed for West African network conditions:

- **Long TTLs**: Reduce re-downloads on slow networks
- **Aggressive Caching**: Prefer stale content over loading states
- **Preloading**: Load images during idle time
- **Fallbacks**: Always show something (placeholder/error) immediately

## Cache Cleanup Strategy

1. **Automatic**: Stale entries removed based on TTL
2. **Manual**: User can clear via settings
3. **Size-based**: Auto-clear least important caches if total size exceeds limit
4. **On Logout**: Clear all caches for privacy

## Testing

```dart
// Mock image URLs for testing
const testProfileUrl = 'https://api.joonapay.com/profiles/test-user.jpg';
const testBankUrl = 'https://api.joonapay.com/banks/orange-money.png';

// Test widget
testWidgets('ProfilePhotoWidget shows image', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ProfilePhotoWidget(
        imageUrl: testProfileUrl,
        size: 48,
      ),
    ),
  );

  // Wait for image to load
  await tester.pumpAndSettle();

  expect(find.byType(CachedNetworkImage), findsOneWidget);
});
```

## Accessibility

- All error states include descriptive icons
- Images have implicit labels from context
- Loading states don't block interaction
- High contrast fallback colors

## Migration Guide

Replace existing image usage:

```dart
// Old
Image.network(
  user.photoUrl,
  width: 48,
  height: 48,
)

// New
ProfilePhotoWidget(
  imageUrl: user.photoUrl,
  size: 48,
)
```

## Troubleshooting

**Images not loading?**
- Check network connectivity
- Verify image URL is valid
- Check cache size hasn't exceeded limits

**Stale images showing?**
- Force refresh: `ImagePreloader.refreshImage()`
- Clear cache: `ImageCacheConfig.clearCache(type)`

**Cache too large?**
- Check stats: `ImageCacheManagerService.getCacheStats()`
- Clear old caches: `ImageCacheManagerService.clearIfExceedsSize(100)`

## Future Enhancements

- [ ] Progressive image loading (blur-up)
- [ ] WebP format support
- [ ] Background sync for profile photos
- [ ] Analytics for cache hit rates
- [ ] Adaptive quality based on network speed
