# Error Handling Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         MyApp                                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              RootErrorBoundary                            │  │
│  │  Catches ALL unhandled errors in the entire app          │  │
│  │                                                           │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │           Feature A Screen                          │ │  │
│  │  │  ┌───────────────────────────────────────────────┐  │ │  │
│  │  │  │     ErrorBoundary (errorContext: 'FeatureA')  │  │ │  │
│  │  │  │  Catches errors in this feature only          │  │ │  │
│  │  │  │                                                │  │ │  │
│  │  │  │  Widget Tree → Error → ErrorFallbackUI        │  │ │  │
│  │  │  │                           ↓                    │  │ │  │
│  │  │  │                    User sees friendly message │  │ │  │
│  │  │  │                    User can tap "Retry"       │  │ │  │
│  │  │  └───────────────────────────────────────────────┘  │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  │                                                           │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │           Feature B Screen                          │ │  │
│  │  │  ┌───────────────────────────────────────────────┐  │ │  │
│  │  │  │     ErrorBoundary (errorContext: 'FeatureB')  │  │ │  │
│  │  │  └───────────────────────────────────────────────┘  │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    All errors reported to
                    Firebase Crashlytics
```

## Error Flow

```
User Action
    ↓
Widget/Async Operation
    ↓
[Error Occurs]
    ↓
    ├─→ Caught by ErrorBoundary?
    │   ├─→ YES: Show ErrorFallbackUI
    │   │         Report to Crashlytics
    │   │         User can retry
    │   │
    │   └─→ NO: Continue up the tree
    │             ↓
    │         Caught by RootErrorBoundary?
    │             ├─→ YES: Full-screen error
    │             │         Report to Crashlytics
    │             │         User can restart
    │             │
    │             └─→ NO: Red Flutter error screen
    │                     (Should never happen)
    │
    └─→ Caught by try-catch?
        ├─→ YES: Handle manually
        │         Report with ErrorReporter
        │         Show Snackbar/CompactError
        │
        └─→ NO: Propagate to ErrorBoundary
```

## Component Relationships

```
┌─────────────────────────────────────────────────────────────────┐
│                    Error Handling Layers                         │
└─────────────────────────────────────────────────────────────────┘

Layer 1: Error Boundaries (Widget Tree Protection)
┌────────────────────────────────────────────────────────────────┐
│ RootErrorBoundary                                              │
│   └─ ErrorBoundary (per screen/feature)                       │
│       └─ AsyncErrorBoundary (per async widget)                │
└────────────────────────────────────────────────────────────────┘
                              ↓
Layer 2: Error Handlers (Code Protection)
┌────────────────────────────────────────────────────────────────┐
│ ErrorHandlerMixin (for widgets)                                │
│   └─ handleAsyncError()                                        │
│   └─ handleAsyncErrorWithResult()                             │
│                                                                 │
│ NotifierErrorHandler (for providers)                           │
│   └─ handleAsyncError()                                        │
│   └─ handleAsyncErrorWithResult()                             │
└────────────────────────────────────────────────────────────────┘
                              ↓
Layer 3: Error Reporting (Logging & Analytics)
┌────────────────────────────────────────────────────────────────┐
│ ErrorReporter                                                  │
│   ├─ reportError()                                             │
│   ├─ reportNetworkError()                                      │
│   ├─ logBreadcrumb()                                           │
│   └─ setUserInfo()                                             │
│                        ↓                                        │
│           Firebase Crashlytics                                 │
└────────────────────────────────────────────────────────────────┘
                              ↓
