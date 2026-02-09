# Integration Guide

## Step 1: Install Dependencies

```bash
cd mobile
flutter pub get
```

Dependencies required:
- `cached_network_image: ^3.4.1` (already in pubspec.yaml)
- `flutter_cache_manager: ^3.4.1` (added)

## Step 2: Import the Module

```dart
import 'package:usdc_wallet/core/image_cache/index.dart';
```

## Step 3: Replace Existing Image Usage

### Before (Old Approach)

```dart
// Profile photo
CircleAvatar(
  backgroundImage: NetworkImage(user.photoUrl),
  radius: 24,
)

// Bank logo
Image.network(
  bank.logoUrl,
  width: 40,
  height: 40,
)

// QR Code
Image.network(
  qrCodeUrl,
  width: 200,
  height: 200,
)
```

### After (New Approach)

```dart
// Profile photo
ProfilePhotoWidget(
  imageUrl: user.photoUrl,
  size: 48,
  fallbackInitials: user.initials,
)

// Bank logo
BankLogoWidget(
  imageUrl: bank.logoUrl,
  size: 40,
)

// QR Code
QRCodeWidget(
  imageUrl: qrCodeUrl,
  size: 200,
)
```

## Step 4: Add Cache Cleanup on Logout

In your auth service or logout handler:

```dart
// lib/features/auth/providers/auth_provider.dart

class AuthNotifier extends Notifier<AuthState> {
  // ... existing code

  Future<void> logout() async {
    // Clear session
    await ref.read(sessionManagerProvider).clearSession();

    // Clear image caches for privacy
    await ImageCacheConfig.clearAllCaches();

    // Navigate to login
    state = const AuthState.unauthenticated();
  }
}
```

## Step 5: Add Cache Management to Settings

```dart
// lib/features/settings/views/storage_settings_view.dart

class StorageSettingsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: AppText(l10n.settings_storage)),
      body: ListView(
        children: [
          // Show cache size
          FutureBuilder<Map<ImageCacheType, CacheStats>>(
            future: ImageCacheManagerService.getCacheStats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return ListTile(
                  title: AppText(l10n.settings_cacheSize),
                  subtitle: AppText('Loading...'),
                );
              }

              final stats = snapshot.data!;
              final totalSize = stats.values.fold<int>(
                0,
                (sum, stat) => sum + stat.totalSizeBytes,
              );

              return ListTile(
                title: AppText(l10n.settings_cacheSize),
                subtitle: AppText(
                  ImageCacheManagerService.formatBytes(totalSize),
                ),
                trailing: Icon(Icons.storage),
              );
            },
          ),

          // Clear cache button
          ListTile(
            title: AppText(l10n.settings_clearImageCache),
            subtitle: AppText(l10n.settings_clearImageCacheDesc),
            trailing: Icon(Icons.delete_outline),
            onTap: () => _showClearCacheDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearCacheDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(l10n.settings_clearImageCache),
        content: AppText(l10n.settings_clearImageCacheConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText(l10n.common_cancel),
          ),
          AppButton(
            label: l10n.common_clear,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ImageCacheConfig.clearAllCaches();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settings_cacheCleared)),
        );
      }
    }
  }
}
```

## Step 6: Add Preloading to Key Screens

### Contacts Screen

```dart
class ContactsView extends ConsumerStatefulWidget {
  @override
  ConsumerState<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends ConsumerState<ContactsView> {
  @override
  void initState() {
    super.initState();
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    final contacts = ref.read(contactsProvider);
    final photoUrls = contacts
        .where((c) => c.photoUrl != null)
        .map((c) => c.photoUrl!)
        .toList();

    if (photoUrls.isNotEmpty) {
      await ImagePreloader.preloadProfilePhotos(
        context: context,
        photoUrls: photoUrls,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... build UI
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
    // ... build UI
  }
}
```

## Step 7: Add Localized Strings

Add to `lib/l10n/app_en.arb`:

```json
{
  "settings_clearImageCache": "Clear Image Cache",
  "settings_clearImageCacheDesc": "Free up storage space",
  "settings_clearImageCacheConfirm": "This will remove all cached images. They will be re-downloaded when needed.",
  "settings_cacheCleared": "Cache cleared successfully",
  "settings_cacheSize": "Cache Size",
  "settings_cacheInfo": "Cache Information",
  "settings_storage": "Storage",
  "settings_clearProfilePhotos": "Clear Profile Photos",
  "settings_clearBankLogos": "Clear Bank Logos",
  "settings_clearQRCodes": "Clear QR Codes",
  "settings_clearMerchantLogos": "Clear Merchant Logos",
  "settings_clearAllCaches": "Clear All",
  "settings_clearCacheOptions": "Clear Cache Options"
}
```

