import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/core/image_cache/image_cache_config.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Optimized cached network image widget with built-in error handling
/// and loading states for different image types
class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final ImageCacheType cacheType;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final bool showLoadingIndicator;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    required this.cacheType,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.showLoadingIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cacheManager = ImageCacheConfig.getManager(cacheType);

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: cacheManager,
      width: width,
      height: height,
      fit: fit,
      placeholder: showLoadingIndicator
          ? (context, url) =>
                placeholder ?? _buildDefaultPlaceholder(colors)
          : null,
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildDefaultErrorWidget(colors),
      // Optimize for performance
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    if (backgroundColor != null) {
      imageWidget = Container(
        width: width,
        height: height,
        color: backgroundColor,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder(ThemeColors colors) {
    return Container(
      width: width,
      height: height,
      color: colors.surface.withValues(alpha: colors.isDark ? 0.55 : 0.85),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              colors.gold.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget(ThemeColors colors) {
    IconData iconData;
    switch (cacheType) {
      case ImageCacheType.profilePhoto:
        iconData = Icons.person_outline;
        break;
      case ImageCacheType.bankLogo:
      case ImageCacheType.merchantLogo:
        iconData = Icons.business_outlined;
        break;
      case ImageCacheType.qrCode:
        iconData = Icons.qr_code_2_outlined;
        break;
      case ImageCacheType.receipt:
        iconData = Icons.receipt_outlined;
        break;
      case ImageCacheType.kycDocument:
        iconData = Icons.description_outlined;
        break;
    }

    return Container(
      width: width,
      height: height,
      color: colors.surface.withValues(alpha: colors.isDark ? 0.55 : 0.85),
      child: Icon(
        iconData,
        size: (width ?? 40) * 0.4,
        color: colors.iconSecondary,
      ),
    );
  }
}

/// Profile photo with circular crop and optimized caching
class ProfilePhotoWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? fallbackInitials;
  final Color? backgroundColor;

  const ProfilePhotoWidget({
    super.key,
    this.imageUrl,
    this.size = 48.0,
    this.fallbackInitials,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback(colors);
    }

    return CachedImageWidget(
      imageUrl: imageUrl!,
      cacheType: ImageCacheType.profilePhoto,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(size / 2),
      backgroundColor: backgroundColor ?? colors.elevated,
      errorWidget: _buildFallback(colors),
    );
  }

  Widget _buildFallback(ThemeColors colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.goldSubtle,
        shape: BoxShape.circle,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Center(
        child: Text(
          fallbackInitials ?? '?',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: colors.gold,
          ),
        ),
      ),
    );
  }
}

/// Bank logo with standardized sizing and caching
class BankLogoWidget extends StatelessWidget {
  final String imageUrl;
  final double size;
  final bool showBorder;

  const BankLogoWidget({
    super.key,
    required this.imageUrl,
    this.size = 40.0,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget logo = CachedImageWidget(
      imageUrl: imageUrl,
      cacheType: ImageCacheType.bankLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      backgroundColor: colors.container,
      borderRadius: BorderRadius.circular(AppRadius.sm),
    );

    if (showBorder) {
      logo = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.borderSubtle,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: logo,
      );
    }

    return logo;
  }
}

/// QR code with optimized caching for dynamic codes
class QRCodeWidget extends StatelessWidget {
  final String imageUrl;
  final double size;

  const QRCodeWidget({
    super.key,
    required this.imageUrl,
    this.size = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    // QR codes require a white background for reliable scanning.
    return CachedImageWidget(
      imageUrl: imageUrl,
      cacheType: ImageCacheType.qrCode,
      width: size,
      height: size,
      fit: BoxFit.contain,
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
  }
}

/// Merchant logo with standardized sizing
class MerchantLogoWidget extends StatelessWidget {
  final String imageUrl;
  final double size;

  const MerchantLogoWidget({
    super.key,
    required this.imageUrl,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CachedImageWidget(
      imageUrl: imageUrl,
      cacheType: ImageCacheType.merchantLogo,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(AppRadius.md),
      backgroundColor: colors.surface,
    );
  }
}