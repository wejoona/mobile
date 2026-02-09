/// USAGE EXAMPLES for HapticService
///
/// This file demonstrates proper usage of the haptic feedback system.
/// DO NOT IMPORT THIS FILE - it's for documentation only.

import 'package:flutter/material.dart';
import 'haptic_service.dart';

// =============================================================================
// Transaction Operations
// =============================================================================

void examplePaymentFlow() {
  // When user taps "Send Money" button
  hapticService.paymentStart();

  // When PIN is verified and payment is submitted
  hapticService.paymentConfirmed();

  // On success screen
  hapticService.success();

  // On error screen
  hapticService.error();

  // On warning (e.g., large amount)
  hapticService.warning();
}

// =============================================================================
// PIN Entry
// =============================================================================

void examplePinEntry() {
  // Each digit tap
  hapticService.pinDigit();

  // When all 6 digits entered
  hapticService.pinComplete();

  // When biometric prompt shown
  hapticService.biometricPrompt();
}

// =============================================================================
// Settings & Toggles
// =============================================================================

class ExampleSettingsToggle extends StatelessWidget {
  const ExampleSettingsToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: true,
      onChanged: (value) {
        hapticService.toggle(); // Toggle feedback
      },
    );
  }
}

// =============================================================================
// Buttons
// =============================================================================

class ExampleButtons extends StatelessWidget {
  const ExampleButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary action - automatic in AppButton
        // AppButton already includes mediumTap for primary variant

        // Manual haptic for custom button
        ElevatedButton(
          onPressed: () {
            hapticService.mediumTap();
            // Action here
          },
          child: const Text('Custom Button'),
        ),

        // Destructive action
        ElevatedButton(
          onPressed: () {
            hapticService.heavyTap(); // Heavy for destructive
            // Delete action
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

// =============================================================================
// List Selection
// =============================================================================

class ExampleList extends StatelessWidget {
  const ExampleList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
          onTap: () {
            hapticService.selection(); // Light selection feedback
            // Navigate or select
          },
        );
      },
    );
  }
}

// =============================================================================
// Copy to Clipboard
// =============================================================================

void exampleCopyToClipboard() async {
  hapticService.lightTap();
  // Clipboard.setData()
}

// =============================================================================
// Refresh
// =============================================================================

class ExampleRefresh extends StatelessWidget {
  const ExampleRefresh({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        hapticService.refresh();
        // Fetch data
      },
      child: ListView(),
    );
  }
}

// =============================================================================
// Long Press
// =============================================================================

class ExampleLongPress extends StatelessWidget {
  const ExampleLongPress({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        hapticService.longPress();
        // Show context menu
      },
      child: const Text('Long press me'),
    );
  }
}

// =============================================================================
// Custom Patterns
// =============================================================================

void exampleCustomPatterns() async {
  // Delayed haptic (for animation timing)
  await hapticService.delayedHaptic(
    hapticService.success,
    const Duration(milliseconds: 300),
  );

  // Custom vibration pattern (Android only)
  await hapticService.customPattern([0, 100, 50, 100]);
}

// =============================================================================
// Global Enable/Disable
// =============================================================================

void exampleSettings() {
  // Disable haptics globally (user preference)
  hapticService.setEnabled(false);

  // Check if enabled
  if (hapticService.isEnabled) {
    hapticService.lightTap();
  }
}

// =============================================================================
// Financial Operations
// =============================================================================

void exampleFinancialOperations() {
  // Money sent successfully
  hapticService.paymentConfirmed();

  // Money received notification
  hapticService.fundsReceived();

  // Large transfer warning
  hapticService.warning();

  // Transfer failed
  hapticService.error();
}

// =============================================================================
// Best Practices
// =============================================================================

/// DO:
/// - Use consistent haptics for similar actions
/// - Match haptic intensity to action importance
/// - Consider user's haptic preferences
/// - Use lighter haptics for frequent actions
/// - Use heavier haptics for important/destructive actions
///
/// DON'T:
/// - Overuse haptics (causes fatigue)
/// - Use heavy haptics for minor actions
/// - Use haptics for every tap
/// - Forget to handle user preferences
/// - Use custom patterns without good reason
///
/// ACCESSIBILITY:
/// - Always respect system haptic settings
/// - Provide visual feedback alongside haptics
/// - Allow users to disable haptics in settings
/// - Test with haptics disabled