Layer 4: User Feedback (UI Display)
┌────────────────────────────────────────────────────────────────┐
│ ErrorFallbackUI (full screen)                                  │
│ CompactErrorWidget (inline)                                    │
│ EmptyStateErrorWidget (empty states)                           │
│ SnackbarError (transient)                                      │
└────────────────────────────────────────────────────────────────┘
```

## Error Type Hierarchy

```
Object
  └─ Exception
      └─ AppError (abstract base class)
          ├─ NetworkError
          │   ├─ fromDioException() factory
          │   └─ statusCode, endpoint
          │
          ├─ AuthError
          │   ├─ sessionExpired
          │   ├─ invalidCredentials
          │   └─ accountLocked
          │
          ├─ ValidationError
          │   └─ field name
          │
          ├─ BusinessError
          │   ├─ insufficientBalance
          │   ├─ dailyLimitExceeded
          │   └─ invalidRecipient
          │
          ├─ StorageError
          │   ├─ readFailed
          │   └─ writeFailed
          │
          ├─ BiometricError
          │   ├─ notAvailable
          │   ├─ notEnrolled
          │   └─ authenticationFailed
          │
          ├─ MediaError
          │   ├─ cameraNotAvailable
          │   ├─ permissionDenied
          │   └─ imageQualityPoor
          │
          └─ QRCodeError
              ├─ invalidFormat
              └─ scanFailed
```

## Integration Points

```
┌───────────────────────────────────────────────────────────────┐
│                      Your App Code                            │
└───────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
         Wrap Screen    Use Mixin    Manual Reporting
              ↓               ↓               ↓
    ┌─────────────┐  ┌──────────────┐  ┌────────────────┐
    │ErrorBoundary│  │ErrorHandler  │  │ErrorReporter   │
    │             │  │Mixin         │  │                │
    │errorContext:│  │              │  │reportError()   │
    │'ScreenName' │  │handleAsync   │  │logBreadcrumb() │
    │             │  │Error()       │  │setUserInfo()   │
    └─────────────┘  └──────────────┘  └────────────────┘
              │               │               │
              └───────────────┼───────────────┘
                              ↓
                    ┌──────────────────┐
                    │Error Occurs      │
                    └──────────────────┘
                              ↓
                    ┌──────────────────┐
                    │Process Error     │
                    │- Determine type  │
                    │- Extract message │
                    │- Add context     │
                    └──────────────────┘
                              ↓
              ┌───────────────┼───────────────┐
              │               │               │
         Show UI      Report to      Log to
              ↓         Crashlytics   Console
    ┌─────────────┐  ┌──────────────┐  ┌────────────┐
    │ErrorFallback│  │Firebase      │  │debugPrint()│
    │UI           │  │Crashlytics   │  │            │
    │             │  │              │  │            │
    │User-friendly│  │Context,      │  │Stack trace │
    │message      │  │severity,     │  │for devs    │
    │Retry button │  │metadata      │  │            │
    └─────────────┘  └──────────────┘  └────────────┘
```

## State Flow in Widget with Error Handling

```
┌─────────────────────────────────────────────────────────────────┐
│              Widget State Machine                                │
└─────────────────────────────────────────────────────────────────┘

Initial State
    ↓
User taps "Load Data"
    ↓
setState(isLoading: true)
    ↓
handleAsyncError(() async {
    ↓
  API Call
    ↓
  Success? ────YES───→ setState(data: result, isLoading: false)
    │                           ↓
    NO                     Show data to user
    │
  Error thrown
    ↓
  Caught by handleAsyncError
    ↓
  ├─→ Report to Crashlytics
  │   (context, severity, metadata)
  │
  ├─→ setState(isLoading: false)
  │
  └─→ Show error snackbar
          ↓
    User sees error message
          ↓
    User can retry
          ↓
    Loop back to "User taps Load Data"
})
```

## Async Error Boundary Flow

```
┌─────────────────────────────────────────────────────────────────┐
│            AsyncErrorBoundary Widget                             │
└─────────────────────────────────────────────────────────────────┘

AsyncErrorBoundary<T>(
  future: fetchData(),
  builder: (context, data) => DataWidget(data),
)
    ↓
FutureBuilder internally
    ↓
