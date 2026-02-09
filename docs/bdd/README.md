# USDC Wallet - BDD Test Definitions

This directory contains BDD (Behavior-Driven Development) test definitions for the USDC Wallet mobile application, written in Gherkin syntax.

## Purpose

These feature files serve as:
1. **Living Documentation** - Human-readable specifications of app behavior
2. **Test Blueprints** - Foundation for automated integration tests
3. **Acceptance Criteria** - Clear definition of "done" for each feature
4. **Communication Tool** - Bridge between business requirements and implementation

## File Structure

| File | Feature | Status | Screens Covered |
|------|---------|--------|-----------------|
| `01_authentication.feature` | User Authentication | ACTIVE | Splash, Login, OTP, PIN |
| `02_send_money.feature` | Send Money (Internal) | ACTIVE | Recipient, Amount, Confirm, PIN, Result |
| `03_deposit.feature` | Deposit Funds | ACTIVE | Deposit options, Amount, Provider, Instructions, Status |
| `04_kyc.feature` | KYC Verification | ACTIVE | All KYC screens (12+) |
| `05_home_wallet.feature` | Home & Wallet | ACTIVE | Home, Receive, Scan, Success |
| `06_transactions.feature` | Transaction History | ACTIVE | Transactions list, Detail, Export |
| `07_settings.feature` | Settings & Account | ACTIVE | All settings screens (15+) |
| `08_cards.feature` | Virtual Cards | FEATURE_FLAGGED | Cards list, Detail, Request, Settings |
| `09_fsm_states.feature` | FSM State Screens | ACTIVE | All FSM state views (11) |

## Gherkin Syntax Reference

```gherkin
Feature: Feature name
  
  Background:
    Given some precondition that applies to all scenarios
  
  Scenario: Scenario name
    Given some initial context
    When an action is performed
    Then expected outcome occurs
    And another expected outcome
  
  Scenario Outline: Parameterized scenario
    Given condition with <parameter>
    When action with <value>
    Then result is <expected>
    
    Examples:
      | parameter | value | expected |
      | x         | 1     | a        |
      | y         | 2     | b        |
```

## Tags

Tags are used to categorize and filter tests:

| Tag | Meaning |
|-----|---------|
| `@critical` | Critical path, must always pass |
| `@feature-flagged` | Behind a feature flag |
| `@authentication` | Authentication related |
| `@send` | Send money flow |
| `@deposit` | Deposit flow |
| `@kyc` | KYC verification |
| `@edge-case` | Edge case scenarios |
| `@offline` | Offline mode scenarios |
| `@security` | Security-related tests |

## Running Tests (Future)

These BDD definitions will be connected to automated tests:

```bash
# Run all tests
flutter test integration_test/

# Run specific feature
flutter test integration_test/bdd/authentication_test.dart

# Run by tag
flutter test --tags=critical
```

## Converting to Automated Tests

Each scenario can be implemented using Flutter's integration testing framework:

```dart
// Example: From BDD to Dart test

// BDD:
// Scenario: Enter valid phone number
//   Given the user is on the login screen
//   When they enter a valid phone number "+2250123456789"
//   And tap the "Continue" button
//   Then they should be navigated to "/login/otp"

// Dart:
testWidgets('Enter valid phone number', (tester) async {
  // Given: the user is on the login screen
  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();
  
  // When: they enter a valid phone number
  await tester.enterText(
    find.byKey(const Key('phone_input')), 
    '0123456789'
  );
  
  // And: tap the "Continue" button
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  
  // Then: they should be navigated to "/login/otp"
  expect(find.byType(LoginOtpView), findsOneWidget);
});
```

## Coverage Map

| Feature Area | BDD Scenarios | Automated Tests | Coverage |
|--------------|---------------|-----------------|----------|
| Authentication | 25 | 0 | 0% |
| Send Money | 32 | 0 | 0% |
| Deposit | 28 | 0 | 0% |
| KYC | 35 | 0 | 0% |
| Home/Wallet | 24 | 0 | 0% |
| Transactions | 26 | 0 | 0% |
| Settings | 30 | 0 | 0% |
| Cards | 24 | 0 | 0% |
| FSM States | 28 | 0 | 0% |
| **Total** | **252** | **0** | **0%** |

## Next Steps

1. **Phase 2: Golden Tests** - Create visual golden tests for each screen
2. **Phase 3: Design Tests** - Visual regression testing
3. **Phase 4: Unit Tests** - Unit tests for business logic
4. **Phase 5: Integration Tests** - Connect BDD to automated tests

## Contributing

When adding new features:

1. Create/update the `.feature` file first
2. Define scenarios before implementation
3. Use existing tags appropriately
4. Follow Gherkin best practices
5. Keep scenarios atomic and independent

## References

- [Gherkin Reference](https://cucumber.io/docs/gherkin/reference/)
- [BDD Best Practices](https://cucumber.io/docs/bdd/)
- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
