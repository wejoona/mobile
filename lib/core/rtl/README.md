# RTL (Right-to-Left) Support - Developer Guide

Quick reference for building RTL-compatible layouts in JoonaPay mobile app.

## Quick Start

```dart
import 'package:usdc_wallet/core/rtl/rtl_support.dart';

// Check if RTL
if (context.isRTL) {
  // RTL-specific logic
}

// Use directional padding
Container(
  padding: RTLSupport.paddingStart(16.0),
  child: Text('Hello'),
)

// Use directional alignment
Align(
  alignment: context.alignStart,
  child: Text('Aligned text'),
)
```

## Common Replacements

### Padding

| ❌ Don't Use | ✅ Use Instead |
|--------------|----------------|
| `EdgeInsets.only(left: x)` | `EdgeInsetsDirectional.only(start: x)` |
| `EdgeInsets.only(right: x)` | `EdgeInsetsDirectional.only(end: x)` |
| `padding: EdgeInsets.fromLTRB(l,t,r,b)` | `padding: EdgeInsetsDirectional.fromSTEB(s,t,e,b)` |

### Alignment

| ❌ Don't Use | ✅ Use Instead |
|--------------|----------------|
| `Alignment.centerLeft` | `AlignmentDirectional.centerStart` |
| `Alignment.centerRight` | `AlignmentDirectional.centerEnd` |
| `Alignment.topLeft` | `AlignmentDirectional.topStart` |
| `Alignment.bottomRight` | `AlignmentDirectional.bottomEnd` |

### Text Alignment

| ❌ Don't Use | ✅ Use Instead |
|--------------|----------------|
| `TextAlign.left` | `TextAlign.start` |
| `TextAlign.right` | `TextAlign.end` |
| `textAlign: TextAlign.left` | `textAlign: context.textAlignStart` |

### Icons

| ❌ Don't Use | ✅ Use Instead |
|--------------|----------------|
| `Icons.arrow_forward` | `RTLSupport.arrowForward(context)` |
| `Icons.arrow_back` | `RTLSupport.arrowBack(context)` |
| `Icons.chevron_right` | `context.isRTL ? Icons.chevron_left : Icons.chevron_right` |

## RTL-Aware Widgets

### DirectionalRow
Auto-reverses children in RTL mode:

```dart
DirectionalRow(
  children: [
    Icon(Icons.person),
    SizedBox(width: 8),
    Text('Profile'),
  ],
)
// In RTL: Text - Icon (reversed)
```

### DirectionalListTile
Swaps leading/trailing icons:

```dart
DirectionalListTile(
  leading: Icon(Icons.settings),
  trailing: Icon(Icons.chevron_right),
  title: Text('Settings'),
)
// In RTL: chevron_right appears on left
```

### DirectionalIconButton
Uses different icons for LTR/RTL:

```dart
DirectionalIconButton(
  ltrIcon: Icons.arrow_forward,
  rtlIcon: Icons.arrow_back,
  onPressed: () => goNext(),
)
```

## Extension Methods

```dart
// Available on BuildContext:
context.isRTL              // bool
context.textDirection      // TextDirection
context.alignStart         // AlignmentDirectional
context.alignEnd           // AlignmentDirectional
context.textAlignStart     // TextAlign
context.textAlignEnd       // TextAlign
```

## Common Patterns

### Pattern: Icon + Text Button

```dart
// ❌ WRONG
Row(
  children: [
    Icon(Icons.send),
    SizedBox(width: 8),
    Text('Send'),
  ],
)

// ✅ CORRECT
DirectionalRow(
  children: [
    Icon(Icons.send),
    SizedBox(width: 8),
    Text('Send'),
  ],
)
```

### Pattern: Form Field with Label

```dart
// ❌ WRONG
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('Name'),
    TextField(),
  ],
)

// ✅ CORRECT
Column(
  crossAxisAlignment: context.isRTL
    ? CrossAxisAlignment.end
    : CrossAxisAlignment.start,
  children: [
    Text('Name'),
    TextField(),
  ],
)
```

### Pattern: Leading/Trailing in Lists

```dart
// ❌ WRONG
Container(
  child: Row(
    children: [
      Icon(Icons.notification),
      Spacer(),
      Switch(value: true),
    ],
  ),
)

// ✅ CORRECT
DirectionalRow(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Icon(Icons.notification),
    Switch(value: true),
  ],
)
```

### Pattern: Absolute Positioning

```dart
// ❌ WRONG
Positioned(
  left: 16,
  top: 20,
  child: Icon(Icons.close),
)

// ✅ CORRECT
Positioned(
  left: context.isRTL ? null : 16,
  right: context.isRTL ? 16 : null,
  top: 20,
  child: Icon(Icons.close),
)
```

## Testing

### Visual Test

```dart
// Switch to Arabic in settings to test
// Or force RTL in debug:
MaterialApp(
  locale: Locale('ar'),
  // ...
)
```

### Unit Test

```dart
testWidgets('Widget is RTL-compatible', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('ar'),
      home: MyWidget(),
    ),
  );

  final context = tester.element(find.byType(MyWidget));
  expect(RTLSupport.isRTL(context), true);
});
```

## Exceptions

### When NOT to use RTL

1. **Numbers:** Always LTR
   ```dart
   Text('123456', textDirection: TextDirection.ltr)
   ```

2. **Phone Numbers:** Always LTR
   ```dart
   AppInput(
     keyboardType: TextInputType.phone,
     textDirection: TextDirection.ltr, // Force LTR
   )
   ```

3. **URLs/Emails:** Always LTR
   ```dart
   Text('support@joonapay.com', textDirection: TextDirection.ltr)
   ```

4. **Brand Names:** Keep original direction
   ```dart
   Text('JoonaPay', textDirection: TextDirection.ltr)
   ```

## Checklist for New Screens

- [ ] No hardcoded `left` or `right` in EdgeInsets
- [ ] No hardcoded `Alignment.centerLeft/Right`
- [ ] Icons use `RTLSupport` helpers
- [ ] `CrossAxisAlignment.start` instead of `.start` where directional
- [ ] Test with Arabic locale
- [ ] Verify with screen reader

## Resources

- Full audit: `/mobile/RTL_AUDIT_AND_MIGRATION.md`
- Utilities: `/mobile/lib/core/rtl/rtl_support.dart`
- Flutter docs: https://docs.flutter.dev/development/accessibility-and-localization/internationalization#bidirectional-support

## Questions?

Check the migration guide or ask in #mobile-dev Slack channel.
