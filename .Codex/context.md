# Mobile Context

## Architecture

- App: Flutter + Riverpod.
- API client: `lib/services/api/api_client.dart`.
- Endpoint constants: `lib/core/constants/api_endpoints.dart`.
- Feature folders: `lib/features/<feature>/`.
- Design system: `lib/design/`.
- Mocks: `lib/mocks/`.
- Router: `lib/router/`.
- Localization: `lib/l10n/`.

## Important Paths

| Need | Path |
| --- | --- |
| API base URL | `lib/services/api/api_client.dart` |
| Auth API provider | `lib/services/api/providers/auth_api.dart` |
| Auth service | `lib/services/auth/auth_service.dart` |
| Auth views | `lib/features/auth/views/` |
| Wallet home | `lib/features/wallet/views/wallet_home_screen.dart` |
| Wallet widgets | `lib/features/wallet/widgets/` |
| Contacts | `lib/features/contacts/` |
| Devices | `lib/features/settings/` |
| Transactions | `lib/features/transactions/` |
| Notifications mocks/service | `lib/mocks/services/notifications/`, `lib/features/notifications/` |
| API-backed savings pots | `lib/features/savings_pots/` |
| Theme tokens | `lib/design/tokens/`, `lib/design/theme/` |
| Golden tests | `test/golden/` |
| E2E-style tests | `test/e2e/`, `integration_test/flows/` |

## Design System Notes

- Typography tokens live in `lib/design/tokens/typography.dart` and `app_text_style.dart`.
- Prefer `AppText` variants to raw `Text` for app UI.
- Prefer `AmountText` or money-specific primitives for balances and amounts.
- Cards should be restrained: 8px radius or less unless existing component requires otherwise.
- Do not create one-off colors; use `theme_colors.dart`, `colors.dart`, and semantic extensions.
- Light theme needs extra care: it should inherit the premium, clean feel of dark theme without becoming washed out.

## API Mode

- Default dev URL currently points to production API unless overridden by `--dart-define=API_URL=...`.
- To dogfood local API, always pass `--dart-define=API_URL=http://<host>:3401/api/v1`.
- `USE_MOCKS=true` should be explicit; do not assume mocked data represents the backend contract.
- `/savings` and `/savings-pots` are routed to the API-backed Savings Pots feature. Do not revive the old wallet-local `SavingsGoalsView` pattern with hardcoded in-memory goals.
- Protected media such as user avatars may be returned as absolute URLs, `/user/avatar/...`, `user/avatar/...`, or `/api/...`; the mobile avatar resolver normalizes these forms against the configured API origin.

## Initial Markets

- Initial customers: Abidjan and USA.
- Region-aware UX should derive from country/profile/config data, not hardcoded Orange/Wave/Ivory Coast assumptions.
- Côte d'Ivoire context: XOF, Orange Money, MTN MoMo, Wave, French primary.
- USA context: USD/USDC, bank/card rails where supported.