Add to `lib/l10n/app_fr.arb`:

```json
{
  "settings_clearImageCache": "Vider le cache d'images",
  "settings_clearImageCacheDesc": "Libérer de l'espace de stockage",
  "settings_clearImageCacheConfirm": "Cela supprimera toutes les images en cache. Elles seront re-téléchargées si nécessaire.",
  "settings_cacheCleared": "Cache vidé avec succès",
  "settings_cacheSize": "Taille du cache",
  "settings_cacheInfo": "Informations sur le cache",
  "settings_storage": "Stockage",
  "settings_clearProfilePhotos": "Vider les photos de profil",
  "settings_clearBankLogos": "Vider les logos bancaires",
  "settings_clearQRCodes": "Vider les codes QR",
  "settings_clearMerchantLogos": "Vider les logos marchands",
  "settings_clearAllCaches": "Tout vider",
  "settings_clearCacheOptions": "Options de vidage du cache"
}
```

Then run:

```bash
flutter gen-l10n
```

## Step 8: Test the Implementation

Run tests:

```bash
flutter test test/core/image_cache/image_cache_test.dart
```

## Step 9: Verify in App

1. Run the app: `flutter run`
2. Navigate to screens with images
3. Check that images load properly
4. Go to Settings > Storage
5. Verify cache size is shown
6. Test clearing cache
7. Verify images reload after clearing

## Performance Checklist

- [ ] Profile photos preload before contacts screen
- [ ] Bank logos preload before bank selection
- [ ] Images fade in smoothly (300ms)
- [ ] Fallback icons show immediately when images fail
- [ ] No duplicate network requests for same image
- [ ] Cache clears on logout
- [ ] Cache size limit enforced (auto-cleanup)

## Migration Checklist

Find and replace across codebase:

1. Search for `Image.network(` → Replace with appropriate widget
2. Search for `NetworkImage(` → Replace with appropriate widget
3. Search for `CircleAvatar` with network images → Replace with `ProfilePhotoWidget`
4. Add preloading to list screens
5. Add cache clearing to logout flow
6. Add storage settings screen

## Common Patterns to Replace

### Pattern 1: Profile Photo in List

```dart
// Before
CircleAvatar(
  backgroundImage: user.photoUrl != null
      ? NetworkImage(user.photoUrl!)
      : null,
  child: user.photoUrl == null
      ? Text(user.initials)
      : null,
)

// After
ProfilePhotoWidget(
  imageUrl: user.photoUrl,
  size: 48,
  fallbackInitials: user.initials,
)
```

### Pattern 2: Bank/Merchant Logo

```dart
// Before
Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Image.network(
    bank.logoUrl,
    fit: BoxFit.contain,
  ),
)

// After
BankLogoWidget(
  imageUrl: bank.logoUrl,
  size: 40,
  showBorder: true,
)
```

### Pattern 3: QR Code Display

```dart
// Before
Container(
  width: 200,
  height: 200,
  color: Colors.white,
  child: Image.network(
    qrCodeUrl,
    fit: BoxFit.contain,
  ),
)

// After
QRCodeWidget(
  imageUrl: qrCodeUrl,
  size: 200,
)
```

## Troubleshooting

### Images not caching?

Check that `flutter_cache_manager` is installed:

```bash
flutter pub get
```

### Images not showing?

1. Check network connectivity
2. Verify image URL is valid (print it)
3. Check error widget is showing (indicates URL is broken)
4. Look for errors in console

### Cache too large?

Manually trigger cleanup:

```dart
await ImageCacheManagerService.clearIfExceedsSize(100); // 100 MB limit
```

### Need to debug cache?

```dart
final info = await ImageCacheManagerService.getCacheInfoString();
print(info);
```

## Best Practices

1. **Always use type-specific widgets** - `ProfilePhotoWidget`, `BankLogoWidget`, etc.
2. **Preload on screen init** - Don't wait for user to scroll
3. **Clear on logout** - Privacy and security
4. **Monitor cache size** - Show in settings, auto-cleanup
5. **Provide fallbacks** - Never show broken images
6. **Use appropriate TTLs** - Profile photos: 7 days, QR codes: 1 hour
7. **Test offline** - Verify cached images show when offline

## Next Steps

1. Run `flutter pub get`
2. Run `flutter gen-l10n` (if adding localized strings)
3. Replace existing image widgets with cached versions
4. Add preloading to key screens
5. Add cache management to settings
6. Test thoroughly
7. Monitor cache performance in production

## Support

For issues or questions:
- Check README.md in this directory
- Check USAGE_EXAMPLES.md for code samples
- Review test files for reference implementations
