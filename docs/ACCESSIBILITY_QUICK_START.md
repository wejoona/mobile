# Accessibility Quick Start Guide

> For developers building accessible features in JoonaPay Mobile

## Overview

This quick reference helps you build accessible features from the start. Follow these guidelines for every screen and component you create.

---

## The Golden Rules

### 1. Semantic Labels for Everything

**All interactive elements MUST have semantic labels.**

```dart
// Good
AppButton(
  label: 'Send Money',
  semanticLabel: 'Send money to recipient', // Context
  onPressed: () {},
)

// Bad
GestureDetector(
  onTap: () {},
  child: Icon(Icons.send), // No label!
)

// Fix
Semantics(
  label: 'Send money',
  button: true,
  onTap: () {},
  child: Icon(Icons.send),
)
```

### 2. Touch Targets Minimum 44x44dp

**All tappable elements must meet minimum size.**

```dart
// Good - Meets minimum
AppButton(
  label: 'Continue',
  // Minimum height: 48dp ✓
)

// Bad - Too small
IconButton(
  icon: Icon(Icons.close, size: 16),
  padding: EdgeInsets.all(4), // Total: 24x24 ✗
)

// Fix - Add padding
IconButton(
  icon: Icon(Icons.close, size: 16),
  padding: EdgeInsets.all(14), // Total: 44x44 ✓
  constraints: BoxConstraints(minWidth: 44, minHeight: 44),
)
```

### 3. Contrast Ratios

**Text must meet WCAG AA contrast requirements.**

| Text Type | Minimum Ratio |
|-----------|---------------|
| Normal text | 4.5:1 |
| Large text (18pt+) | 3:1 |
| UI components | 3:1 |

```dart
// Good - Uses design tokens with verified contrast
AppText(
  'Welcome',
  color: AppColors.textPrimary, // 14.7:1 ratio ✓
)

// Bad - Custom color without verification
Text(
  'Welcome',
  style: TextStyle(color: Color(0xFF666666)), // Unknown ratio ✗
)
```

### 4. State Changes Announced

**Visual changes must be announced to screen readers.**

```dart
// Good - Loading state announced
AppButton(
  label: 'Submit',
  isLoading: isLoading, // Announces "Loading, please wait"
  onPressed: _submit,
)

// Bad - Silent state change
if (isLoading)
  CircularProgressIndicator() // No announcement ✗
else
  ElevatedButton(...)

// Fix - Add semantics
Semantics(
  label: isLoading ? 'Loading, please wait' : 'Submit',
  child: isLoading ? CircularProgressIndicator() : ElevatedButton(...),
)
```

### 5. Errors Clearly Identified

**Errors must be visible AND announced.**

```dart
// Good - Error announced
AppInput(
  label: 'Email',
  error: 'Invalid email address', // Announced to screen reader
)

// Bad - Visual only
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red), // Color only ✗
    ),
  ),
)

// Fix - Add error text
TextField(
  decoration: InputDecoration(
    errorText: 'Invalid email address', // Announced ✓
  ),
)
```

---

## Component Checklist

Use this checklist for every component you create:

### Buttons

- [ ] Has semantic label (via `label` or `semanticLabel`)
- [ ] Announces loading state if applicable
- [ ] Announces disabled state
- [ ] Minimum 44x44dp touch target
- [ ] Text contrast meets 4.5:1
- [ ] Has visible focus indicator
- [ ] Provides haptic feedback

```dart
AppButton(
  label: 'Continue', // ✓ Label
  semanticLabel: 'Continue to payment', // ✓ Context
  isLoading: state.isLoading, // ✓ State
  onPressed: state.canSubmit ? _submit : null, // ✓ Disabled
  // ✓ Component enforces 48dp height
  // ✓ Colors verified in design system
  // ✓ Focus built in
  // ✓ Haptic on InkWell
)
```

### Text Inputs

- [ ] Has label or placeholder
- [ ] Helper text for complex fields
- [ ] Error messages announced
- [ ] Minimum 44dp height
- [ ] Label contrast meets 4.5:1
- [ ] Focus indicator visible
- [ ] Input purpose identified (keyboardType)

```dart
AppInput(
  label: 'Email address', // ✓ Label
  hint: 'example@email.com', // ✓ Placeholder
  helper: 'We\'ll send a confirmation email', // ✓ Helper
  error: state.emailError, // ✓ Error
  keyboardType: TextInputType.emailAddress, // ✓ Purpose
  // ✓ Component enforces 56dp height
  // ✓ Colors verified
  // ✓ Focus built in
)
```

### Cards

- [ ] Entire card tappable (if interactive)
- [ ] Announces card content logically
- [ ] Focus indicator if tappable
- [ ] Contrast for borders/shadows

```dart
AppCard(
  onTap: () => _openDetails(), // ✓ Entire card tappable
  child: Semantics(
    label: 'Transaction: Sent 5,000 XOF to Amadou, January 29', // ✓ Summary
    child: Column(
      children: [
        // Card content with ExcludeSemantics on decorative elements
      ],
    ),
  ),
)
```

