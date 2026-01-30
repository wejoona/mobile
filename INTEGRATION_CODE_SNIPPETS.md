# Quick Integration Code Snippets

## 1. Add Routes to app_router.dart

Add these imports at the top:
```dart
import '../features/onboarding/views/enhanced_onboarding_view.dart';
import '../features/onboarding/views/welcome_post_login_view.dart';
import '../features/onboarding/views/help/usdc_explainer_view.dart';
import '../features/onboarding/views/help/deposits_guide_view.dart';
import '../features/onboarding/views/help/fees_transparency_view.dart';
```

Add these routes in your routes list:
```dart
// Enhanced onboarding
GoRoute(
  path: '/onboarding/enhanced',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context,
    state,
    const EnhancedOnboardingView(),
  ),
),

// Welcome screen
GoRoute(
  path: '/welcome-post-login',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context,
    state,
    const WelcomePostLoginView(),
  ),
),

// Help screens
GoRoute(
  path: '/help/usdc',
  pageBuilder: (context, state) => AppPageTransitions.slideLeft(
    context,
    state,
    const UsdcExplainerView(),
  ),
),
GoRoute(
  path: '/help/deposits',
  pageBuilder: (context, state) => AppPageTransitions.slideLeft(
    context,
    state,
    const DepositsGuideView(),
  ),
),
GoRoute(
  path: '/help/fees',
  pageBuilder: (context, state) => AppPageTransitions.slideLeft(
    context,
    state,
    const FeesTransparencyView(),
  ),
),
```

## 2. Update Splash Screen Navigation

File: `/lib/features/splash/views/splash_view.dart`

Add import:
```dart
import '../../onboarding/providers/onboarding_progress_provider.dart';
```

Modify navigation logic:
```dart
Future<void> _checkAuthAndNavigate() async {
  // ... existing auth check code ...

  if (!isAuthenticated) {
    // Check if user has seen onboarding
    final hasSeenTutorial = ref.read(
      onboardingProgressProvider.select((s) => s.hasSeenTutorial)
    );

    if (!hasSeenTutorial) {
      context.go('/onboarding/enhanced');
    } else {
      context.go('/login');
    }
  } else {
    context.go('/home');
  }
}
```

## 3. Update Auth Flow for Welcome Screen

File: `/lib/features/auth/providers/auth_provider.dart`

After successful registration and PIN setup:
```dart
import '../../../features/onboarding/providers/onboarding_progress_provider.dart';

// In your registration success handler
Future<void> _handleRegistrationSuccess() async {
  // Mark first login
  await ref.read(onboardingProgressProvider.notifier).setFirstLogin();

  // Navigate to welcome screen
  if (mounted) {
    context.go('/welcome-post-login');
  }
}

// For returning users
Future<void> _handleLoginSuccess() async {
  if (mounted) {
    context.go('/home');
  }
}
```

## 4. Add First Deposit Prompt to Home Screen

File: `/lib/features/wallet/views/wallet_home_screen.dart`

Add imports:
```dart
import '../../onboarding/widgets/first_deposit_prompt.dart';
import '../../onboarding/providers/onboarding_progress_provider.dart';
```

In your build method, after existing banners:
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // ... existing code ...

  return Scaffold(
    body: Column(
      children: [
        // ... existing content ...

        // Add after KYC banner, before transactions
        const FirstDepositPrompt(),

        // ... rest of content ...
      ],
    ),
  );
}
```

## 5. Track Deposit Completion

File: `/lib/features/deposit/views/deposit_status_screen.dart` (or wherever deposit success is handled)

Add import:
```dart
import '../../onboarding/providers/onboarding_progress_provider.dart';
```

In deposit success handler:
```dart
Future<void> _handleDepositSuccess() async {
  // Mark first deposit completed
  final progress = ref.read(onboardingProgressProvider);
  if (!progress.hasCompletedFirstDeposit) {
    await ref.read(onboardingProgressProvider.notifier)
      .markFirstDepositCompleted();

    // Show KYC prompt if appropriate
    if (progress.shouldShowKycPrompt) {
      _showKycPrompt();
    }
  }

  // ... rest of success handling ...
}

