# Image Cache Usage Examples

## Quick Start

### 1. Import the module

```dart
import 'package:usdc_wallet/core/image_cache/index.dart';
```

### 2. Use pre-built widgets

```dart
// Profile photo (circular, with fallback)
ProfilePhotoWidget(
  imageUrl: user.photoUrl,
  size: 48,
  fallbackInitials: 'AB',
)

// Bank logo (with border)
BankLogoWidget(
  imageUrl: 'https://api.joonapay.com/banks/orange-money-logo.png',
  size: 40,
)

// QR code
QRCodeWidget(
  imageUrl: 'https://api.joonapay.com/qr/payment-123.png',
  size: 200,
)

// Merchant logo
MerchantLogoWidget(
  imageUrl: merchant.logoUrl,
  size: 56,
)
```

## Real-World Examples

### Contact List with Profile Photos

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/image_cache/index.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

class ContactsView extends ConsumerStatefulWidget {
  const ContactsView({super.key});

  @override
  ConsumerState<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends ConsumerState<ContactsView> {
  @override
  void initState() {
    super.initState();
    _preloadPhotos();
  }

  Future<void> _preloadPhotos() async {
    final contacts = ref.read(contactsProvider);
    final photoUrls = contacts
        .where((c) => c.photoUrl != null)
        .map((c) => c.photoUrl!)
        .toList();

    // Preload in background for instant display
    await ImagePreloader.preloadProfilePhotos(
      context: context,
      photoUrls: photoUrls,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contacts = ref.watch(contactsProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(l10n.contacts_title, style: AppTypography.headlineSmall),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: ProfilePhotoWidget(
              imageUrl: contact.photoUrl,
              size: 48,
              fallbackInitials: contact.initials,
            ),
            title: AppText(contact.name),
            subtitle: AppText(contact.phoneNumber),
            onTap: () => _selectContact(contact),
          );
        },
      ),
    );
  }

  void _selectContact(Contact contact) {
    context.push('/send/recipient', extra: contact);
  }
}
```

### Bank Selection with Logos

```dart
class BankSelectionView extends ConsumerStatefulWidget {
  const BankSelectionView({super.key});

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
    final l10n = AppLocalizations.of(context)!;
    final banks = ref.watch(banksProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(l10n.bank_selectBank, style: AppTypography.headlineSmall),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: banks.length,
        itemBuilder: (context, index) {
          final bank = banks[index];
          return GestureDetector(
            onTap: () => _selectBank(bank),
            child: AppCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BankLogoWidget(
                    imageUrl: bank.logoUrl,
                    size: 48,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AppText(
                    bank.name,
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectBank(Bank bank) {
    context.push('/bank-linking/setup', extra: bank);
  }
}
```

### Payment QR Code Display

```dart
class PaymentQRView extends ConsumerWidget {
  final String paymentId;

  const PaymentQRView({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final qrCodeUrl = 'https://api.joonapay.com/qr/payment-$paymentId.png';

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(l10n.payment_qrCode, style: AppTypography.headlineSmall),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareQRCode(qrCodeUrl),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppCard(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: QRCodeWidget(
                imageUrl: qrCodeUrl,
                size: 250,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            AppText(
              l10n.payment_scanToPayInstruction,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareQRCode(String qrCodeUrl) async {
    // Implementation
  }
}
```

### Transaction History with Merchant Logos

```dart
class TransactionListView extends ConsumerWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final transactions = ref.watch(transactionsProvider);

    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final txn = transactions[index];
        return _TransactionItem(transaction: txn);
      },
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md),
      onTap: () => context.push('/transaction/${transaction.id}'),
      child: Row(
        children: [
          _buildIcon(),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  transaction.description,
                  style: AppTypography.bodyMedium,
                ),
                SizedBox(height: AppSpacing.xs),
                AppText(
                  _formatDate(transaction.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.silver,
                  ),
                ),
              ],
            ),
          ),
          AppText(
            _formatAmount(transaction.amount),
            style: AppTypography.titleMedium.copyWith(
              color: transaction.type == TransactionType.credit
                  ? AppColors.success
                  : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (transaction.merchantLogoUrl != null) {
      return MerchantLogoWidget(
        imageUrl: transaction.merchantLogoUrl!,
        size: 40,
      );
    }

    if (transaction.recipientPhotoUrl != null) {
      return ProfilePhotoWidget(
        imageUrl: transaction.recipientPhotoUrl,
        size: 40,
        fallbackInitials: transaction.recipientInitials,
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        _getTransactionIcon(),
        size: 20,
        color: AppColors.gold500,
      ),
    );
  }

  IconData _getTransactionIcon() {
    switch (transaction.type) {
      case TransactionType.credit:
        return Icons.arrow_downward;
      case TransactionType.debit:
        return Icons.arrow_upward;
    }
  }

  String _formatDate(DateTime date) {
    // Implementation
    return '';
  }

  String _formatAmount(double amount) {
    // Implementation
    return '';
  }
}
```

### Profile Settings with Cache Management

```dart
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(l10n.settings_title, style: AppTypography.headlineSmall),
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSection(
            l10n.settings_storage,
            [
              ListTile(
                leading: Icon(Icons.image_outlined),
                title: AppText(l10n.settings_clearImageCache),
                subtitle: AppText(l10n.settings_clearImageCacheDesc),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _showClearCacheOptions(context, l10n),
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: AppText(l10n.settings_cacheInfo),
                subtitle: FutureBuilder<String>(
                  future: _getCacheSizeString(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return AppText(
                        snapshot.data!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.silver,
                        ),
                      );
                    }
                    return AppText('...');
                  },
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _showCacheInfo(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: AppText(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.silver,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
        SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Future<void> _showClearCacheOptions(BuildContext context, AppLocalizations l10n) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.charcoal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.silver,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            AppText(
              l10n.settings_clearCacheOptions,
              style: AppTypography.headlineSmall,
            ),
            SizedBox(height: AppSpacing.lg),
            _buildClearOption(
              context,
              l10n.settings_clearProfilePhotos,
              ImageCacheType.profilePhoto,
            ),
            _buildClearOption(
              context,
              l10n.settings_clearBankLogos,
              ImageCacheType.bankLogo,
            ),
            _buildClearOption(
              context,
              l10n.settings_clearQRCodes,
              ImageCacheType.qrCode,
            ),
            _buildClearOption(
              context,
              l10n.settings_clearMerchantLogos,
              ImageCacheType.merchantLogo,
            ),
            SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.settings_clearAllCaches,
              onPressed: () => _clearAllCaches(context),
              variant: ButtonVariant.secondary,
            ),
            SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.common_cancel,
              onPressed: () => Navigator.pop(context),
              variant: ButtonVariant.text,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearOption(
    BuildContext context,
    String label,
    ImageCacheType type,
  ) {
    return ListTile(
      title: AppText(label),
      trailing: Icon(Icons.delete_outline),
      onTap: () => _clearCache(context, type),
    );
  }

  Future<void> _clearCache(BuildContext context, ImageCacheType type) async {
    await ImageCacheConfig.clearCache(type);
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cache cleared')),
      );
    }
  }

  Future<void> _clearAllCaches(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: AppText('Clear All Caches?'),
        content: AppText('This will remove all cached images.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText('Cancel'),
          ),
          AppButton(
            label: 'Clear',
            onPressed: () => Navigator.pop(context, true),
            variant: ButtonVariant.secondary,
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ImageCacheConfig.clearAllCaches();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All caches cleared')),
        );
      }
    }
  }

  Future<String> _getCacheSizeString() async {
    final stats = await ImageCacheManagerService.getCacheStats();
    final totalSize = stats.values.fold<int>(
      0,
      (sum, stat) => sum + stat.totalSizeBytes,
    );
    return ImageCacheManagerService.formatBytes(totalSize);
  }

  Future<void> _showCacheInfo(BuildContext context) async {
    final info = await ImageCacheManagerService.getCacheInfoString();
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.charcoal,
          title: AppText('Cache Information'),
          content: SingleChildScrollView(
            child: AppText(
              info,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppColors.silver,
              ),
            ),
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

### Custom Image Widget

```dart
class CustomImageExample extends StatelessWidget {
  final String imageUrl;

  const CustomImageExample({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      cacheType: ImageCacheType.profilePhoto,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      backgroundColor: AppColors.charcoal,
      placeholder: _buildCustomPlaceholder(),
      errorWidget: _buildCustomError(),
      showLoadingIndicator: false, // Using custom placeholder
    );
  }

  Widget _buildCustomPlaceholder() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold500),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          AppText(
            'Loading...',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.silver,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomError() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: AppColors.silver.withOpacity(0.5),
          ),
          SizedBox(height: AppSpacing.sm),
          AppText(
            'Failed to load',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.silver,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Advanced Patterns

### Refresh Profile Photo After Upload

```dart
class ProfilePhotoUploadService {
  Future<void> uploadAndRefreshPhoto({
    required BuildContext context,
    required File photoFile,
  }) async {
    // Upload photo
    final response = await apiClient.uploadProfilePhoto(photoFile);
    final newPhotoUrl = response.data['photoUrl'] as String;

    // Force refresh the cached image
    await ImagePreloader.refreshImage(
      context: context,
      imageUrl: newPhotoUrl,
      cacheType: ImageCacheType.profilePhoto,
    );

    // Update user state
    ref.read(userProvider.notifier).updatePhotoUrl(newPhotoUrl);
  }
}
```

### Conditional Preloading

```dart
class SmartPreloader {
  Future<void> preloadIfNotCached({
    required BuildContext context,
    required List<String> imageUrls,
    required ImageCacheType cacheType,
  }) async {
    final uncachedUrls = <String>[];

    for (final url in imageUrls) {
      final isCached = await ImagePreloader.isImageCached(
        imageUrl: url,
        cacheType: cacheType,
      );

      if (!isCached) {
        uncachedUrls.add(url);
      }
    }

    if (uncachedUrls.isNotEmpty) {
      await ImagePreloader.preloadImages(
        context: context,
        imageUrls: uncachedUrls,
        cacheType: cacheType,
      );
    }
  }
}
```

### Background Cache Cleanup

```dart
class CacheMaintenanceService {
  static Future<void> performMaintenance() async {
    // Clear QR codes (short-lived)
    await ImageCacheConfig.clearCache(ImageCacheType.qrCode);

    // Clear if total size exceeds 200 MB
    await ImageCacheManagerService.clearIfExceedsSize(200);

    // Log stats
    final stats = await ImageCacheManagerService.getCacheStats();
    debugPrint('Cache maintenance completed:');
    for (final entry in stats.entries) {
      debugPrint(
        '  ${entry.key}: ${entry.value.fileCount} files, '
        '${ImageCacheManagerService.formatBytes(entry.value.totalSizeBytes)}',
      );
    }
  }
}

// Call periodically or on app start
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Perform cache maintenance
  await CacheMaintenanceService.performMaintenance();

  runApp(const MyApp());
}
```
