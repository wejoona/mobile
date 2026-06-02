# Mobile Decisions

Do not reopen these unless new evidence changes them.

## API And Mocking

- The mobile app should prefer real in-stack APIs for dogfooding.
- Mocks are acceptable for outside dependencies and future features, but they must match backend contract shape.
- Auth OTP should use Korido API -> VerifyHQ locally, not a mobile-only fake.

## Design

- Login/register visual language is the reference for app coherence.
- Dark theme is the strongest current theme; improve light theme to match its polish.
- Use one typography system. Avoid screen-local font families and arbitrary sizes.
- Balance and transaction surfaces should use money-specific primitives and consistent family/weight.
- Empty space in key financial zones should communicate calm and hierarchy, not missing content.

## Product

- MVP goal is internal team dogfooding before pilot/release.
- Initial users are in Abidjan and the USA.
- Region-specific rails and labels should be data-driven.
- Contact features should identify Korido users clearly, but similar small high-leverage improvements should be found across the product, not only contacts.

## Deployment

- Production is GitOps-owned.
- Do not mutate live k3s resources for ordinary deploys.
- Read CI and GitOps repo before touching deployment behavior.
