import 'package:flutter/material.dart';
import '../../tokens/index.dart';
import '../primitives/index.dart';

/// Themed bottom sheet component
///
/// Provides consistent styling for bottom sheets across light and dark themes.
/// Includes drag handle, proper safe area padding, and scrollable content.
///
/// Usage:
/// ```dart
/// // Simple bottom sheet
/// await AppBottomSheet.show(
///   context,
///   title: 'Select Country',
///   child: CountryListWidget(),
/// );
///
/// // Scrollable bottom sheet with custom height
/// await AppBottomSheet.showScrollable(
///   context,
///   title: 'Transaction Details',
///   builder: (context) => TransactionDetailsWidget(),
///   initialChildSize: 0.6,
/// );
///
/// // Full-screen modal
/// await AppBottomSheet.showFullScreen(
///   context,
///   title: 'Edit Profile',
///   child: ProfileFormWidget(),
/// );
/// ```
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    this.title,
    this.titleWidget,
    required this.child,
    this.showHandle = true,
    this.showCloseButton = false,
    this.padding,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget child;
  final bool showHandle;
  final bool showCloseButton;
  final EdgeInsetsGeometry? padding;

  /// Show a bottom sheet
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    Widget? titleWidget,
    required Widget child,
    bool showHandle = true,
    bool showCloseButton = false,
    EdgeInsetsGeometry? padding,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final colors = context.colors;

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: colors.container,
      barrierColor: colors.scrim,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      builder: (context) => AppBottomSheet(
        title: title,
        titleWidget: titleWidget,
        showHandle: showHandle,
        showCloseButton: showCloseButton,
        padding: padding,
        child: child,
      ),
    );
  }

  /// Show a scrollable bottom sheet with DraggableScrollableSheet
  static Future<T?> showScrollable<T>(
    BuildContext context, {
    String? title,
    Widget? titleWidget,
    required Widget Function(BuildContext) builder,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.95,
    bool showHandle = true,
    bool showCloseButton = false,
  }) {
    final colors = context.colors;

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: colors.scrim,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colors.container,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xxl),
              ),
            ),
            child: Column(
              children: [
                if (showHandle) _DragHandle(),
                if (title != null || titleWidget != null)
                  _SheetHeader(
                    title: title,
                    titleWidget: titleWidget,
                    showCloseButton: showCloseButton,
                  ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    children: [
                      builder(context),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Show a full-screen modal bottom sheet
  static Future<T?> showFullScreen<T>(
    BuildContext context, {
    String? title,
    Widget? titleWidget,
    required Widget child,
    bool showCloseButton = true,
  }) {
    final colors = context.colors;

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: colors.container,
      barrierColor: colors.scrim,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AppBottomSheet(
        title: title,
        titleWidget: titleWidget,
        showHandle: false,
        showCloseButton: showCloseButton,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: padding ??
            EdgeInsets.only(
              left: AppSpacing.screenPadding,
              right: AppSpacing.screenPadding,
              top: AppSpacing.screenPadding,
              bottom: AppSpacing.screenPadding +
                  MediaQuery.of(context).viewInsets.bottom,
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            if (showHandle) _DragHandle(),

            // Header
            if (title != null || titleWidget != null)
              _SheetHeader(
                title: title,
                titleWidget: titleWidget,
                showCloseButton: showCloseButton,
              ),

            // Content
            child,
          ],
        ),
      ),
    );
  }
}

/// Drag handle widget
class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.lg,
      ),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colors.textTertiary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Sheet header with optional title and close button
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    this.title,
    this.titleWidget,
    required this.showCloseButton,
  });

  final String? title;
  final Widget? titleWidget;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: titleWidget ??
                (title != null
                    ? AppText(
                        title!,
                        variant: AppTextVariant.titleLarge,
                        color: colors.textPrimary,
                      )
                    : const SizedBox.shrink()),
          ),
          if (showCloseButton)
            IconButton(
              icon: Icon(Icons.close, color: colors.textSecondary),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

/// Extension to show bottom sheets from any BuildContext
extension AppBottomSheetExtension on BuildContext {
  /// Show a bottom sheet
  Future<T?> showBottomSheet<T>({
    String? title,
    Widget? titleWidget,
    required Widget child,
    bool showHandle = true,
    bool showCloseButton = false,
    EdgeInsetsGeometry? padding,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return AppBottomSheet.show<T>(
      this,
      title: title,
      titleWidget: titleWidget,
      child: child,
      showHandle: showHandle,
      showCloseButton: showCloseButton,
      padding: padding,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// Show a scrollable bottom sheet
  Future<T?> showScrollableBottomSheet<T>({
    String? title,
    Widget? titleWidget,
    required Widget Function(BuildContext) builder,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.95,
    bool showHandle = true,
    bool showCloseButton = false,
  }) {
    return AppBottomSheet.showScrollable<T>(
      this,
      title: title,
      titleWidget: titleWidget,
      builder: builder,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      showHandle: showHandle,
      showCloseButton: showCloseButton,
    );
  }

  /// Show a full-screen modal bottom sheet
  Future<T?> showFullScreenBottomSheet<T>({
    String? title,
    Widget? titleWidget,
    required Widget child,
    bool showCloseButton = true,
  }) {
    return AppBottomSheet.showFullScreen<T>(
      this,
      title: title,
      titleWidget: titleWidget,
      child: child,
      showCloseButton: showCloseButton,
    );
  }
}
