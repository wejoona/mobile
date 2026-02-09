# STATUS: ACTIVE
# KYC Flow Feature - BDD Specifications

## Overview
Know Your Customer (KYC) verification flow for identity verification.

## Screens Covered
- `/kyc` - KYC Status View
- `/kyc/document-type` - Document Type Selection
- `/kyc/personal-info` - Personal Information
- `/kyc/document-capture` - Document Capture
- `/kyc/selfie` - Selfie Capture
- `/kyc/liveness` - Liveness Check
- `/kyc/review` - Review & Submit
- `/kyc/submitted` - Submission Confirmation

---

## Feature: KYC Status

### Screen: KycStatusView
**File:** `lib/features/kyc/views/kyc_status_view.dart`
**Route:** `/kyc`

```gherkin
Feature: KYC Status Display

  Background:
    Given I am authenticated
    And I am on the KYC status screen

  @smoke @kyc @status
  Scenario: Display pending status
    Given my KYC status is "pending" or "none"
    Then I should see gold verification icon
    And I should see "Identity Verification Required" title
    And I should see description about verification
    And I should see info cards:
      | Icon     | Title           | Description              |
      | security | Bank-Level      | Secure data handling     |
      | timer    | Quick Process   | Takes about 5 minutes    |
      | document | Documents       | ID + Selfie required     |
    And I should see "Start Verification" button

  @kyc @status @submitted
  Scenario: Display submitted status
    Given my KYC status is "submitted"
    Then I should see hourglass/pending icon
    And I should see "Under Review" title
    And I should see "We'll notify you within 24 hours"
    And I should see "Continue" button

  @kyc @status @verified
  Scenario: Display verified status
    Given my KYC status is "verified"
    Then I should see green checkmark icon
    And I should see "Identity Verified" title
    And I should see verification completion date
    And "Start Verification" button should not appear

  @kyc @status @rejected
  Scenario: Display rejected status
    Given my KYC status is "rejected"
    And rejection reason is "Document quality too low"
    Then I should see red error icon
    And I should see "Verification Failed" title
    And I should see rejection reason card with:
      | Field  | Value                    |
      | Title  | Rejection Reason         |
      | Reason | Document quality too low |
    And I should see "Try Again" button

  @kyc @status @action
  Scenario: Start verification
    Given my status allows verification
    When I tap "Start Verification"
    Then I should navigate to "/kyc/document-type"

  @kyc @status @continue
  Scenario: Continue to home from submitted
    Given my KYC status is "submitted"
    When I tap "Continue"
    Then I should navigate to "/home"
```

---

## Feature: Document Type Selection

### Screen: DocumentTypeView
**File:** `lib/features/kyc/views/document_type_view.dart`
**Route:** `/kyc/document-type`

```gherkin
Feature: Select Document Type

  Background:
    Given I have started KYC verification
    And I am on document type selection

  @smoke @kyc @document_type
  Scenario: Display document options
    Then I should see "Choose Document Type" title
    And I should see document type cards:
      | Type           | Icon      | Description                |
      | National ID    | card      | Government-issued ID       |
      | Passport       | book      | International passport     |
      | Driver License | car       | Valid driver's license     |
    And I should see "Continue" button (disabled)

  @kyc @document_type @select
  Scenario: Select document type
    When I tap "National ID" card
    Then it should be highlighted/selected
    And "Continue" button should be enabled

  @kyc @document_type @continue
  Scenario: Continue to personal info
    Given I have selected "National ID"
    When I tap "Continue"
    Then document type should be saved
    And I should navigate to "/kyc/personal-info"
```

---

## Feature: Personal Information

### Screen: KycPersonalInfoView
**File:** `lib/features/kyc/views/kyc_personal_info_view.dart`
**Route:** `/kyc/personal-info`

```gherkin
Feature: Enter Personal Information

  Background:
    Given I have selected document type
    And I am on personal info screen

  @smoke @kyc @personal_info
  Scenario: Display personal info form
    Then I should see "Personal Information" title
    And I should see form fields:
      | Field       | Type       | Required |
      | First Name  | text       | Yes      |
      | Last Name   | text       | Yes      |
      | Date of Birth | date     | Yes      |
      | Nationality | dropdown   | Yes      |
      | Address     | text       | No       |
    And I should see "Continue" button

  @kyc @personal_info @validation
  Scenario: Validate required fields
    When I leave required fields empty
    And tap "Continue"
    Then I should see validation errors on empty fields

  @kyc @personal_info @dob
  Scenario: Date of birth validation
    When I select date of birth less than 18 years ago
    Then I should see "Must be at least 18 years old" error

  @kyc @personal_info @continue
  Scenario: Continue to document capture
    Given all required fields are filled
    When I tap "Continue"
    Then personal info should be saved
    And I should navigate to "/kyc/document-capture"
```

---

## Feature: Document Capture

### Screen: DocumentCaptureView
**File:** `lib/features/kyc/views/document_capture_view.dart`
**Route:** `/kyc/document-capture`

```gherkin
Feature: Capture Document Images

  Background:
    Given I have entered personal info
    And I am on document capture screen

  @smoke @kyc @document_capture
  Scenario: Display capture instructions
    Then I should see "Capture Your Document" title
    And I should see camera viewfinder with document frame overlay
    And I should see "Capture front of ID" instruction
    And I should see capture button

  @kyc @document_capture @front
  Scenario: Capture document front
    When I position document within frame
    And tap capture button
    Then photo should be taken
    And I should see preview with:
      - "Retake" button
      - "Use This Photo" button

  @kyc @document_capture @retake
  Scenario: Retake photo
    Given I have captured front
    When I tap "Retake"
    Then camera should reopen
    And I can capture again

  @kyc @document_capture @back
  Scenario: Capture document back
    Given I have confirmed front image
    Then instruction should change to "Capture back of ID"
    When I capture back image
    And confirm it
    Then I should navigate to "/kyc/selfie"

  @kyc @document_capture @quality
  Scenario: Document quality check
    Given captured image is blurry
    Then I should see "Image quality too low" warning
    And suggestion to retake
```

