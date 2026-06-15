# Korido Mobile DevOps Rules

This repo follows the Source Command branch and release contract.

## Branches

- `develop`: active integration. Push coherent feature/fix slices here.
- `staging`: stable team-validation candidate. Codemagic watches this branch and publishes TestFlight builds.
- `main`: production-ready source only.

Promote `develop` to `staging` only when the app boots, the primary changed flow has no known crash, and the API contract for the slice is aligned.

## Mobile Release Rules

- Keep the marketing version below `2.0.0` before launch; prefer stable `1.x` and increment build numbers through Codemagic/App Store Connect.
- Do not push every fix to `staging`. Batch a stable candidate.
- Use real in-stack APIs for readiness work. Use mocks only for unavailable outside dependencies.
- Do not mutate Kubernetes or GitOps from mobile-only work.

## Verification Before Staging

- Run focused Flutter analysis/tests for the touched slice when practical.
- Boot on the intended simulator/device for UI/security/session changes.
- Check both light and dark theme for visible UI changes.
