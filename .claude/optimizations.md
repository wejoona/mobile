# Token Optimization Rules

> **MANDATORY reading before any task**

## Rule 1: Never Read Full Files

### Bad (2000 tokens)
```
Read lib/services/pin/pin_service.dart
→ Returns all 398 lines
```

### Good (200 tokens)
```
Check file-index.md → verifyPinLocally is at line 71
Read lib/services/pin/pin_service.dart offset=71 limit=60
→ Returns only the method you need
```

## Rule 2: Never Search When Location is Known

### Bad (500+ tokens)
```
Glob **/*button*.dart
→ Returns 15 files
Read each to find the right one
```

### Good (0 search tokens)
```
Check context.md → AppButton is at lib/design/components/primitives/app_button.dart
Read directly (or don't read at all - check snippets.md)
```

## Rule 3: Never Generate Known Patterns

### Bad (500 tokens)
```
Generate a new screen with scaffold, appbar, body...
[Generates 80 lines of code]
```

### Good (50 tokens)
```
Copy from templates.md "Screen Template"
Replace FeatureName with actual name
```

## Rule 4: Never Explain Before Acting

### Bad (100 tokens)
```
"I'll now create a new screen for the transfer confirmation.
This screen will display the transfer details and allow the
user to confirm. I'll use the standard patterns we've established..."
```

### Good (10 tokens)
```
"Creating transfer confirmation screen."
[Tool call]
```

## Rule 5: Batch Tool Calls

### Bad (3 round trips)
```
Message 1: Read file A
Message 2: Read file B
Message 3: Read file C
```

### Good (1 round trip)
```
Message 1: Read file A, B, C (parallel)
```

## Rule 6: Use Grep with Precision

### Bad
```
Grep "function" → 500 matches
```

### Good
```
Grep "class TransferService" → 1 match
Grep "Future<void> verifyPin" → exact method
```

## Rule 7: Never Re-read in Same Session

If you read a file earlier in the session, don't read it again.
Reference your memory of its contents.

## Rule 8: Skip Exploration for Common Tasks

| Task | Don't Explore | Just Do |
|------|---------------|---------|
| Add screen | - | Copy template, add route |
| Add string | - | Add to arb files |
| Add button | - | Use AppButton |
| Add spacing | - | SizedBox(height: AppSpacing.md) |
| Navigate | - | context.push('/path') |
| Show error | - | AppToast.showError() |

## Rule 9: Use offset/limit for Large Files

| File Size | Action |
|-----------|--------|
| < 100 lines | Read whole file |
| 100-300 lines | Read with limit=100 around target |
| > 300 lines | Check file-index.md, read specific section |

## Rule 10: Don't Spawn Agents for Simple Lookups

### Bad
```
Task tool with Explore agent to find "where errors are handled"
→ Agent reads 20 files, 5000+ tokens
```

### Good
```
Check context.md for error handling location
or
Grep "catch" or "onError" with limit
```

## Token Budget Guidelines

| Task Type | Budget | How to Stay Under |
|-----------|--------|-------------------|
| Add simple screen | 500 | Template + 2 edits |
| Fix bug | 300 | Grep → Read section → Edit |
| Add feature | 1500 | Check context → Template → Implement |
| Refactor | 2000 | Read sections only, batch edits |

## Before Every Tool Call, Ask:

1. Is this in context.md/templates.md/snippets.md? → Don't search
2. Is this in file-index.md? → Use offset/limit
3. Can I batch this with other calls? → Parallel
4. Did I read this earlier? → Use memory
5. Am I about to explain what I'll do? → Just do it

## Quick Reference: What NOT to Do

| Don't | Do Instead |
|-------|------------|
| Read entire file | Read with offset/limit |
| Glob for known files | Use path from context.md |
| Generate boilerplate | Copy from templates.md |
| Explain before action | Just act |
| Sequential reads | Parallel reads |
| Explore agent for lookups | Grep with precision |
| Re-read files | Reference memory |
| Ask obvious questions | Check decisions.md |
