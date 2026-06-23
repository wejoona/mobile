# Korido Candidate Flow Mermaid

This file is the visual contract for candidate-critical Korido flows. It maps
user paths, FSM events, API calls, backend decisions, provider fallbacks, and
candidate gates. Keep implementation aligned with these diagrams before
promoting `develop` to `staging`.

## 1. App Startup, Version, Security, And Default Entry

```mermaid
flowchart TD
  A["App process starts"] --> B["Bootstrap: load env, API URL, saved session, theme"]
  B --> C["GET /config/mobile-version"]
  C --> D{"Force upgrade required?"}
  D -- "Yes" --> E["FSM event: forceUpdateRequired"]
  E --> F["/force-update with app URL when available"]
  D -- "No" --> G["Run device security checks"]
  G --> H{"Security issue detected?"}
  H -- "Yes" --> I["FSM event: deviceSecurityBlocked"]
  I --> J["Security alert screen"]
  H -- "No" --> K{"Valid saved session?"}
  K -- "No" --> L["FSM event: unauthenticated"]
  L --> M["/login as default entry, dark theme default"]
  K -- "Yes" --> N{"Session lock required?"}
  N -- "Yes" --> O["FSM event: sessionLocked"]
  O --> P["/session-locked"]
  N -- "No" --> Q["Refresh profile, wallet, limits, devices"]
  Q --> R["/home"]
```

```mermaid
flowchart LR
  A["Startup decision"] --> B{"Config API reachable?"}
  B -- "No" --> C{"Local minimum version policy cached?"}
  C -- "Yes" --> D["Use cached policy, mark API degraded"]
  C -- "No" --> E["Allow login with degraded banner unless security blocks"]
  B -- "Yes" --> F{"API URL returned?"}
  F -- "Yes" --> G["Use explicit API URL for subsequent calls"]
  F -- "No" --> H["Keep bundled API URL"]
```

## 2. Login And OTP

```mermaid
flowchart TD
  A["/login"] --> B["User selects country"]
  B --> C["PhoneNumber value object: countryIso, callingCode, nationalNumber, e164, display"]
  C --> D{"National number valid for country?"}
  D -- "No" --> E["Show local validation error, no API call"]
  D -- "Yes" --> F["FSM event: loginOtpRequested"]
  F --> G["POST /auth/login"]
  G --> H{"OTP request accepted?"}
  H -- "No: user not found" --> I["Show explicit account detail error and signup CTA"]
  H -- "No: rate limited" --> J["Show cooldown state"]
  H -- "No: network/API" --> K["Show retryable API error"]
  H -- "Yes" --> L["/login/otp with phone value object carried forward"]
  L --> M["User enters 6-digit OTP"]
  M --> N["Show visual cue: accepted code, securing session"]
  N --> O["POST /auth/verify-otp"]
  O --> P{"OTP valid?"}
  P -- "No" --> Q["Return to OTP input with retry/error"]
  P -- "Yes" --> R["Persist tokens and user"]
  R --> S{"User PIN set?"}
  S -- "No" --> T["FSM event: pinSetupRequired -> /pin/setup"]
  S -- "Yes" --> U["FSM event: pinUnlockRequired -> /login/pin or /session-locked"]
```

```mermaid
flowchart LR
  A["Login route"] --> B{"Has TOS checkbox?"}
  B -- "Yes" --> C["Invalid: remove from login"]
  B -- "No" --> D{"Signup CTA opens signup start?"}
  D -- "No" --> E["Invalid: route link bug"]
  D -- "Yes" --> F["Valid login surface"]
```

## 3. Signup, Consent, And Onboarding

```mermaid
flowchart TD
  A["/login -> user taps Sign up"] --> B["FSM event: signupSelected"]
  B --> C["/onboarding/phone or /signup/start"]
  C --> D["Collect country and phone value object"]
  D --> E["POST /auth/register"]
  E --> F{"Registration OTP accepted?"}
  F -- "No" --> G["Show explicit registration error"]
  F -- "Yes" --> H["/onboarding/otp"]
  H --> I["POST /auth/verify-otp"]
  I --> J{"OTP valid?"}
  J -- "No" --> K["Retry OTP"]
  J -- "Yes" --> L["FSM event: consentRequired"]
  L --> M["/onboarding/consent as separate consent step"]
  M --> N{"Required consents accepted?"}
  N -- "No" --> O["Stay on consent, explain required documents"]
  N -- "Yes" --> P["POST consent acceptance when API exists or persist pending consent locally"]
  P --> Q["/onboarding/profile"]
  Q --> R["/onboarding/pin"]
  R --> S["/onboarding/kyc-prompt"]
  S --> T["/onboarding/success"]
  T --> U["/home"]
```

