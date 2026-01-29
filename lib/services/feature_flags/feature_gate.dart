import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feature_flags_provider.dart';

/// Feature Gate Widget
///
/// Conditionally renders a widget based on a feature flag.
/// If the flag is disabled, shows fallback widget (default: nothing).
///
/// Usage:
/// ```dart
/// FeatureGate(
///   flag: FeatureFlagKeys.billPayments,
///   child: BillPaymentsButton(),
///   fallback: DisabledFeatureMessage(),
/// )
/// ```
class FeatureGate extends ConsumerWidget {
  /// Feature flag key to check
  final String flag;

  /// Widget to show when feature is enabled
  final Widget child;

  /// Widget to show when feature is disabled (default: empty)
  final Widget fallback;

  const FeatureGate({
    super.key,
    required this.flag,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);
    final isEnabled = flags[flag] ?? false;

    return isEnabled ? child : fallback;
  }
}

/// Feature Gate Builder
///
/// Provides a builder pattern for more complex conditional rendering.
///
/// Usage:
/// ```dart
/// FeatureGateBuilder(
///   flag: FeatureFlagKeys.savingsPots,
///   builder: (context, isEnabled) {
///     if (!isEnabled) {
///       return ComingSoonBanner();
///     }
///     return SavingsPotsCard();
///   },
/// )
/// ```
class FeatureGateBuilder extends ConsumerWidget {
  /// Feature flag key to check
  final String flag;

  /// Builder function that receives enabled state
  final Widget Function(BuildContext context, bool isEnabled) builder;

  const FeatureGateBuilder({
    super.key,
    required this.flag,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);
    final isEnabled = flags[flag] ?? false;

    return builder(context, isEnabled);
  }
}

/// Multi-Feature Gate
///
/// Renders child only if ALL specified flags are enabled.
///
/// Usage:
/// ```dart
/// MultiFeatureGate(
///   flags: [
///     FeatureFlagKeys.externalTransfers,
///     FeatureFlagKeys.biometricAuth,
///   ],
///   child: SecureExternalTransferButton(),
/// )
/// ```
class MultiFeatureGate extends ConsumerWidget {
  /// List of feature flags - ALL must be enabled
  final List<String> flags;

  /// Widget to show when all features are enabled
  final Widget child;

  /// Widget to show when any feature is disabled (default: empty)
  final Widget fallback;

  const MultiFeatureGate({
    super.key,
    required this.flags,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flagsState = ref.watch(featureFlagsProvider);

    // Check if all flags are enabled
    final allEnabled = flags.every((flag) => flagsState[flag] ?? false);

    return allEnabled ? child : fallback;
  }
}

/// Any Feature Gate
///
/// Renders child if ANY of the specified flags are enabled.
///
/// Usage:
/// ```dart
/// AnyFeatureGate(
///   flags: [
///     FeatureFlagKeys.billPayments,
///     FeatureFlagKeys.airtime,
///   ],
///   child: ServicesSection(),
/// )
/// ```
class AnyFeatureGate extends ConsumerWidget {
  /// List of feature flags - ANY must be enabled
  final List<String> flags;

  /// Widget to show when any feature is enabled
  final Widget child;

  /// Widget to show when all features are disabled (default: empty)
  final Widget fallback;

  const AnyFeatureGate({
    super.key,
    required this.flags,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flagsState = ref.watch(featureFlagsProvider);

    // Check if any flag is enabled
    final anyEnabled = flags.any((flag) => flagsState[flag] ?? false);

    return anyEnabled ? child : fallback;
  }
}
