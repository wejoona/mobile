# Dialog & Bottom Sheet Migration Guide

This guide shows how to migrate existing dialogs and bottom sheets to use the new themed components.

## Quick Reference

| Old Pattern | New Component | Method |
|-------------|---------------|--------|
| `showDialog<bool>` with yes/no | `ConfirmationDialog` | `ConfirmationDialog.show()` |
| `AlertDialog` with single button | `AlertDialog` | `AlertDialog.show()` |
| `showModalBottomSheet` | `AppBottomSheet` | `AppBottomSheet.show()` |
| Generic info dialog | `AppDialog` | `AppDialog.info()` |
| Error message | `AlertDialog` | `AlertDialog.error()` |
| Success message | `AlertDialog` | `AlertDialog.success()` |

## Benefits

- Automatic light/dark theme support
- Consistent spacing and sizing
- Proper barrier colors (scrim)
- Semantic color coding (error = red, success = green)
- Accessibility improvements
- Less boilerplate code

---

## Migration Examples

### 1. Confirmation Dialog (Yes/No)

#### Before (Hardcoded)
```dart
Future<void> _handleRevokeDevice(
  BuildContext context,
  WidgetRef ref,
  Device device,
  AppLocalizations l10n,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.slate, // ❌ Hardcoded dark color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: AppText(
          l10n.settings_removeDevice,
          variant: AppTextVariant.titleMedium,
        ),
        content: AppText(
          l10n.settings_removeDeviceConfirm,
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary, // ❌ Hardcoded
        ),
        actions: [
          AppButton(
            label: l10n.action_cancel,
            onPressed: () => Navigator.pop(dialogContext, false),
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.small,
          ),
          AppButton(
            label: l10n.action_remove,
            onPressed: () => Navigator.pop(dialogContext, true),
            variant: AppButtonVariant.error,
            size: AppButtonSize.small,
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    // Perform action
  }
}
```

#### After (Themed)
```dart
Future<void> _handleRevokeDevice(
  BuildContext context,
  WidgetRef ref,
  Device device,
  AppLocalizations l10n,
) async {
  // ✅ Automatically themed, concise
  final confirmed = await ConfirmationDialog.show(
    context,
    title: l10n.settings_removeDevice,
    message: l10n.settings_removeDeviceConfirm,
    confirmText: l10n.action_remove,
    cancelText: l10n.action_cancel,
    isDestructive: true, // Shows red button + delete icon
  );

  if (confirmed) {
    // Perform action
  }
}
```

#### Even Shorter with Extension
```dart
final confirmed = await context.showDeleteConfirmation(
  title: l10n.settings_removeDevice,
  message: l10n.settings_removeDeviceConfirm,
);
```

---

### 2. Success Alert

#### Before
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: AppText(l10n.settings_deviceTrustedSuccess),
    backgroundColor: AppColors.successBase,
  ),
);
```

#### After
```dart
await AlertDialog.success(
  context,
  title: l10n.common_success,
  message: l10n.settings_deviceTrustedSuccess,
);

// Or with extension
await context.showSuccessAlert(
  title: l10n.common_success,
  message: l10n.settings_deviceTrustedSuccess,
);
```

---

### 3. Error Alert

#### Before
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: AppText(l10n.settings_deviceTrustError),
    backgroundColor: AppColors.errorBase,
  ),
);
```

#### After
```dart
await AlertDialog.error(
  context,
  title: l10n.common_error,
  message: l10n.settings_deviceTrustError,
);

// Or with extension
await context.showErrorAlert(
  title: l10n.common_error,
  message: l10n.settings_deviceTrustError,
);
```

---

### 4. Bottom Sheet

#### Before
```dart
showModalBottomSheet(
  context: context,
  backgroundColor: AppColors.charcoal, // ❌ Hardcoded
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(AppRadius.lg),
    ),
  ),
  builder: (context) => Padding(
    padding: EdgeInsets.all(AppSpacing.md),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Manual handle
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.silver,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        // Content here
        MyContentWidget(),
      ],
    ),
  ),
);
```

#### After
```dart
await AppBottomSheet.show(
  context,
  title: 'Select Option',
  child: MyContentWidget(),
);

// Or with extension
await context.showBottomSheet(
  title: 'Select Option',
  child: MyContentWidget(),
);
```

---

### 5. Scrollable Bottom Sheet with DraggableScrollableSheet