### Images

- [ ] Decorative images excluded from semantics
- [ ] Informative images have alt text
- [ ] Icons have semantic labels

```dart
// Decorative
ExcludeSemantics(
  child: Image.asset('assets/decorative_pattern.png'),
)

// Informative
Semantics(
  label: 'Profile picture of Amadou Diallo',
  image: true,
  child: CircleAvatar(
    backgroundImage: NetworkImage(user.photoUrl),
  ),
)

// Icon
Semantics(
  label: 'Success',
  child: Icon(Icons.check_circle, color: AppColors.success),
)
```

### Lists

- [ ] Proper reading order
- [ ] List semantics (if applicable)
- [ ] Empty state announced
- [ ] Loading state announced

```dart
// Good
Semantics(
  label: 'Recent transactions, ${transactions.length} items',
  child: ListView.builder(
    itemCount: transactions.length,
    itemBuilder: (context, index) {
      return TransactionCard(
        transaction: transactions[index],
        // Each card has proper semantics
      );
    },
  ),
)

// Empty state
if (transactions.isEmpty)
  Semantics(
    label: 'No transactions yet',
    child: EmptyStateWidget(),
  )
```

### Dialogs / Bottom Sheets

- [ ] Title announced
- [ ] Dismissible with gestures
- [ ] Focus trapped appropriately
- [ ] Result announced

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: AppText('Confirm Delete'), // ✓ Title
    content: AppText('Are you sure...'), // ✓ Content
    actions: [
      TextButton(
        child: AppText('Cancel'),
        onPressed: () => Navigator.pop(context, false),
      ),
      AppButton(
        label: 'Delete',
        variant: AppButtonVariant.danger,
        onPressed: () => Navigator.pop(context, true),
      ),
    ],
  ),
).then((confirmed) {
  if (confirmed) {
    // Announce result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item deleted')), // ✓ Announced
    );
  }
});
```

---

## Screen Checklist

For every screen you create:

### Structure

- [ ] Screen title set (AppBar or Semantics)
- [ ] Logical heading hierarchy
- [ ] Focusable elements in visual order
- [ ] No keyboard traps

```dart
Scaffold(
  appBar: AppBar(
    title: AppText('Send Money'), // ✓ Screen title
  ),
  body: SafeArea(
    child: Column(
      children: [
        // Elements in logical order
      ],
    ),
  ),
)
```

### Content

- [ ] All text scales to 200%
- [ ] No horizontal scrolling at any scale
- [ ] All images have alt text or excluded
- [ ] Color not sole indicator of meaning

### Interactions

- [ ] All actions accessible via screen reader
- [ ] Form validation errors announced
- [ ] Success/failure states announced
- [ ] Loading states announced

### Testing

- [ ] Tested with TalkBack (Android)
- [ ] Tested with VoiceOver (iOS)
- [ ] Tested at 200% text scale
- [ ] Tested with reduced motion enabled

---

## Common Patterns

### Loading States

```dart
// Pattern: Announce loading, maintain focus
class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      await api.submit();
      // Announce success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submitted successfully')),
      );
    } catch (e) {
      // Announce error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Submit',
      isLoading: _isLoading, // Handles announcement
      onPressed: _submit,
    );
  }
}
```

### Form Validation

```dart
// Pattern: Real-time validation with announcements
class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _emailError;

  void _validateEmail(String value) {
    setState(() {
      _emailError = Validators.email(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppInput(
            label: 'Email',
            onChanged: _validateEmail,
            error: _emailError, // Announced when set
          ),
          AppButton(
            label: 'Continue',
            onPressed: _emailError == null ? _submit : null,
          ),
        ],
      ),
    );
  }
}
```

### Conditional Rendering

```dart
// Pattern: Announce state changes
Widget build(BuildContext context) {
  if (isLoading) {
    return Semantics(
      label: 'Loading transactions, please wait',
      child: Center(child: CircularProgressIndicator()),
    );
  }

  if (hasError) {
    return Semantics(
      label: 'Error loading transactions: ${error.message}',
      child: ErrorWidget(error: error),
    );
  }

  if (items.isEmpty) {
    return Semantics(
      label: 'No transactions yet',
      child: EmptyStateWidget(),
    );
  }

  return Semantics(
    label: '${items.length} transactions',
    child: ListView.builder(...),
  );
}
```

### Toggles / Switches

```dart
// Pattern: Announce state changes
Switch(
  value: isEnabled,
  onChanged: (value) {
    setState(() => isEnabled = value);

    // Announce change
    final message = value ? 'Notifications enabled' : 'Notifications disabled';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 1),
      ),
    );
  },
)