```mermaid
flowchart LR
  A["Signup surface"] --> B{"Shows onboarding step marker before OTP?"}
  B -- "Yes" --> C["Invalid: signup start is not onboarding progress"]
  B -- "No" --> D{"Back button pops to login safely?"}
  D -- "No" --> E["Invalid: route stack bug"]
  D -- "Yes" --> F["Valid signup start"]
```

## 4. PIN Unlock, Setup, Change, And Recovery

```mermaid
flowchart TD
  A["Authenticated session requires local unlock"] --> B["/session-locked or /login/pin"]
  B --> C{"Biometric unlock eligible?"}
  C -- "Yes" --> D["Show biometric button"]
  C -- "No" --> E["Hide biometric button"]
  D --> F["User taps biometric"]
  F --> G{"Device biometric succeeds and bound account matches?"}
  G -- "No" --> H["Stay locked, allow PIN"]
  G -- "Yes" --> I["FSM event: localUnlockSucceeded"]
  I --> J["/home"]
  E --> K["User enters PIN"]
  H --> K
  K --> L["POST /user/pin/verify"]
  L --> M{"PIN valid?"}
  M -- "No" --> N["Increment attempts, show lockout if needed"]
  M -- "Yes" --> I
```

```mermaid
flowchart TD
  A["User taps Forgot PIN"] --> B["FSM event: pinRecoveryStarted"]
  B --> C["/pin/reset with phone prefilled from current auth/session context"]
  C --> D["POST /user/pin/reset or account recovery OTP request"]
  D --> E{"OTP sent?"}
  E -- "No" --> F["Show retryable recovery error"]
  E -- "Yes" --> G["/pin/reset/otp"]
  G --> H["Verify recovery OTP"]
  H --> I{"OTP valid?"}
  I -- "No" --> J["Retry OTP"]
  I -- "Yes" --> K["POST /risk/screen operation=account_recovery"]
  K --> L{"Risk decision"}
  L -- "Low" --> M["Allow new PIN setup"]
  L -- "Medium" --> N["Require extra OTP or device confirmation"]
  L -- "High" --> O["Require liveness"]
  L -- "Provider down / cannot decide" --> P["Create support ticket category=account_recovery"]
  O --> Q["Run liveness flow"]
  Q --> R{"Liveness proof accepted?"}
  R -- "Yes" --> M
  R -- "No or unavailable" --> P
  P --> S["Manual review screen with SLA, no route dead end"]
  M --> T["Enter new PIN once"]
  T --> U["Confirm new PIN"]
  U --> V["POST /user/pin/set or reset completion"]
  V --> W["FSM event: pinRecoveryCompleted"]
  W --> X["Unlock session without asking same PIN a third time"]
```

```mermaid
flowchart LR
  A["Biometric eligibility"] --> B{"User logged in before on this app install?"}
  B -- "No" --> C["Do not show biometric unlock"]
  B -- "Yes" --> D{"User enabled biometric for Korido account?"}
  D -- "No" --> C
  D -- "Yes" --> E{"Stored account binding matches current user?"}
  E -- "No" --> C
  E -- "Yes" --> F["Show biometric unlock"]
```

## 5. KYC And Liveness

```mermaid
flowchart TD
  A["User starts KYC or risk step-up requires liveness"] --> B["FSM event: livenessRequired"]
  B --> C["POST /kyc/liveness/session with client capabilities"]
  C --> D{"Session created?"}
  D -- "No: KYC_PROVIDER_UNAVAILABLE" --> E["Manual review screen with SLA"]
  D -- "No: retryable network" --> F["Retry state with support option"]
  D -- "Yes" --> G["Read providerCapabilities and negotiatedCapabilities"]
  G --> H{"Required capture mode supported by device/client?"}
  H -- "No" --> E
  H -- "Yes" --> I["Open camera after permission granted"]
  I --> J{"Camera opened?"}
  J -- "No" --> K["Show permission/settings/retry, no dismiss-only dead end"]
  J -- "Yes" --> L["Capture required photo or video evidence"]
  L --> M["POST multipart /kyc/liveness/challenge"]
  M --> N{"More challenges?"}
  N -- "Yes" --> L
  N -- "No" --> O{"livenessProofId returned?"}
  O -- "Yes" --> P["POST /step-up/validate with livenessProofId"]
  O -- "No but simulator compatibility allowed" --> Q["Fallback to session token only for older API/simulator"]
  O -- "No in production" --> E
  P --> R{"Step-up accepted?"}
  Q --> R
  R -- "Yes" --> S["Return to calling flow"]
  R -- "No" --> E
```