ConnectionState.waiting?
    ├─→ YES: Show loadingBuilder()
    │         or CircularProgressIndicator
    │
    └─→ NO: Check for error
            ↓
        Has error?
            ├─→ YES: Report to Crashlytics
            │         ↓
            │       Show errorBuilder()
            │       or ErrorFallbackUI
            │         ↓
            │       User taps retry
            │         ↓
            │       Rebuild widget
            │       (future executes again)
            │
            └─→ NO: Has data?
                    ├─→ YES: Show builder(context, data)
                    │
                    └─→ NO: Show empty widget
```

## Error Severity Decision Tree

```
Error Occurs
    ↓
What type?
    │
    ├─→ Validation Error (user input)
    │       ↓
    │   Severity: INFO
    │   Report: NO (don't send to Crashlytics)
    │   Show: Inline validation message
    │
    ├─→ Network Error (connection issue)
    │       ↓
    │   Severity: WARNING
    │   Report: YES (for analytics)
    │   Show: Snackbar with retry
    │
    ├─→ Auth Error (session expired)
    │       ↓
    │   Severity: ERROR
    │   Report: YES
    │   Show: Redirect to login
    │
    ├─→ Business Error (insufficient funds)
    │       ↓
    │   Severity: INFO
    │   Report: YES (for business analytics)
    │   Show: Dialog with explanation
    │
    └─→ Unknown Error (unexpected)
            ↓
        Severity: ERROR or FATAL
        Report: YES (definitely)
        Show: ErrorFallbackUI with retry
```

## Data Flow: Error Reporting

```
┌──────────────────────────────────────────────────────────────────┐
│                   Error Occurs in App                             │
└──────────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────────┐
│         ErrorReporter.reportError(error, stack)                   │
│                                                                   │
│  1. Extract error information                                    │
│     - Error message                                              │
│     - Stack trace                                                │
│     - Error type                                                 │
│                                                                   │
│  2. Add context                                                  │
│     - Screen/feature name                                        │
│     - User ID (if logged in)                                     │
│     - App state                                                  │
│     - Custom metadata                                            │
│                                                                   │
│  3. Determine severity                                           │
│     - Info / Warning / Error / Fatal                             │
└──────────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────────┐
│              Firebase Crashlytics                                 │
│                                                                   │
│  Records:                                                        │
│  - Error type and message                                        │
│  - Stack trace                                                   │
│  - Device info (OS, model, version)                              │
│  - User info (ID, email)                                         │
│  - Custom keys (context, metadata)                               │
│  - Breadcrumbs (user journey)                                    │
│  - App version                                                   │
│  - Timestamp                                                     │
└──────────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────────┐
│         Firebase Console (Analytics Dashboard)                    │
│                                                                   │
│  View:                                                           │
│  - Error trends over time                                        │
│  - Most common errors                                            │
│  - Affected users                                                │
│  - Device/OS breakdown                                           │
│  - Error context and metadata                                    │
│  - User journey before error                                     │
└──────────────────────────────────────────────────────────────────┘
                            ↓
                 Developer fixes issue
                            ↓
                   Deploy new version
                            ↓
                Monitor error reduction
```

## Best Practices Summary

```
DO ✅                                    DON'T ❌
────────────────────────────────────    ────────────────────────────────
Wrap app with RootErrorBoundary         Wrap every single widget
Wrap screens with ErrorBoundary         Show stack traces to users
Use ErrorHandlerMixin for async ops     Report validation errors
Provide user-friendly messages          Swallow errors silently
Add retry options                       Use generic error messages
Report with context                     Forget to test error scenarios
Set user info on login                  Let errors crash the app
Clear user info on logout               Over-report trivial issues
Test error scenarios                    Ignore error analytics
```

## Performance Characteristics

```
Component               Overhead    When
─────────────────────  ──────────  ────────────────────────
RootErrorBoundary      ~1ms        App initialization
ErrorBoundary          ~1ms        Per wrapped widget
AsyncErrorBoundary     ~0ms        Only on error
ErrorHandlerMixin      ~0ms        Only on error
ErrorReporter          ~5-10ms     Async (non-blocking)
ErrorFallbackUI        ~50ms       Only when displayed

Total Impact: Negligible in normal operation
```