void _showKycPrompt() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: context.colors.surface,
      title: AppText(
        l10n.kyc_prompt_title,
        variant: AppTextVariant.titleMedium,
      ),
      content: AppText(
        l10n.kyc_prompt_message,
        variant: AppTextVariant.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(onboardingProgressProvider.notifier).markKycPromptSeen();
            Navigator.pop(context);
          },
          child: AppText(l10n.action_skip),
        ),
        AppButton(
          label: l10n.kyc_start,
          onPressed: () {
            ref.read(onboardingProgressProvider.notifier).markKycPromptSeen();
            Navigator.pop(context);
            context.push('/kyc');
          },
          size: AppButtonSize.small,
        ),
      ],
    ),
  );
}
```

## 6. Add Help Menu to App Bar

File: `/lib/features/wallet/views/wallet_home_screen.dart`

Add help icon to app bar:
```dart
Scaffold(
  appBar: AppBar(
    actions: [
      IconButton(
        icon: Icon(Icons.help_outline_rounded),
        onPressed: () => _showHelpMenu(context),
      ),
    ],
  ),
  // ... rest of scaffold ...
)
```

Add help menu method:
```dart
void _showHelpMenu(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final colors = context.colors;

  showModalBottomSheet(
    context: context,
    backgroundColor: colors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.xl),
      ),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: AppSpacing.md),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: AppText(
              l10n.help_title,
              variant: AppTextVariant.titleMedium,
            ),
          ),

          // Help options
          _buildHelpOption(
            context,
            Icons.account_balance_rounded,
            l10n.help_whatIsUsdc,
            () => context.push('/help/usdc'),
          ),
          _buildHelpOption(
            context,
            Icons.arrow_downward_rounded,
            l10n.help_howDepositsWork,
            () => context.push('/help/deposits'),
          ),
          _buildHelpOption(
            context,
            Icons.receipt_rounded,
            l10n.help_transactionFees,
            () => context.push('/help/fees'),
          ),

          SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}

Widget _buildHelpOption(
  BuildContext context,
  IconData icon,
  String title,
  VoidCallback onTap,
) {
  final colors = context.colors;

  return ListTile(
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: colors.gold, size: 20),
    ),
    title: AppText(title, variant: AppTextVariant.bodyLarge),
    trailing: Icon(Icons.chevron_right_rounded, color: colors.textTertiary),
    onTap: () {
      Navigator.pop(context);
      onTap();
    },
  );
}
```

## 7. Add Analytics Tracking

Create analytics helper file: `/lib/services/analytics/onboarding_analytics.dart`

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class OnboardingAnalytics {
  final FirebaseAnalytics _analytics;

  OnboardingAnalytics(this._analytics);

  // Tutorial events
  Future<void> logTutorialStarted() async {
    await _analytics.logEvent(name: 'onboarding_tutorial_started');
  }

  Future<void> logTutorialPageViewed(int page) async {
    await _analytics.logEvent(
      name: 'onboarding_tutorial_page_viewed',
      parameters: {'page': page},
    );
  }

  Future<void> logTutorialCompleted() async {
    await _analytics.logEvent(name: 'onboarding_tutorial_completed');
  }

  Future<void> logTutorialSkipped(int page) async {
    await _analytics.logEvent(
      name: 'onboarding_tutorial_skipped',
      parameters: {'page': page},
    );
  }

  // Welcome screen
  Future<void> logWelcomeScreenViewed() async {
    await _analytics.logEvent(name: 'welcome_screen_viewed');
  }

  Future<void> logWelcomeCtaClicked(String action) async {
    await _analytics.logEvent(
      name: 'welcome_cta_clicked',
      parameters: {'action': action},
    );
  }

  // First deposit prompt
  Future<void> logFirstDepositPromptShown() async {
    await _analytics.logEvent(name: 'first_deposit_prompt_shown');
  }

  Future<void> logFirstDepositPromptClicked() async {
    await _analytics.logEvent(name: 'first_deposit_prompt_clicked');
  }

  Future<void> logFirstDepositPromptDismissed() async {
    await _analytics.logEvent(name: 'first_deposit_prompt_dismissed');
  }

  // Help content
  Future<void> logHelpContentViewed(String type) async {
    await _analytics.logEvent(
      name: 'help_content_viewed',
      parameters: {'type': type},
    );
  }

  // Milestones
  Future<void> logFirstDepositCompleted(double amountXof) async {
    await _analytics.logEvent(
      name: 'first_deposit_completed',
      parameters: {'amount_xof': amountXof},
    );
  }

  Future<void> logFirstTransferCompleted() async {
    await _analytics.logEvent(name: 'first_transfer_completed');
  }

  Future<void> logKycStartedFromPrompt() async {
    await _analytics.logEvent(name: 'kyc_started_from_prompt');
  }
}

// Provider
final onboardingAnalyticsProvider = Provider<OnboardingAnalytics>((ref) {
  return OnboardingAnalytics(FirebaseAnalytics.instance);
});
```