---

## Feature: Selfie Capture

### Screen: SelfieView
**File:** `lib/features/kyc/views/selfie_view.dart`
**Route:** `/kyc/selfie`

```gherkin
Feature: Capture Selfie

  Background:
    Given I have captured document images
    And I am on selfie capture screen

  @smoke @kyc @selfie
  Scenario: Display selfie capture
    Then I should see "Take a Selfie" title
    And I should see front camera viewfinder with face frame
    And I should see instructions:
      - "Position your face within the frame"
      - "Ensure good lighting"
      - "Remove glasses if possible"

  @kyc @selfie @capture
  Scenario: Capture selfie
    When I position face within frame
    And tap capture button
    Then selfie should be taken
    And I should see preview

  @kyc @selfie @continue
  Scenario: Continue to liveness
    Given I have confirmed selfie
    When I tap "Continue"
    Then I should navigate to "/kyc/liveness"
```

---

## Feature: Liveness Check

### Screen: KycLivenessView
**File:** `lib/features/kyc/views/kyc_liveness_view.dart`
**Route:** `/kyc/liveness`

```gherkin
Feature: Liveness Verification

  Background:
    Given I have captured selfie
    And I am on liveness check screen

  @smoke @kyc @liveness
  Scenario: Display liveness prompts
    Then I should see "Liveness Check" title
    And I should see camera with face frame
    And I should see animated instruction prompts

  @kyc @liveness @actions
  Scenario: Follow liveness prompts
    Then I should be prompted to:
      | Action        | Instruction         |
      | Look left     | "Turn head left"    |
      | Look right    | "Turn head right"   |
      | Blink         | "Blink your eyes"   |
      | Smile         | "Smile" (optional)  |

  @kyc @liveness @success
  Scenario: Complete liveness check
    Given I have completed all prompts
    Then I should see "Liveness Verified" message
    And I should navigate to "/kyc/review"

  @kyc @liveness @failure
  Scenario: Failed liveness check
    Given I don't complete prompts correctly
    Then I should see "Let's try again" message
    And prompts should restart
```

---

## Feature: Review & Submit

### Screen: ReviewView
**File:** `lib/features/kyc/views/review_view.dart`
**Route:** `/kyc/review`

```gherkin
Feature: Review KYC Submission

  Background:
    Given I have completed all capture steps
    And I am on review screen

  @smoke @kyc @review
  Scenario: Display review summary
    Then I should see "Review Your Information" title
    And I should see sections:
      | Section           | Content                  |
      | Personal Info     | Name, DOB, Nationality   |
      | Document Type     | National ID              |
      | Document Front    | Thumbnail preview        |
      | Document Back     | Thumbnail preview        |
      | Selfie            | Thumbnail preview        |
    And I should see "Submit" button

  @kyc @review @edit
  Scenario: Edit information
    When I tap "Edit" on Personal Info section
    Then I should navigate back to personal info screen

  @kyc @review @submit
  Scenario: Submit KYC
    When I tap "Submit"
    Then I should see loading indicator
    And POST /kyc/submit should be called
    And on success, I should navigate to "/kyc/submitted"

  @kyc @review @error
  Scenario: Submission error
    Given submission fails
    Then I should see error message
    And I should have option to retry
```

---

## Feature: Submission Confirmation

### Screen: SubmittedView
**File:** `lib/features/kyc/views/submitted_view.dart`
**Route:** `/kyc/submitted`

```gherkin
Feature: KYC Submission Confirmation

  Background:
    Given I have submitted KYC
    And I am on submitted confirmation screen

  @smoke @kyc @submitted
  Scenario: Display confirmation
    Then I should see success animation/icon
    And I should see "Documents Submitted!" title
    And I should see "We'll review your documents and notify you within 24 hours"
    And I should see "Continue" button

  @kyc @submitted @continue
  Scenario: Navigate to home
    When I tap "Continue"
    Then I should navigate to "/home"
```

---

## State Management

### KycProvider State
```dart
class KycState {
  final KycStatus status;
  final String? rejectionReason;
  final DocumentType? documentType;
  final PersonalInfo? personalInfo;
  final String? documentFrontPath;
  final String? documentBackPath;
  final String? selfiePath;
  final bool livenessVerified;
  final bool isSubmitting;
  final String? error;
}
```

---

## API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/kyc/status` | GET | Get current status |
| `/kyc/documents` | POST | Upload document images |
| `/kyc/selfie` | POST | Upload selfie |
| `/kyc/liveness` | POST | Submit liveness data |
| `/kyc/submit` | POST | Submit full KYC package |

---

## Golden Test Variations

### Status Screen
1. Pending/None status
2. Submitted status
3. Verified status
4. Rejected status with reason

### Document Type
1. No selection
2. National ID selected
3. Passport selected
4. Driver License selected

### Personal Info
1. Empty form
2. Partially filled
3. Validation errors
4. Complete form

### Document Capture
1. Front capture instruction
2. Back capture instruction
3. Preview state
4. Quality warning

### Selfie
1. Initial state
2. Face detected
3. Preview state

### Liveness
1. Initial prompt
2. In-progress prompt
3. Success state

### Review
1. Full summary view

### Submitted
1. Confirmation state

---

*Part of USDC Wallet Complete Testing Suite*