```mermaid
flowchart LR
  A["Challenge"] --> B{"requiresMotionEvidence?"}
  B -- "No" --> C["Photo capture accepted"]
  B -- "Yes" --> D{"Client supports video or provider motion signal?"}
  D -- "Yes" --> E["Video or provider motion capture"]
  D -- "No" --> F["Manual review, do not fake motion with still photo"]
```

## 6. Home, Balance, And Pull To Refresh

```mermaid
flowchart TD
  A["/home entered"] --> B["FSM event: homeVisible"]
  B --> C["GET /wallet"]
  B --> D["GET /transactions or transaction summary"]
  B --> E["GET /user/limits"]
  C --> F{"Wallet response valid?"}
  F -- "Yes" --> G["Render balance with AmountText and money tokens"]
  F -- "No: empty/no wallet" --> H["Show create wallet or zero-state CTA"]
  F -- "No: API error" --> I["Show retryable balance error"]
  D --> J["Render recent transactions or empty state"]
  E --> K["Render permissions: canSend, canDeposit, canWithdraw"]
  L["User pulls to refresh"] --> M["Start refresh indicator"]
  M --> N["Refresh wallet, transactions, limits in bounded Future.wait"]
  N --> O{"All critical calls settled?"}
  O -- "Yes" --> P["Stop refresh indicator"]
  O -- "Timeout/error" --> Q["Stop refresh indicator and show scoped error"]
```

```mermaid
flowchart LR
  A["Money action button"] --> B{"Permission boolean true?"}
  B -- "Yes" --> C["Open flow"]
  B -- "No and reviewRequired" --> D["Manual review/SLA state"]
  B -- "No and blockReason" --> E["Show backend block reason"]
```

## 7. Send Money And Korido Account Identification

```mermaid
flowchart TD
  A["/send"] --> B["Select recipient source: phone, username, contact, QR"]
  B --> C["Normalize recipient identifier"]
  C --> D{"Identifier is current user?"}
  D -- "Yes" --> E["Block self-send with clear message"]
  D -- "No" --> F["Lookup Korido account"]
  F --> G{"Known Korido user?"}
  G -- "No" --> H["Invite/contact fallback if allowed"]
  G -- "Yes" --> I["Show verified Korido badge and recipient profile"]
  I --> J["Enter amount"]
  J --> K["GET /user/limits and transfer fee/availability when needed"]
  K --> L{"Limit and permission allow send?"}
  L -- "No" --> M["Show limit/review state"]
  L -- "Yes" --> N["Confirm screen"]
  N --> O["Require PIN"]
  O --> P["POST /risk/screen or /step-up/transaction if needed"]
  P --> Q{"Risk decision"}
  Q -- "Low" --> R["POST /wallet/transfer/internal"]
  Q -- "OTP" --> S["Step-up OTP then transfer"]
  Q -- "Liveness" --> T["Liveness then transfer"]
  Q -- "Manual review" --> U["Manual review state, no transfer"]
  R --> V["Compact success screen with receipt and share option"]
```

```mermaid
flowchart LR
  A["Recipient lookup"] --> B{"Source"}
  B -- "Phone" --> C["PhoneNumber value object"]
  B -- "Username" --> D["Username search"]
  B -- "Contact" --> E["Contact permission and normalized phones"]
  C --> F["Canonical account lookup"]
  D --> F
  E --> F
  F --> G{"Multiple matches?"}
  G -- "Yes" --> H["Require explicit user selection"]
  G -- "No" --> I["Use selected user id/account id"]
```

## 8. Contacts And Address Book Permissions

```mermaid
flowchart TD
  A["User opens contacts feature"] --> B["Check contacts permission"]
  B --> C{"Permission state"}
  C -- "Not requested" --> D["Show Korido rationale"]
  D --> E["Request OS contacts permission"]
  C -- "Denied" --> F["Show settings CTA and manual lookup"]
  C -- "Granted" --> G["Read phone contacts on device"]
  E --> H{"Granted?"}
  H -- "No" --> F
  H -- "Yes" --> G
  G --> I["Normalize each phone as PhoneNumber value object"]
  I --> J["POST /contacts/check or /contacts/sync in bounded batches"]
  J --> K["Render contact list"]
  K --> L{"Contact has Korido account?"}
  L -- "Yes" --> M["Show Korido badge and send CTA"]
  L -- "No" --> N["Show invite CTA"]
```

```mermaid
flowchart LR
  A["Bulk contact lookup"] --> B{"Server strategy"}
  B -- "Known numbers hashed/indexed" --> C["Fast indexed lookup"]
  B -- "Raw recursive upload required" --> D["Invalid for privacy and scale"]
  C --> E["Return minimal account presence and display metadata"]
```

