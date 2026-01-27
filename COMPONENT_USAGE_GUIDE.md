# Component Usage Guide

## AppInput - Enhanced Input Field

### Basic Usage
```dart
AppInput(
  label: 'Email',
  hint: 'Enter your email',
  controller: emailController,
  variant: AppInputVariant.standard,
)
```

### All Variants
```dart
// Standard text input
AppInput(variant: AppInputVariant.standard)

// Phone number input (digits only)
AppInput(variant: AppInputVariant.phone)

// PIN input (centered, monospace)
AppInput(variant: AppInputVariant.pin)

// Amount input (decimal support, centered)
AppInput(variant: AppInputVariant.amount)

// Search input
AppInput(variant: AppInputVariant.search)
```

### State Examples
```dart
// Error state
AppInput(
  label: 'Password',
  error: 'Password must be at least 8 characters',
  controller: passwordController,
)

// Disabled state
AppInput(
  label: 'Phone',
  enabled: false,
  controller: phoneController,
)

// With icons
AppInput(
  label: 'Search',
  prefixIcon: Icons.search,
  suffixIcon: Icons.close,
)

// With helper text
AppInput(
  label: 'Username',
  helper: 'Choose a unique username',
)
```

### Visual States (Automatic)
- **Idle**: Default gray border, standard background
- **Focused**: Gold border (2px), label turns gold
- **Filled**: Subtle background tint when text entered
- **Error**: Red border, red label, error message below
- **Disabled**: Muted colors, no interaction

---

## AppButton - Enhanced Button

### Basic Usage
```dart
AppButton(
  label: 'Continue',
  onPressed: () => handleContinue(),
)
```

### All Variants
```dart
// Primary (gold gradient)
AppButton(
  label: 'Sign In',
  variant: AppButtonVariant.primary,
  onPressed: onSignIn,
)

// Secondary (outlined)
AppButton(
  label: 'Cancel',
  variant: AppButtonVariant.secondary,
  onPressed: onCancel,
)

// Ghost (text only)
AppButton(
  label: 'Skip',
  variant: AppButtonVariant.ghost,
  onPressed: onSkip,
)

// Success
AppButton(
  label: 'Confirm',
  variant: AppButtonVariant.success,
  onPressed: onConfirm,
)

// Danger
AppButton(
  label: 'Delete',
  variant: AppButtonVariant.danger,
  onPressed: onDelete,
)
```

### Button Sizes
```dart
// Small
AppButton(
  label: 'OK',
  size: AppButtonSize.small,
)

// Medium (default)
AppButton(
  label: 'Submit',
  size: AppButtonSize.medium,
)

// Large
AppButton(
  label: 'Get Started',
  size: AppButtonSize.large,
  isFullWidth: true,
)
```

### Advanced Features
```dart
// With icon
AppButton(
  label: 'Send Money',
  icon: Icons.send,
  iconPosition: IconPosition.left,
  onPressed: onSend,
)

// Full width
AppButton(
  label: 'Create Account',
  isFullWidth: true,
  onPressed: onCreate,
)

// Loading state
AppButton(
  label: 'Processing...',
  isLoading: true,
  onPressed: null, // Disabled while loading
)

// Long text (auto-truncates)
AppButton(
  label: 'This is a very long button label that will be truncated',
  isFullWidth: true,
  onPressed: onPress,
)
```

---

## Theme Switcher

### Location
Settings > Preferences > Theme

### Options
1. **Light** - Always use light theme
2. **Dark** - Always use dark theme (default)
3. **System** - Follow device theme setting

### Programmatic Usage
```dart
// Get current theme
final themeState = ref.watch(themeProvider);

// Set theme
ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.dark);

// Toggle between light/dark (ignores system)
ref.read(themeProvider.notifier).toggleTheme();

// Get theme data based on mode
final theme = themeState.getTheme(MediaQuery.of(context).platformBrightness);

// Check if dark mode
final isDark = themeState.isDark(MediaQuery.of(context).platformBrightness);
```

---

## Color System Reference

### Primary Colors
```dart
AppColors.gold500       // Primary gold accent
AppColors.obsidian      // Main background
AppColors.graphite      // Elevated surfaces
AppColors.slate         // Cards
AppColors.elevated      // Inputs, hover states
```

### Text Colors
```dart
AppColors.textPrimary   // High emphasis
AppColors.textSecondary // Medium emphasis
AppColors.textTertiary  // Low emphasis
AppColors.textDisabled  // Disabled state
AppColors.textInverse   // On gold/light backgrounds
```

### Semantic Colors
```dart
// Success
AppColors.successBase
AppColors.successText

// Warning
AppColors.warningBase
AppColors.warningText

// Error
AppColors.errorBase
AppColors.errorText

// Info
AppColors.infoBase
AppColors.infoText
```

