# Component Library

Complete catalog of JoonaPay's reusable design system components with usage examples and API reference.

## Table of Contents

1. [Primitives](#primitives)
   - [AppButton](#appbutton)
   - [AppInput](#appinput)
   - [AppText](#apptext)
   - [AppCard](#appcard)
   - [AppSelect](#appselect)
   - [AppToggle](#apptoggle)
   - [AppSkeleton](#appskeleton)
   - [AppRefreshIndicator](#apprefreshindicator)
2. [Composed Components](#composed-components)
3. [Best Practices](#best-practices)

---

## Primitives

Basic building blocks used throughout the application.

---

### AppButton

Luxury button with gold gradient, multiple variants, and loading states.

#### Variants

```dart
enum AppButtonVariant {
  primary,      // Gold gradient background
  secondary,    // Transparent with border
  ghost,        // Text only
  success,      // Green background
  danger,       // Red background
}
```

#### Sizes

```dart
enum AppButtonSize {
  small,   // Compact (13px text)
  medium,  // Standard (15px text)
  large,   // Prominent (17px text)
}
```

#### Basic Usage

```dart
// Primary CTA
AppButton(
  label: 'Send Money',
  onPressed: () => handleSend(),
)

// Secondary action
AppButton(
  label: 'Cancel',
  variant: AppButtonVariant.secondary,
  onPressed: () => Navigator.pop(context),
)

// Ghost/text button
AppButton(
  label: 'Learn More',
  variant: AppButtonVariant.ghost,
  onPressed: () => showInfo(),
)
```

#### With Icons

```dart
// Icon on left (default)
AppButton(
  label: 'Add Money',
  icon: Icons.add_circle_outline,
  onPressed: () => addMoney(),
)

// Icon on right
AppButton(
  label: 'Continue',
  icon: Icons.arrow_forward,
  iconPosition: IconPosition.right,
  onPressed: () => continue(),
)
```

#### Loading State

```dart
// Show loading spinner
AppButton(
  label: 'Processing',
  isLoading: _isProcessing,
  onPressed: _handleSubmit,
)
```

#### Full Width

```dart
// Stretch to container width
AppButton(
  label: 'Get Started',
  isFullWidth: true,
  onPressed: () => startOnboarding(),
)
```

#### Sizes

```dart
// Small button
AppButton(
  label: 'Skip',
  size: AppButtonSize.small,
  onPressed: () => skip(),
)

// Large button
AppButton(
  label: 'Confirm',
  size: AppButtonSize.large,
  onPressed: () => confirm(),
)
```

#### Accessibility

```dart
// Custom semantic label
AppButton(
  label: 'Submit',
  semanticLabel: 'Submit transaction form',
  onPressed: () => submit(),
)

// Disable haptics
AppButton(
  label: 'Silent Action',
  enableHaptics: false,
  onPressed: () => action(),
)
```

#### API Reference

```dart
AppButton({
  required String label,            // Button text
  VoidCallback? onPressed,          // Tap handler (null = disabled)
  AppButtonVariant variant,         // Visual variant (default: primary)
  AppButtonSize size,               // Button size (default: medium)
  bool isLoading,                   // Show loading spinner (default: false)
  bool isFullWidth,                 // Stretch width (default: false)
  IconData? icon,                   // Optional icon
  IconPosition iconPosition,        // Icon placement (default: left)
  String? semanticLabel,            // Screen reader label
  bool enableHaptics,               // Haptic feedback (default: true)
})
```

---

### AppInput

Input field with labels, validation, and multiple variants.

#### Variants

```dart
enum AppInputVariant {
  standard,  // Default text input
  phone,     // Phone number (digits only)
  pin,       // PIN/OTP (digits, centered)
  amount,    // Currency amount (decimal)
  search,    // Search field
}
```

#### States

```dart
enum AppInputState {
  idle,      // Default state
  focused,   // User is typing
  filled,    // Has value
  error,     // Validation error
  disabled,  // Not editable
}
```

#### Basic Usage

```dart
final _controller = TextEditingController();

AppInput(
  label: 'Email Address',
  hint: 'you@example.com',
  controller: _controller,
)
```

#### With Validation

```dart
AppInput(
  label: 'Phone Number',
  controller: _phoneController,
  error: _phoneError, // Shows error message
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    return null;
  },
)
```

#### With Icons

```dart
// Prefix icon
AppInput(
  label: 'Search',
  hint: 'Search transactions...',
  prefixIcon: Icons.search,
  controller: _searchController,
)

// Suffix icon
AppInput(
  label: 'Password',
  obscureText: true,
  suffixIcon: Icons.visibility_off,
  controller: _passwordController,
)
```

#### Phone Variant

```dart
AppInput(
  label: 'Phone Number',
  variant: AppInputVariant.phone,
  hint: '0X XX XX XX XX',
  controller: _phoneController,
)

// Alternative: PhoneInput with country code
PhoneInput(
  label: 'Phone Number',
  controller: _phoneController,
  countryCode: '+225',
  onCountryCodeTap: () => selectCountry(),
)
```

#### Amount Variant

```dart
AppInput(
  label: 'Amount',
  variant: AppInputVariant.amount,
  hint: '0.00',
  controller: _amountController,
  // Allows decimals, centered text, mono font
)
```

#### PIN Variant

```dart
AppInput(
  label: 'PIN',
  variant: AppInputVariant.pin,
  obscureText: true,
  maxLength: 6,
  controller: _pinController,
  // Digits only, centered, mono font
)
```

#### Helper Text

```dart
AppInput(
  label: 'Amount',
  helper: 'Minimum: 100 XOF',
  controller: _amountController,
)
```

#### Read-Only

```dart
AppInput(
  label: 'Transaction ID',
  controller: _idController,
  readOnly: true,
  // User cannot edit
)
```

#### Custom Formatters

```dart
AppInput(
  label: 'Card Number',
  controller: _cardController,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(16),
  ],
)
```

#### Callbacks

```dart
AppInput(
  label: 'Amount',
  controller: _amountController,
  onChanged: (value) {
    print('Changed: $value');
  },
  onSubmitted: (value) {
    print('Submitted: $value');
    _handleSubmit();
  },
  onTap: () {
    print('Field tapped');
  },
)
```

#### API Reference

```dart
AppInput({
  TextEditingController? controller,
  FocusNode? focusNode,
  String? label,                         // Field label
  String? hint,                          // Placeholder text
  String? helper,                        // Helper text below field
  String? error,                         // Error message (shows red)
  Widget? prefix,                        // Custom prefix widget
  Widget? suffix,                        // Custom suffix widget
  IconData? prefixIcon,                  // Icon at start
  IconData? suffixIcon,                  // Icon at end
  AppInputVariant variant,               // Input type (default: standard)
  bool obscureText,                      // Hide text (default: false)
  bool enabled,                          // Allow editing (default: true)
  bool readOnly,                         // Prevent editing (default: false)
  bool autofocus,                        // Auto-focus (default: false)
  int maxLines,                          // Line count (default: 1)
  int? maxLength,                        // Character limit
  TextInputType? keyboardType,           // Keyboard type
  TextInputAction? textInputAction,      // Keyboard action button
  List<TextInputFormatter>? inputFormatters,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
  VoidCallback? onTap,
  String? Function(String?)? validator,
  String? semanticLabel,                 // Screen reader label
})

PhoneInput({
  required TextEditingController controller,
  String countryCode,                    // Default: '+225'
  VoidCallback? onCountryCodeTap,        // Country picker callback
  ValueChanged<String>? onChanged,
  String? error,
  String? label,
})
```

---

### AppText

Text component with built-in typography variants and theme support.

#### Variants

```dart
enum AppTextVariant {
  displayLarge,    // 72px Playfair Display
  displayMedium,   // 48px Playfair Display
  displaySmall,    // 36px Playfair Display
  headlineLarge,   // 32px DM Sans
  headlineMedium,  // 28px DM Sans
  headlineSmall,   // 24px DM Sans
  titleLarge,      // 22px DM Sans
  titleMedium,     // 18px DM Sans
  titleSmall,      // 16px DM Sans
  bodyLarge,       // 16px DM Sans (default)
  bodyMedium,      // 14px DM Sans
  bodySmall,       // 12px DM Sans
  labelLarge,      // 14px DM Sans Medium
  labelMedium,     // 12px DM Sans Medium
  labelSmall,      // 11px DM Sans Medium
}
```

#### Basic Usage

```dart
// Default (bodyLarge)
AppText('Hello World')

// With variant
AppText(
  'Welcome',
  variant: AppTextVariant.headlineLarge,
)

// Custom color
AppText(
  'Error message',
  color: AppColors.errorText,
)
```

#### Alignment

```dart
AppText(
  'Centered',
  textAlign: TextAlign.center,
)
```

#### Max Lines & Overflow

```dart
AppText(
  'Long text that will be truncated...',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

#### Font Weight

```dart
AppText(
  'Bold',
  fontWeight: FontWeight.w700,
)
```

#### API Reference

```dart
AppText(
  String text,                        // Text content
  {
    AppTextVariant? variant,          // Typography style (default: bodyLarge)
    Color? color,                     // Text color (defaults to theme)
    TextAlign? textAlign,             // Alignment
    int? maxLines,                    // Maximum lines
    TextOverflow? overflow,           // Overflow behavior
    FontWeight? fontWeight,           // Custom weight
  }
)
```

---

### AppCard

Card container with variants, padding, and tap handling.

#### Variants

```dart
enum AppCardVariant {
  elevated,    // Standard card with shadow
  goldAccent,  // Gold border accent
  subtle,      // Minimal styling
  glass,       // Glassmorphism effect
}
```

#### Basic Usage

```dart
AppCard(
  child: Text('Card content'),
)
```

#### Variants

```dart
// Gold accent card
AppCard(
  variant: AppCardVariant.goldAccent,
  child: Column(
    children: [
      Text('Premium Feature'),
      Text('Only for verified users'),
    ],
  ),
)

// Glass card
AppCard(
  variant: AppCardVariant.glass,
  child: BalanceWidget(),
)
```

#### Custom Padding

```dart
AppCard(
  padding: EdgeInsets.all(AppSpacing.cardPaddingLarge),
  child: Text('Large padding'),
)

// No padding
AppCard(
  padding: EdgeInsets.zero,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(AppRadius.xl),
    child: Image.network('...'),
  ),
)
```

#### Margin

```dart
AppCard(
  margin: EdgeInsets.symmetric(
    horizontal: AppSpacing.screenPadding,
    vertical: AppSpacing.md,
  ),
  child: Text('Card with margin'),
)
```

#### Tap Handling

```dart
AppCard(
  onTap: () => Navigator.push(...),
  child: ListTile(
    leading: Icon(Icons.account_circle),
    title: Text('Profile'),
    trailing: Icon(Icons.arrow_forward_ios),
  ),
)
```

#### Custom Border Radius

```dart
AppCard(
  borderRadius: AppRadius.xxl,
  child: Text('Large radius'),
)
```

#### API Reference

```dart
AppCard({
  required Widget child,
  AppCardVariant variant,             // Card style (default: elevated)
  EdgeInsetsGeometry? padding,        // Internal padding (default: 20px all)
  EdgeInsetsGeometry? margin,         // External margin
  VoidCallback? onTap,                // Tap handler (makes interactive)
  double? borderRadius,               // Corner radius (default: 16px)
})
```

---

### AppSelect

Dropdown/select component with bottom sheet UI for mobile.

#### Item Model

```dart
class AppSelectItem<T> {
  final T value;              // Item value
  final String label;         // Display text
  final IconData? icon;       // Optional icon
  final String? subtitle;     // Optional subtitle
  final bool enabled;         // Can be selected (default: true)
}
```

#### Basic Usage

```dart
final selectedCurrency = 'USD';

AppSelect<String>(
  label: 'Currency',
  items: [
    AppSelectItem(value: 'USD', label: 'US Dollar'),
    AppSelectItem(value: 'XOF', label: 'CFA Franc'),
    AppSelectItem(value: 'EUR', label: 'Euro'),
  ],
  value: selectedCurrency,
  onChanged: (value) {
    setState(() => selectedCurrency = value);
  },
)
```

#### With Icons

```dart
AppSelect<PaymentMethod>(
  label: 'Payment Method',
  items: [
    AppSelectItem(
      value: PaymentMethod.orangeMoney,
      label: 'Orange Money',
      icon: Icons.phone_android,
    ),
    AppSelectItem(
      value: PaymentMethod.mtnMomo,
      label: 'MTN Mobile Money',
      icon: Icons.phone_iphone,
    ),
  ],
  value: _selectedMethod,
  onChanged: (value) => setState(() => _selectedMethod = value),
)
```

#### With Subtitles

```dart
AppSelect<Account>(
  label: 'Account',
  items: accounts.map((acc) => AppSelectItem(
    value: acc,
    label: acc.name,
    subtitle: '${acc.balance} USDC',
    icon: Icons.account_balance_wallet,
  )).toList(),
  value: selectedAccount,
  onChanged: (value) => setState(() => selectedAccount = value),
)
```

#### With Validation

```dart
AppSelect<String>(
  label: 'Country',
  hint: 'Select your country',
  error: _countryError, // Shows error message
  items: countries,
  value: _selectedCountry,
  onChanged: (value) {
    setState(() {
      _selectedCountry = value;
      _countryError = null; // Clear error
    });
  },
)
```

#### Helper Text

```dart
AppSelect<String>(
  label: 'Network',
  helper: 'Choose your mobile money network',
  items: networks,
  value: _network,
  onChanged: (value) => setState(() => _network = value),
)
```

#### Disabled Items

```dart
AppSelect<String>(
  label: 'Option',
  items: [
    AppSelectItem(value: 'a', label: 'Option A'),
    AppSelectItem(value: 'b', label: 'Option B (Coming Soon)', enabled: false),
    AppSelectItem(value: 'c', label: 'Option C'),
  ],
  value: _option,
  onChanged: (value) => setState(() => _option = value),
)
```

#### Hide Checkmark

```dart
AppSelect<String>(
  label: 'Theme',
  showCheckmark: false, // No checkmark for selected item
  items: themes,
  value: _theme,
  onChanged: (value) => setState(() => _theme = value),
)
```

#### API Reference

```dart
AppSelect<T>({
  required List<AppSelectItem<T>> items,
  required T? value,
  required ValueChanged<T?> onChanged,
  String? label,                      // Field label
  String? hint,                       // Placeholder (default: 'Select an option')
  String? error,                      // Error message
  String? helper,                     // Helper text
  bool enabled,                       // Allow interaction (default: true)
  IconData? prefixIcon,               // Icon before selected value
  bool showCheckmark,                 // Show checkmark on selected (default: true)
})

AppSelectItem<T>({
  required T value,
  required String label,
  IconData? icon,
  String? subtitle,
  bool enabled,                       // Default: true
})
```

---

### AppToggle

Toggle switch component (coming soon - file created but not yet documented in context).

```dart
// Basic toggle
AppToggle(
  value: _isEnabled,
  onChanged: (value) => setState(() => _isEnabled = value),
)

// With label
AppToggle(
  value: _notifications,
  onChanged: (value) => setState(() => _notifications = value),
  label: 'Enable Notifications',
)
```

---

### AppSkeleton

Loading skeleton component for shimmer effects.

#### Basic Usage

```dart
// Single line skeleton
AppSkeleton(
  width: 200,
  height: 16,
)

// Card skeleton
AppSkeleton(
  width: double.infinity,
  height: 100,
  borderRadius: AppRadius.lg,
)
```

#### Shimmer Effect

```dart
// Automatic shimmer animation
AppSkeleton(
  width: 150,
  height: 20,
  // Shimmer effect is built-in
)
```

#### Common Patterns

```dart
// Text skeleton
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    AppSkeleton(width: 200, height: 24), // Title
    SizedBox(height: AppSpacing.sm),
    AppSkeleton(width: 150, height: 16), // Subtitle
    SizedBox(height: AppSpacing.xs),
    AppSkeleton(width: 180, height: 16), // Description
  ],
)

// Avatar skeleton
AppSkeleton(
  width: 48,
  height: 48,
  borderRadius: AppRadius.full, // Circle
)

// List skeleton
ListView.builder(
  itemCount: 5,
  itemBuilder: (context, index) => Padding(
    padding: EdgeInsets.only(bottom: AppSpacing.md),
    child: Row(
      children: [
        AppSkeleton(width: 48, height: 48, borderRadius: AppRadius.full),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(width: double.infinity, height: 16),
              SizedBox(height: AppSpacing.xs),
              AppSkeleton(width: 120, height: 12),
            ],
          ),
        ),
      ],
    ),
  ),
)
```

---

### AppRefreshIndicator

Custom pull-to-refresh indicator with gold accent.

#### Basic Usage

```dart
AppRefreshIndicator(
  onRefresh: () async {
    await loadData();
  },
  child: ListView(
    children: items.map((item) => ItemCard(item)).toList(),
  ),
)
```

#### API Reference

```dart
AppRefreshIndicator({
  required Future<void> Function() onRefresh,
  required Widget child,
})
```

---

## Composed Components

Complex components built from primitives (located in `lib/design/components/composed/`).

### Common Composed Components

- **BalanceCard** - Wallet balance display
- **TransactionListItem** - Transaction row
- **QuickActionButton** - Home screen action
- **BottomNavBar** - Navigation bar
- **PinEntryWidget** - PIN input grid
- **AmountInputWidget** - Currency input with formatting
- **ContactListItem** - Contact/beneficiary row
- **StatCard** - Statistics display card
- **EmptyStateWidget** - No data placeholder
- **ErrorStateWidget** - Error display

**Note:** See individual component files in `lib/design/components/composed/` for detailed documentation.

---

## Best Practices

### Component Selection

```dart
// ✅ DO: Use AppButton
AppButton(
  label: 'Submit',
  onPressed: () => submit(),
)

// ❌ DON'T: Use raw ElevatedButton
ElevatedButton(
  onPressed: () => submit(),
  child: Text('Submit'),
)
```

### Consistent Spacing

```dart
// ✅ DO: Use spacing tokens
Column(
  children: [
    AppCard(...),
    SizedBox(height: AppSpacing.lg),
    AppCard(...),
  ],
)

// ❌ DON'T: Hardcode spacing
Column(
  children: [
    AppCard(...),
    SizedBox(height: 15), // Arbitrary value
    AppCard(...),
  ],
)
```

### Typography

```dart
// ✅ DO: Use AppText with variants
AppText(
  'Title',
  variant: AppTextVariant.headlineMedium,
)

// ❌ DON'T: Use raw Text with manual styling
Text(
  'Title',
  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
)
```

### Colors

```dart
// ✅ DO: Use color tokens
Container(color: AppColors.slate)

// ❌ DON'T: Hardcode colors
Container(color: Color(0xFF1A1A1F))
```

### Accessibility

```dart
// ✅ DO: Provide semantic labels
AppButton(
  label: 'Send',
  semanticLabel: 'Send money to selected contact',
  onPressed: () => send(),
)

// ✅ DO: Use sufficient contrast
Text(
  'Important',
  style: TextStyle(color: AppColors.textPrimary), // High contrast
)
```

### Performance

```dart
// ✅ DO: Use const constructors
const AppText('Static text')

// ✅ DO: Extract controllers outside build
final _controller = TextEditingController();

@override
Widget build(BuildContext context) {
  return AppInput(controller: _controller);
}
```

---

## Component Composition

### Building Complex UIs

```dart
// Compose primitives into features
class TransferForm extends StatefulWidget {
  @override
  State<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<TransferForm> {
  final _amountController = TextEditingController();
  String? _selectedCurrency = 'USDC';

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Send Money',
            variant: AppTextVariant.titleLarge,
          ),
          SizedBox(height: AppSpacing.lg),

          AppInput(
            label: 'Amount',
            variant: AppInputVariant.amount,
            controller: _amountController,
            hint: '0.00',
          ),
          SizedBox(height: AppSpacing.lg),

          AppSelect<String>(
            label: 'Currency',
            items: [
              AppSelectItem(value: 'USDC', label: 'USDC'),
              AppSelectItem(value: 'XOF', label: 'XOF'),
            ],
            value: _selectedCurrency,
            onChanged: (value) => setState(() => _selectedCurrency = value),
          ),
          SizedBox(height: AppSpacing.xl),

          AppButton(
            label: 'Continue',
            isFullWidth: true,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    // Handle form submission
  }
}
```

---

## Related

- [Colors](./colors.md) - Color system and tokens
- [Typography](./typography.md) - Text styles
- [Spacing](./spacing.md) - Layout and spacing
- [Source Code](../../lib/design/components/) - Component implementations