Use in views:
```dart
// In EnhancedOnboardingView
@override
void initState() {
  super.initState();
  ref.read(onboardingAnalyticsProvider).logTutorialStarted();
}

void _onPageChanged(int index) {
  setState(() => _currentPage = index);
  ref.read(onboardingAnalyticsProvider).logTutorialPageViewed(index + 1);
}

void _onSkip() {
  ref.read(onboardingAnalyticsProvider).logTutorialSkipped(_currentPage + 1);
  _completeOnboarding();
}
```

## 8. Testing Commands

```bash
# Fresh install test
flutter run --clear

# Test specific language
flutter run --dart-define=LOCALE=fr

# Check for errors
flutter analyze

# Run tests
flutter test

# Generate localizations
flutter gen-l10n

# View logs
flutter logs

# Profile performance
flutter run --profile
```

## 9. Debug Helper

Add to your settings screen or debug menu:

```dart
// Debug: Reset onboarding
ElevatedButton(
  onPressed: () async {
    await ref.read(onboardingProgressProvider.notifier).resetProgress();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Onboarding progress reset')),
      );
    }
  },
  child: Text('Reset Onboarding (Debug)'),
),

// Debug: Show current progress
ElevatedButton(
  onPressed: () {
    final progress = ref.read(onboardingProgressProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Onboarding Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tutorial: ${progress.hasSeenTutorial}'),
            Text('First Deposit: ${progress.hasCompletedFirstDeposit}'),
            Text('First Transfer: ${progress.hasCompletedFirstTransfer}'),
            Text('KYC Prompt: ${progress.hasSeenKycPrompt}'),
            Text('Tooltips: ${progress.hasSeenTooltips}'),
            Text('Is New User: ${progress.isNewUser}'),
            Text('Should Show Deposit: ${progress.shouldShowDepositPrompt}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  },
  child: Text('Show Progress (Debug)'),
),
```

## 10. Quick Test Script

Create a test helper:

```dart
// lib/debug/onboarding_test_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingTestHelper {
  static Future<void> testOnboardingFlow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Reset progress
    await ref.read(onboardingProgressProvider.notifier).resetProgress();

    // Navigate to onboarding
    context.go('/onboarding/enhanced');

    // Log
    debugPrint('✅ Onboarding test started - progress reset');
  }

  static Future<void> testWelcomeScreen(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await ref.read(onboardingProgressProvider.notifier).setFirstLogin();
    context.go('/welcome-post-login');
    debugPrint('✅ Welcome screen test started');
  }

  static Future<void> testDepositPrompt(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await ref.read(onboardingProgressProvider.notifier).resetProgress();
    await ref.read(onboardingProgressProvider.notifier).markTutorialCompleted();
    context.go('/home');
    debugPrint('✅ Deposit prompt should show on home screen');
  }
}
```

---

**Copy these snippets directly into your code for quick integration!**