## 9. Profile Photo Update

```mermaid
flowchart TD
  A["User taps change profile photo"] --> B["Request camera or photo permission"]
  B --> C{"Permission granted?"}
  C -- "No" --> D["Show settings CTA"]
  C -- "Yes" --> E["Capture or pick image"]
  E --> F["On-device face detection"]
  F --> G{"Exactly one face detected?"}
  G -- "No" --> H["Ask user to retake/select clearer image"]
  G -- "Yes" --> I["Compress/resample for low-end device safety"]
  I --> J["POST multipart /user/avatar"]
  J --> K{"Upload success?"}
  K -- "No" --> L["Show retryable profile error"]
  K -- "Yes" --> M["Update profile state with protected avatar URL"]
  M --> N["Render image through authenticated protected-media loader"]
```

```mermaid
flowchart LR
  A["Avatar URL"] --> B{"Shape"}
  B -- "Absolute URL" --> C["Use as origin-safe URL with auth headers when protected"]
  B -- "/user/avatar/:id" --> D["Resolve against API origin"]
  B -- "user/avatar/:id" --> D
  B -- "/api/..." --> E["Resolve against API host root"]
```

## 10. Notifications, Session Expiry, And Logout

```mermaid
flowchart TD
  A["App foreground authenticated"] --> B["Session manager timer"]
  B --> C{"Inactive threshold reached?"}
  C -- "No" --> A
  C -- "Yes" --> D["Show session expiring modal"]
  D --> E{"User action"}
  E -- "Stay logged in" --> F["Refresh session activity and dismiss modal"]
  E -- "Logout" --> G["POST /auth/logout"]
  E -- "Countdown expires" --> G
  G --> H["Clear tokens, PIN unlock state, user state"]
  H --> I["FSM event: loggedOut"]
  I --> J["/login, no back gesture to /home"]
```

```mermaid
flowchart LR
  A["Notification"] --> B{"Severity"}
  B -- "Info/success" --> C["Neutral/dark surface, readable text"]
  B -- "Warning" --> D["Warm accent, readable text"]
  B -- "Error/security" --> E["Error surface, high contrast text"]
  C --> F["Placement does not cover primary CTA"]
  D --> F
  E --> F
```

## 11. Devices And Backoffice Blacklist

```mermaid
flowchart TD
  A["App authenticated"] --> B["Register/update device"]
  B --> C["POST /devices/register and /risk/device/register"]
  C --> D["Device appears in settings devices"]
  D --> E{"User action"}
  E -- "Trust" --> F["POST /devices/:id/trust"]
  E -- "Untrust" --> G["POST /devices/:id/untrust"]
  E -- "Revoke" --> H["DELETE /devices/:id"]
  I["Backoffice admin blacklists device"] --> J["Device status set to blacklisted"]
  J --> K["Sessions for device revoked"]
  K --> L["Next mobile API call receives security/device block"]
  L --> M["FSM event: deviceBlacklisted"]
  M --> N["Security block screen, support path only"]
```

```mermaid
flowchart LR
  A["Device access decision"] --> B{"Device blacklisted?"}
  B -- "Yes" --> C["Block app access"]
  B -- "No" --> D{"Device trusted?"}
  D -- "Yes" --> E["Lower account-recovery risk"]
  D -- "No" --> F["Higher recovery/session risk"]
```

## 12. Staging Candidate Gate

```mermaid
flowchart TD
  A["Develop slice completed"] --> B["Focused verification: analyzer/build/test/API/simulator"]
  B --> C{"Known crash or dead end?"}
  C -- "Yes" --> D["Keep on develop, fix blocker"]
  C -- "No" --> E{"Core candidate paths pass?"}
  E -- "No" --> D
  E -- "Yes" --> F["Commit and push develop"]
  F --> G{"Mobile TestFlight candidate?"}
  G -- "No" --> H["Do not push mobile staging"]
  G -- "Yes" --> I["Run candidate checklist and version/build sanity"]
  I --> J["Promote develop -> staging"]
  J --> K["Codemagic builds TestFlight"]
```

```mermaid
flowchart LR
  A["Candidate paths"] --> B["Startup/login/OTP"]
  A --> C["PIN unlock/recovery"]
  A --> D["KYC/liveness/manual review"]
  A --> E["Home balance refresh"]
  A --> F["Send money"]
  A --> G["Contacts lookup"]
  A --> H["Profile photo"]
  A --> I["Notifications/session/logout"]
  A --> J["Devices/security block"]
```
