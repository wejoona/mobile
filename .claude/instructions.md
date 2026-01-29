# Instructions for Claude

> **READ THIS FIRST. FOLLOW STRICTLY.**

## Reading Order (Mandatory)

```
1. sitemap.md        ← ALL ROUTES & SCREENS (CHECK BEFORE CREATING ANY SCREEN)
2. optimizations.md  ← Token-saving rules
3. context.md        ← File locations, patterns
4. file-index.md     ← Line numbers for partial reads
5. snippets.md       ← Micro-patterns to copy
6. templates.md      ← Full templates for new files
7. decisions.md      ← Past decisions (don't re-discuss)
8. api-reference.md  ← API endpoints
```

## CRITICAL: Check Sitemap Before Creating Screens

**ALWAYS read `sitemap.md` before creating ANY new screen or route.**

The sitemap contains:
- Every route in the app
- Which view file handles each route
- DO NOT DUPLICATE list

If the screen already exists, USE IT. Do not create a new one.

## Token-Saving Rules

### 1. Read Context Before Exploring
```
ALWAYS read first:
1. .claude/context.md      → Project structure, patterns
2. .claude/templates.md    → Copy-paste code
3. .claude/decisions.md    → Past decisions (don't re-discuss)
4. .claude/api-reference.md → API endpoints

ONLY explore codebase if context files don't answer your question.
```

### 2. Don't Search for Known Locations
```
DON'T: Glob/Grep to find files
DO: Use paths from context.md

Example:
- Need button? → lib/design/components/primitives/app_button.dart
- Need wallet? → lib/features/wallet/
- Need API? → lib/services/sdk/usdc_wallet_sdk.dart
```

### 3. Copy Templates, Don't Generate
```
DON'T: Generate boilerplate from scratch
DO: Copy from templates.md and customize

Example:
- New screen? → Copy "Screen Template"
- New provider? → Copy "Provider Template"
- New service? → Copy "Service Template"
```

### 4. Don't Re-Discuss Decisions
```
DON'T: "Should we use Riverpod or Bloc?"
DO: Check decisions.md → Already decided: Riverpod

DON'T: "What hashing should we use for PIN?"
DO: Check decisions.md → Already decided: PBKDF2, 100k iterations
```

### 5. Minimal Responses
```
DON'T: Long explanations of what you're doing
DO: Short confirmation, then action

Bad: "I'll now create a new screen for the feature. First, let me explain
the architecture we're using. We're using Riverpod for state management
because it offers type-safety and testability. The screen will follow..."

Good: "Creating the screen."
[Write tool]
"Done. Added FeatureView and route."
```

### 6. Batch Operations
```
DON'T: Multiple separate tool calls
DO: Parallel tool calls when possible

Bad:
- Read file A
- Read file B
- Read file C

Good:
- Read files A, B, C (parallel)
```

### 7. Don't Read Entire Files
```
DON'T: Read 500-line file to find one function
DO: Use Grep with specific pattern, or ask user for line number
```

### 8. Use Existing Components
```
Before creating anything, check context.md "Existing Components" table.
DON'T recreate: AppButton, AppText, AppInput, AppCard, AppSelect
```

## Quick Reference

### Common Tasks (No Exploration Needed)

| Task | Action |
|------|--------|
| Add screen | Copy template, add route |
| Add string | Add to app_en.arb + app_fr.arb, run gen-l10n |
| Add API call | Add to service, add mock |
| Style button | Use AppButton with variant |
| Show error | Use AppToast.show() |
| Navigate | context.push('/path') |

### File Locations (Memorized)

| Need | Path |
|------|------|
| Colors | lib/design/tokens/colors.dart |
| Spacing | lib/design/tokens/spacing.dart |
| Router | lib/router/app_router.dart |
| SDK | lib/services/sdk/usdc_wallet_sdk.dart |
| Mocks | lib/mocks/ |
| L10n | lib/l10n/app_en.arb |

### Patterns (Memorized)

| Pattern | Code |
|---------|------|
| Get l10n | `final l10n = AppLocalizations.of(context)!;` |
| Get SDK | `final sdk = ref.read(sdkProvider);` |
| Navigate | `context.push('/path');` |
| Show loading | `AppButton(isLoading: true)` |
| Spacing | `SizedBox(height: AppSpacing.md)` |

## Before Starting Any Task

1. Read this file
2. Read context.md for structure
3. Check if templates.md has what you need
4. Check if decisions.md already answered the question
5. Only then start working
