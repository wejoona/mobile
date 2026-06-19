# Mobile Decisions

Do not reopen these unless new evidence changes them.

## API And Mocking

- The mobile app should prefer real in-stack APIs for dogfooding.
- Mocks are acceptable for outside dependencies and future features, but they must match backend contract shape.
- Auth OTP should use Korido API -> VerifyHQ locally, not a mobile-only fake.
- Cross-service credentials are bootstrap-only when wired directly through Vault or env values. The platform service / service access enrollment layer is the canonical owner for multi-service credential issuance, rotation, and trust between Korido, VerifyHQ, PaySwitch, and other JoonaPay services.

## Design

- Login/register visual language is the reference for app coherence.
- Dark theme is the strongest current theme; improve light theme to match its polish.
- Use one typography system. Avoid screen-local font families and arbitrary sizes.
- Balance and transaction surfaces should use money-specific primitives and consistent family/weight.
- Empty space in key financial zones should communicate calm and hierarchy, not missing content.

## Product

- MVP goal is internal team dogfooding before pilot/release.
- Once a reported issue is verified solved on current `develop`, treat it as closed and do not re-audit it every session. Reopen only with fresh user evidence, a failing focused check, or a related code change that could regress it.
- Initial users are in Abidjan and the USA.
- Region-specific rails and labels should be data-driven.
- Phone numbers are canonical value objects, not display strings. Keep country ISO, dial/calling code, local national number, E.164/MSISDN, and display text as explicit fields when useful; never concatenate UI fragments like `+225|+225...` into API state, and never hardcode `+225` in money-flow provider logic outside fixtures or CI-specific tests.
- Money-flow country, currency, and rail ownership must be explicit. Do not infer a deposit/withdraw/send country from a formatted phone display, selected provider label, or currency alone when a country/profile/config value is available.
- Contact features should identify Korido users clearly, but similar small high-leverage improvements should be found across the product, not only contacts.
- Savings goals must stay API-backed through Savings Pots. The old wallet-local `SavingsGoalsView` was removed because it used hardcoded in-memory data and could diverge from money-flow reality.
- Profile photos are protected media. Mobile must preserve auth headers for protected avatar URLs and resolve relative API paths without inventing public storage URLs.

## Branch Triage

- `github/fix/money-movement-issues` and `github/fix/wallet-account-issues` were rejected as stale/destructive for mobile; they attempted to delete `.Codex`, fonts, Gradle wrapper, generated/localization/test assets, and large chunks of current work. The useful virtual-cards flag already exists on `develop`.
- Dashboard `github/main` was rejected as stale because it removes current API-backed services/resources and restores local transaction create/edit pages.
- Backend `github/main` was rejected as stale because it removes service-access, risk, provider extraction, device blacklist, email verification, and related hardening work.

## Deployment

- Production is GitOps-owned.
- Do not mutate live k3s resources for ordinary deploys.
- Read CI and GitOps repo before touching deployment behavior.
- Mobile active development happens on `develop`.
- Mobile TestFlight candidates are promoted through `staging`, which Codemagic watches.
- API/dashboard staging Kubernetes candidates should also be promoted through `staging` once their GitOps values/apps exist; `main` remains production.
- Do not push every fix to `staging`; promote only stable candidates with no known crash/regression.
- Keep the public app version below `2.0.0` before launch. Prefer keeping `1.0.0` and letting Codemagic advance the TestFlight build number from App Store Connect.
- Use `mobile/scripts/promote_testflight_candidate.sh --yes` for deliberate candidate pushes after the candidate is stable enough.

## Dependencies

- Release-build dependency warnings are not automatically a release blocker.
- Do not bulk-upgrade FlutterFire, camera, contacts, permissions, local auth, or notification plugins during product hardening without a dedicated upgrade branch and full simulator/API regression pass.
- Patch-level lockfile upgrades are acceptable only when tied to a concrete bug, security fix, or build failure.
- The current Swift Package Manager warnings are future Flutter compatibility warnings; CocoaPods remains the active iOS integration path.