### Borders
```dart
AppColors.borderSubtle      // 6% white
AppColors.borderDefault     // 10% white
AppColors.borderStrong      // 15% white
AppColors.borderGold        // 30% gold
AppColors.borderGoldStrong  // 50% gold
```

---

## Spacing System (8pt Grid)

```dart
AppSpacing.xxs      // 2px
AppSpacing.xs       // 4px
AppSpacing.sm       // 8px   ← Base unit
AppSpacing.md       // 12px
AppSpacing.lg       // 16px
AppSpacing.xl       // 20px
AppSpacing.xxl      // 24px
AppSpacing.xxxl     // 32px
AppSpacing.huge     // 40px
AppSpacing.massive  // 48px
AppSpacing.giant    // 64px

// Semantic spacing
AppSpacing.screenPadding    // 20px
AppSpacing.cardPadding      // 20px
AppSpacing.sectionGap       // 24px
```

---

## Border Radius System

```dart
AppRadius.xs    // 4px  - Subtle
AppRadius.sm    // 6px  - Small elements
AppRadius.md    // 8px  - Default (buttons, inputs)
AppRadius.lg    // 12px - Cards
AppRadius.xl    // 16px - Large cards
AppRadius.xxl   // 20px - Modals
AppRadius.xxxl  // 24px - Hero elements
AppRadius.full  // 9999 - Pills, avatars
```

---

## Typography System

### Display (Playfair Display)
```dart
AppTypography.displayLarge   // 72px, bold
AppTypography.displayMedium  // 48px, bold
AppTypography.displaySmall   // 36px, semibold
```

### Headlines (DM Sans)
```dart
AppTypography.headlineLarge  // 32px, semibold
AppTypography.headlineMedium // 28px, semibold
AppTypography.headlineSmall  // 24px, semibold
```

### Titles (DM Sans)
```dart
AppTypography.titleLarge     // 22px, semibold
AppTypography.titleMedium    // 18px, medium
AppTypography.titleSmall     // 16px, medium
```

### Body (DM Sans)
```dart
AppTypography.bodyLarge      // 16px, regular
AppTypography.bodyMedium     // 14px, regular
AppTypography.bodySmall      // 12px, regular
```

### Labels (DM Sans)
```dart
AppTypography.labelLarge     // 14px, medium
AppTypography.labelMedium    // 12px, medium
AppTypography.labelSmall     // 11px, medium
```

### Monospace (JetBrains Mono)
```dart
AppTypography.monoLarge      // 24px - Amounts
AppTypography.monoMedium     // 16px - Codes
AppTypography.monoSmall      // 12px - Small numbers
```

### Special
```dart
AppTypography.balanceDisplay // 42px - Balance amounts
AppTypography.button         // 16px, semibold
AppTypography.cardLabel      // 13px, medium
```

---

## Best Practices

### Input Fields
1. Always provide a `label` for accessibility
2. Use appropriate `variant` for the data type
3. Show `helper` text for complex fields
4. Display `error` messages below field
5. Handle `onChanged` for real-time validation

### Buttons
1. Use `primary` for main actions
2. Use `secondary` for cancel/back actions
3. Set `isFullWidth: true` for bottom CTAs
4. Show `isLoading: true` during async operations
5. Keep labels concise (max 2-3 words)

### Theme
1. Test components in both light and dark modes
2. Use semantic colors (success/error/warning)
3. Maintain 4.5:1 contrast ratio minimum
4. Respect user's system theme preference

### Spacing
1. Use consistent spacing from `AppSpacing`
2. Follow 8pt grid system
3. Group related elements with smaller gaps
4. Separate sections with larger gaps

---

## Common Patterns

### Form Layout
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    AppInput(
      label: 'Email',
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
    ),
    const SizedBox(height: AppSpacing.md),
    AppInput(
      label: 'Password',
      controller: passwordController,
      obscureText: true,
      error: passwordError,
    ),
    const SizedBox(height: AppSpacing.xl),
    AppButton(
      label: 'Sign In',
      isFullWidth: true,
      isLoading: isLoading,
      onPressed: onSignIn,
    ),
  ],
)
```

### Settings Tile
```dart
_SettingsTile(
  icon: Icons.notifications,
  title: 'Notifications',
  subtitle: 'Enabled',
  onTap: () => context.push('/settings/notifications'),
)
```

### Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    backgroundColor: AppColors.slate,
    title: const AppText(
      'Confirm Action',
      variant: AppTextVariant.titleMedium,
    ),
    content: const AppText(
      'Are you sure?',
      variant: AppTextVariant.bodyMedium,
      color: AppColors.textSecondary,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const AppText('Cancel'),
      ),
      AppButton(
        label: 'Confirm',
        size: AppButtonSize.small,
        onPressed: onConfirm,
      ),
    ],
  ),
)
```
