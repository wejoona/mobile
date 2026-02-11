/// RTL (Right-to-Left) Language Support
///
/// Export all RTL utilities and helpers for building bidirectional layouts.
///
/// Usage:
/// ```dart
/// import 'package:usdc_wallet/core/rtl/index.dart';
///
/// // Check RTL
/// if (context.isRTL) { ... }
///
/// // Use directional padding
/// padding: RTLSupport.paddingStart(16.0)
///
/// // Use RTL-aware widgets
/// DirectionalRow(children: [...])
/// ```

export 'package:usdc_wallet/core/rtl/rtl_support.dart';

// Export example widgets (remove this export in production if not needed)
// Only use for development reference
// export 'package:usdc_wallet/core/rtl/examples/rtl_compatible_examples.dart';