#### Before
```dart
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.6,
    builder: (context, controller) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.slate, // ❌ Hardcoded
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        child: ListView(
          controller: controller,
          children: [
            MyLongContentWidget(),
          ],
        ),
      );
    },
  ),
);
```

#### After
```dart
await AppBottomSheet.showScrollable(
  context,
  title: 'Transaction History',
  builder: (context) => MyLongContentWidget(),
  initialChildSize: 0.6,
);

// Or with extension
await context.showScrollableBottomSheet(
  title: 'Transaction History',
  builder: (context) => MyLongContentWidget(),
  initialChildSize: 0.6,
);
```

---

### 6. Full-Screen Modal

#### Before
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: AppColors.obsidian,
  builder: (context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: MyFormWidget(),
    ),
  ),
);
```

#### After
```dart
await AppBottomSheet.showFullScreen(
  context,
  title: 'Edit Profile',
  child: MyFormWidget(),
);

// Or with extension
await context.showFullScreenBottomSheet(
  title: 'Edit Profile',
  child: MyFormWidget(),
);
```

---

### 7. Info Dialog with Icon

#### Before
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    backgroundColor: AppColors.slate,
    title: Row(
      children: [
        Icon(Icons.info_outline, color: AppColors.gold500),
        SizedBox(width: 8),
        Text('Important'),
      ],
    ),
    content: Text('Please read these terms...'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('OK'),
      ),
    ],
  ),
);
```

#### After
```dart
await AppDialog.info(
  context,
  title: 'Important',
  message: 'Please read these terms...',
);

// Or with custom icon
await AppDialog.show(
  context,
  title: 'Important',
  message: 'Please read these terms...',
  type: DialogType.info,
  icon: Icons.announcement,
);
```

---

## Common Patterns

### Delete Confirmation
```dart
final confirmed = await context.showDeleteConfirmation(
  title: 'Delete Transaction',
  message: 'This action cannot be undone.',
);
```

### Generic Confirmation
```dart
final confirmed = await context.showConfirmation(
  title: 'Logout',
  message: 'Are you sure you want to logout?',
  confirmText: 'Logout',
  isDestructive: false,
);
```

### Success Feedback
```dart
await context.showSuccessAlert(
  title: 'Transfer Complete',
  message: 'Your payment has been sent successfully.',
);
```

### Error Feedback
```dart
await context.showErrorAlert(
  title: 'Transfer Failed',
  message: error.message,
);
```

---

## Search & Replace Patterns

Use these patterns to find dialogs to migrate:

```bash
# Find AlertDialog usages
grep -r "AlertDialog(" lib/ --include="*.dart"

# Find showDialog usages
grep -r "showDialog<" lib/ --include="*.dart"

# Find showModalBottomSheet usages
grep -r "showModalBottomSheet" lib/ --include="*.dart"

# Find hardcoded background colors
grep -r "backgroundColor: AppColors\." lib/ --include="*.dart"
```

---

## Checklist for Migration

- [ ] Import new components: `import 'package:usdc_wallet/design/components/dialogs/index.dart';`
- [ ] Replace `AlertDialog` with `AppDialog`, `AlertDialog`, or `ConfirmationDialog`
- [ ] Replace `showModalBottomSheet` with `AppBottomSheet`
- [ ] Remove hardcoded `backgroundColor` - uses theme automatically
- [ ] Remove manual barrier color - uses `context.colors.scrim` automatically
- [ ] Remove manual drag handles - included in `AppBottomSheet`
- [ ] Test in both light and dark themes
- [ ] Use extensions for cleaner code: `context.showConfirmation()`, etc.

---

## Component Reference

### AppDialog
- Generic dialog with customizable content
- Static methods: `show()`, `confirm()`, `success()`, `error()`, `warning()`, `info()`

### AlertDialog
- Single-action alert (OK button only)
- Static methods: `show()`, `success()`, `error()`, `warning()`, `info()`
- Extensions: `context.showSuccessAlert()`, `context.showErrorAlert()`, etc.

### ConfirmationDialog
- Two-action dialog (confirm/cancel)
- Static method: `show()`
- Extensions: `context.showConfirmation()`, `context.showDeleteConfirmation()`
- Set `isDestructive: true` for delete actions

### AppBottomSheet
- Simple, scrollable, or full-screen bottom sheets
- Static methods: `show()`, `showScrollable()`, `showFullScreen()`
- Extensions: `context.showBottomSheet()`, `context.showScrollableBottomSheet()`, etc.
- Includes drag handle and proper theming
