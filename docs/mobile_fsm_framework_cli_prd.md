# Mobile FSM Framework / CLI PRD

## Purpose

Create a reusable mobile and USSD application framework, delivered as a CLI or recipe pack, that makes route contracts, finite state machines, API contracts, and structural UX rules the default. The goal is to prevent apps from growing screen-by-screen into inconsistent auth, onboarding, KYC, money, consent, and recovery flows.

## Product Thesis

Mobile and USSD apps are state machines with a UI attached. The framework should make that explicit:

- Product paths are modeled as events and states before screens are generated.
- Screens emit events; they do not own routing.
- Services return data or route intents; they do not own navigation.
- Route contracts decide chrome, gates, back behavior, and recovery behavior.
- Generated contract tests protect the structure before visual QA.

## Target Users

- Product engineers building fintech, wallet, compliance, or service apps.
- Backend-first teams that need mobile clients aligned with API contracts.
- Teams building both smartphone and USSD experiences from the same business paths.

## Initial Scope

### Flutter First

Generate and maintain Flutter apps with:

- Typed route contracts.
- FSM state/event definitions.
- FSM-owned navigation facade.
- Auth/login/signup/consent/PIN/KYC/session templates.
- Money-flow templates for quote, confirmation, step-up auth, result, and receipt.
- API client contract adapters.
- Source-boundary tests that reject direct router calls outside the FSM adapter.

### USSD Second

Generate USSD flow definitions from the same route/event model:

- Menu contracts instead of visual routes.
- Session state persistence.
- Input validation.
- Timeout/retry behavior.
- Safe fallbacks and recovery paths.

## Non-Goals

- Do not become a visual design system at first.
- Do not replace backend DDD generation.
- Do not force a single router package forever.
- Do not generate production money logic without API contracts.

## Core Concepts

### Flow Manifest

The app starts from a manifest:

```yaml
product: wallet
platforms: [flutter, ussd]
default_entry: login
flows:
  login:
    entry: /login
    events: [phone_submitted, otp_verified, pin_required, authenticated]
  signup:
    entry: /signup
    events: [phone_submitted, otp_verified, consent_accepted, profile_completed]
  pin_reset:
    entry: /pin/reset
    public: true
    allow_when_locked: true
    events: [forgot_pin_selected, recovery_otp_verified, risk_evaluated]
```

### Route Contract

Each route declares:

- Path or USSD menu code.
- Role.
- Required auth/session/device/KYC state.
- Allowed previous and next events.
- Allowed chrome.
- Forbidden chrome.
- API preconditions.

### FSM Navigation Facade

Generated code exposes methods such as:

- `fsmGo(route, event)`
- `fsmPush(route, event)`
- `fsmPop(fallbackRoute)`
- `openLogin()`
- `openSignup()`
- `openConsent()`
- `openPinReset()`
- `enterAuthenticatedApp()`

The raw router remains private to the FSM adapter.

## CLI Shape

Working name: `mobile-fsm`.

Commands:

```bash
mobile-fsm init --platform flutter --product wallet
mobile-fsm add-flow signup --roles auth-entry,consent-step,setup-step
mobile-fsm add-route /signup/legal-consent --role consent-step
mobile-fsm add-money-flow send --requires wallet --step-up pin
mobile-fsm sync-api ./openapi.yaml
mobile-fsm audit routes
mobile-fsm generate
mobile-fsm test contracts
```

## Generated Files

Flutter:

- `lib/state/fsm/app_route_contract.dart`
- `lib/state/fsm/app_fsm.dart`
- `lib/state/fsm/fsm_provider.dart`
- `lib/router/app_redirector.dart`
- `lib/features/<flow>/views/*`
- `test/state/fsm/app_route_contract_test.dart`
- `test/state/fsm/fsm_navigation_boundary_test.dart`

USSD:

- `src/flows/<flow>.state.ts`
- `src/menus/<flow>.menu.ts`
- `src/session/session-state.repository.ts`
- `test/flows/<flow>.contract.spec.ts`

## Recipes

Initial recipes:

- `auth-phone-otp`
- `signup-consent-profile-pin`
- `session-lock-pin-biometric`
- `pin-reset-risk-liveness-manual-review`
- `kyc-tiered-review`
- `money-quote-confirm-submit-result`
- `notification-route-intents`
- `deep-link-route-intents`
- `phone-number-value-object`

## Quality Gates

Generated projects must include:

- No direct router calls outside FSM adapter.
- No legal consent on login/auth-entry.
- No intro/setup progress on login/signup entry.
- No authenticated shell with login underneath the back stack.
- No money submission before quote/limit/step-up checks.
- No phone serialization outside the phone value object/auth service.
- No recovery endpoint using the normal app token when a scoped recovery token is required.

## Relationship To The DDD CLI

Two viable packaging options:

1. Add `mobile-fsm` as a recipe pack inside the existing DDD CLI.
2. Keep it as a separate CLI that consumes DDD/OpenAPI contracts.

Recommended direction: start separate for speed and clarity, then expose DDD CLI recipes that call it. This keeps mobile/USSD concerns independent while still giving backend-generated contracts a first-class path into client apps.

## MVP Milestones

1. Define manifest schema and route-role vocabulary.
2. Generate Flutter FSM route contract and facade.
3. Generate source-boundary contract tests.
4. Generate login/signup/consent/PIN reset templates.
5. Add OpenAPI sync for endpoint constants and request/response DTOs.
6. Add USSD menu generator from the same manifest.
7. Package as a CLI with recipe hooks for the DDD CLI.

## Open Decisions

- CLI name: `mobile-fsm`, `flowkit`, or `client-fsm`.
- Statechart engine: hand-rolled typed FSM first, or adapter support for XState-like definitions.
- Manifest source of truth: YAML, JSON, or Dart/TypeScript declarations.
- How much visual design should be generated versus delegated to an app design system.