// Or use Semantics wrapper
Semantics(
  label: 'Notifications',
  value: isEnabled ? 'Enabled' : 'Disabled',
  toggled: isEnabled,
  onTap: () {
    setState(() => isEnabled = !isEnabled);
  },
  child: Switch(value: isEnabled, onChanged: (v) => setState(() => isEnabled = v)),
)
```

---

## Tools & Testing

### Flutter Semantics Debugger

```dart
// Enable in main.dart
MaterialApp(
  debugShowMaterialGrid: false,
  showSemanticsDebugger: true, // Enable this
  // ...
)
```

Or enable at runtime:
```dart
// In widget
WidgetsBinding.instance.ensureSemantics();
```

### Widget Tests

```dart
testWidgets('Button is accessible', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AppButton(
          label: 'Continue',
          onPressed: () {},
        ),
      ),
    ),
  );

  // Check semantic label
  expect(find.bySemanticsLabel('Continue'), findsOneWidget);

  // Check button role
  final semantics = tester.getSemantics(find.byType(AppButton));
  expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);

  // Check touch target
  await AccessibilityTestHelper.checkTouchTargets(tester);
});
```

### Manual Testing

1. **Enable TalkBack (Android)**
   - Settings > Accessibility > TalkBack
   - Test entire flow

2. **Enable VoiceOver (iOS)**
   - Settings > Accessibility > VoiceOver
   - Test entire flow

3. **Test Text Scaling**
   - Set to 200%
   - Verify no clipping

4. **Test Reduced Motion**
   - Enable setting
   - Verify animations disabled

---

## Resources

### Documentation

- [ACCESSIBILITY_COMPLIANCE.md](./ACCESSIBILITY_COMPLIANCE.md) - Full compliance guide
- [SCREEN_READER_TESTING.md](./SCREEN_READER_TESTING.md) - Testing procedures
- [DYNAMIC_TYPE_GUIDE.md](./DYNAMIC_TYPE_GUIDE.md) - Text scaling guide

### Helpers

- `AccessibilityTestHelper` - Automated test utilities
- `ReducedMotionHelper` - Motion preference support
- `AppFocusBorder` - Focus indicator component

### Design Tokens

All verified for accessibility:
- `AppColors` - Contrast ratios verified
- `AppTypography` - Scales automatically
- `AppSpacing` - Adequate touch targets

---

## Quick Fixes for Common Issues

### Issue: "Button announces as just 'Button'"

**Fix:** Add semantic label
```dart
// Before
ElevatedButton(
  child: Icon(Icons.send),
  onPressed: () {},
)

// After
Semantics(
  label: 'Send money',
  button: true,
  child: ElevatedButton(
    child: Icon(Icons.send),
    onPressed: () {},
  ),
)

// Better - Use AppButton
AppButton(
  label: 'Send',
  icon: Icons.send,
  semanticLabel: 'Send money',
  onPressed: () {},
)
```

### Issue: "Touch target too small"

**Fix:** Add padding or constraints
```dart
// Before
IconButton(
  icon: Icon(Icons.close, size: 16),
  onPressed: () {},
)

// After
IconButton(
  icon: Icon(Icons.close, size: 16),
  constraints: BoxConstraints(minWidth: 44, minHeight: 44),
  onPressed: () {},
)
```

### Issue: "Error not announced"

**Fix:** Use error property
```dart
// Before
Container(
  decoration: BoxDecoration(
    border: Border.all(color: hasError ? Colors.red : Colors.grey),
  ),
  child: TextField(),
)

// After
TextField(
  decoration: InputDecoration(
    errorText: hasError ? 'Invalid input' : null,
  ),
)
```

### Issue: "Loading state silent"

**Fix:** Use AppButton or add semantics
```dart
// Before
if (isLoading)
  CircularProgressIndicator()
else
  ElevatedButton(...)

// After
AppButton(
  label: 'Submit',
  isLoading: isLoading,
  onPressed: _submit,
)
```

### Issue: "Text clips at 200% scale"

**Fix:** Remove fixed height, add maxLines
```dart
// Before
Container(
  height: 60,
  child: Text('Long text...'),
)

// After
Container(
  constraints: BoxConstraints(minHeight: 60),
  child: Text(
    'Long text...',
    maxLines: 3,
    overflow: TextOverflow.ellipsis,
  ),
)
```

---

## Pre-Commit Checklist

Before submitting a PR:

- [ ] All interactive elements have semantic labels
- [ ] Touch targets meet 44x44dp minimum
- [ ] Colors use design tokens (verified contrast)
- [ ] State changes are announced
- [ ] Errors are clearly identified
- [ ] Text scales to 200% without clipping
- [ ] Tested with screen reader
- [ ] Accessibility tests pass

```bash
# Run accessibility tests
flutter test test/accessibility/

# Run with semantics debugger
flutter run --enable-asserts --debug
```

---

**Last Updated:** 2026-01-29

**Questions?** Check [ACCESSIBILITY_COMPLIANCE.md](./ACCESSIBILITY_COMPLIANCE.md) or ask the team.
