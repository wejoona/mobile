# Feature Flags Integration Checklist

## Prerequisites
- [ ] Backend API endpoints implemented (`/feature-flags/me`)
- [ ] Database table `system.feature_flags` created
- [ ] Shared preferences dependency added to `pubspec.yaml`

## Implementation Steps

### 1. App Initialization
- [ ] Import SharedPreferences in `main.dart`
- [ ] Initialize SharedPreferences before runApp
- [ ] Override `sharedPreferencesProvider` in ProviderScope
- [ ] Call `loadFlags()` on app start

### 2. Auth Integration
- [ ] Call `refresh()` after successful login
- [ ] Call `clearCache()` on logout
- [ ] Handle flag refresh errors gracefully

### 3. Mock Setup
- [ ] Verify mock interceptor registered in `mock_registry.dart`
- [ ] Test mock endpoints return expected data
- [ ] Update mock data to match backend flags

### 4. UI Integration
- [ ] Replace hardcoded feature checks with `FeatureGate`
- [ ] Update existing `if (canDoX)` checks to use provider
- [ ] Add fallback UI for disabled features
- [ ] Test UI with flags enabled/disabled

### 5. Testing
- [ ] Run unit tests: `flutter test test/services/feature_flags_service_test.dart`
- [ ] Test offline mode (airplane mode)
- [ ] Test cache persistence (kill and restart app)
- [ ] Test auto-refresh (wait 15+ minutes)
- [ ] Test flag changes (toggle backend flags)

### 6. Migration
- [ ] Update all references to old `FeatureFlags.mvp()`
- [ ] Replace `canPayBills` with `FeatureFlagKeys.billPayments`
- [ ] Remove old `feature_flags_service.dart` if not needed
- [ ] Update import statements

### 7. Documentation
- [ ] Update team docs with usage patterns
- [ ] Add feature flag keys to backend documentation
- [ ] Document evaluation rules for product team
- [ ] Create runbook for toggling flags

## Verification

### Functional Tests
- [ ] App starts successfully
- [ ] Flags load from cache on cold start
- [ ] Flags fetch from API after cache expires
- [ ] Login refreshes flags
- [ ] Logout clears flags
- [ ] Offline mode uses cached flags
- [ ] UI updates when flags change

### Performance Tests
- [ ] App startup time < 3s with flags
- [ ] Flag check performance < 1ms
- [ ] No UI jank when gates render
- [ ] Cache size < 10KB

### Edge Cases
- [ ] No network on first launch
- [ ] API returns error
- [ ] Invalid flag key requested
- [ ] Flag removed from backend
- [ ] Concurrent refresh calls
- [ ] Cache corrupted

## Rollout Plan

### Phase 1: Development
- [ ] Deploy to dev environment
- [ ] Test with dev team
- [ ] Fix any issues

### Phase 2: Staging
- [ ] Deploy to staging
- [ ] QA testing
- [ ] Performance testing

### Phase 3: Production (Gradual)
- [ ] Enable for internal users (0.1%)
- [ ] Monitor metrics and errors
- [ ] Expand to beta users (5%)
- [ ] Monitor for issues
- [ ] Full rollout (100%)

## Monitoring

### Metrics to Track
- [ ] Flag fetch success rate
- [ ] Flag fetch latency
- [ ] Cache hit rate
- [ ] Flag evaluation errors
- [ ] User impact by flag

### Alerts to Set Up
- [ ] Flag fetch failure rate > 5%
- [ ] Flag fetch latency > 2s
- [ ] Cache corruption errors
- [ ] Unexpected flag states

## Post-Launch

### Week 1
- [ ] Monitor error rates
- [ ] Check cache performance
- [ ] Verify flag changes propagate
- [ ] Collect user feedback

### Week 2
- [ ] Analyze flag usage patterns
- [ ] Identify unused flags
- [ ] Optimize cache strategy if needed
- [ ] Update documentation based on learnings

### Month 1
- [ ] Review all active flags
- [ ] Deprecate temporary flags
- [ ] Plan new feature rollouts
- [ ] Share best practices with team

## Cleanup

After successful rollout:
- [ ] Remove old feature flag system
- [ ] Archive migration documentation
- [ ] Update code style guide
- [ ] Celebrate!

## Contacts

- Backend: Check `/usdc-wallet/src/modules/feature-flag/`
- Frontend: Check `/mobile/lib/services/feature_flags/`
- Docs: See README.md and IMPLEMENTATION.md

## Notes

- Auto-refresh interval: 15 minutes
- Cache key: `feature_flags_cache`
- Default behavior: disabled (safe default)
- Evaluation: server-side only
