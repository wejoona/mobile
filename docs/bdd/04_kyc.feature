# STATUS: ACTIVE
# Feature: KYC (Know Your Customer) Verification
# Screens: kyc_status_view, document_type_view, document_capture_view, kyc_personal_info_view, selfie_view, kyc_liveness_view, review_view, submitted_view, kyc_upgrade_view

@kyc @compliance @critical
Feature: KYC Identity Verification

  Background:
    Given the user is logged in
    And has an active wallet

  # ============================================
  # KYC STATUS OVERVIEW
  # ============================================

  @status
  Scenario: View KYC status - Tier 0 (Unverified)
    Given the user has not completed any KYC
    When they view KYC status
    Then they should see "Unverified" status
    And current limits (Tier 0)
    And "Start Verification" button

  @status
  Scenario: View KYC status - Tier 1 (Basic)
    Given the user completed Tier 1 KYC
    When they view KYC status
    Then they should see "Basic Verified" status
    And Tier 1 limits displayed
    And "Upgrade to Tier 2" option

  @status
  Scenario: View KYC status - Under Review
    Given the user submitted KYC documents
    When they view KYC status
    Then they should see "Under Review" status
    And estimated review time
    And submission date

  @status
  Scenario: View KYC status - Rejected
    Given the user's KYC was rejected
    When they view KYC status
    Then they should see "Rejected" status
    And reason for rejection
    And "Resubmit Documents" option

  @status
  Scenario: View KYC status - Expired
    Given the user's KYC documents have expired
    When they view KYC status
    Then they should see "Expired" status
    And "Renew Documents" option

  # ============================================
  # DOCUMENT TYPE SELECTION
  # ============================================

  @document-type
  Scenario: Select document type - Passport
    Given the user started KYC verification
    When they are on document type selection
    And they select "Passport"
    Then they should proceed to document capture
    And instructions for passport should show

  @document-type
  Scenario: Select document type - National ID
    Given the user is selecting document type
    When they select "National ID"
    Then they should proceed to capture
    And instructions for front and back should show

  @document-type
  Scenario: Select document type - Driver's License
    Given the user is selecting document type
    When they select "Driver's License"
    Then they should proceed to capture
    And instructions should be shown

  @document-type
  Scenario: Unsupported document type
    Given certain document types are not accepted
    Then they should be greyed out
    With message "Not accepted in your region"

  # ============================================
  # DOCUMENT CAPTURE
  # ============================================

  @document-capture
  Scenario: Capture document front
    Given the user selected National ID
    When they are prompted to capture front
    And they take a photo
    Then the system should analyze image quality
    And proceed if quality is acceptable

  @document-capture
  Scenario: Document image too blurry
    Given the user is capturing document
    When the image is blurry
    Then an error "Image is not clear. Please retake." should show
    And they should retake the photo

  @document-capture
  Scenario: Document not fully visible
    Given the user captured a document
    When edges are cut off
    Then an error "Document not fully visible" should show
    And guidance overlay should appear

  @document-capture
  Scenario: Glare detected on document
    Given the user captured a document
    When glare is detected
    Then a warning "Reduce glare. Adjust lighting." should show

  @document-capture
  Scenario: Capture document back
    Given the user captured the front of National ID
    When they proceed
    Then they should be prompted to capture the back
    And follow same quality checks

  @document-capture
  Scenario: Use existing photo from gallery
    Given the user has a document photo
    When they tap "Upload from Gallery"
    And select a photo
    Then the system should analyze the uploaded image

  # ============================================
  # PERSONAL INFORMATION
  # ============================================

  @personal-info
  Scenario: Enter personal information
    Given the user captured documents
    When they proceed to personal info
    Then they should enter:
      | Full name (as on document) |
      | Date of birth |
      | Nationality |
      | Gender |
    And fields may be pre-filled from document OCR

  @personal-info
  Scenario: Name mismatch warning
    Given OCR extracted name "John Smith"
    When user enters "Jon Smith"
    Then a warning "Name doesn't match document" should show
    And option to correct or confirm

  @personal-info
  Scenario: Underage user
    Given minimum age is 18
    When user enters DOB showing age 16
    Then an error "Must be 18 or older" should show
    And they cannot proceed

  # ============================================
  # SELFIE CAPTURE
  # ============================================

  @selfie
  Scenario: Capture selfie successfully
    Given the user completed personal info
    When they are prompted for selfie
    And they take a clear selfie
    Then face detection should succeed
    And they proceed to liveness check

  @selfie
  Scenario: Multiple faces detected
    Given the user is taking a selfie
    When multiple faces are detected
    Then an error "Only one person should be in frame" should show

  @selfie
  Scenario: No face detected
    Given the user took a photo
    When no face is detected
    Then an error "No face detected. Please try again." should show

  @selfie
  Scenario: Face not matching document
    Given the selfie face doesn't match document photo
    When system compares
    Then a warning should show
    And manual review may be required

  # ============================================
  # LIVENESS CHECK
  # ============================================

  @liveness
  Scenario: Complete liveness check
    Given the user is on liveness verification
    When they follow the prompts:
      | Turn head left |
      | Turn head right |
      | Blink |
    Then liveness should be verified
    And they proceed to review

  @liveness
  Scenario: Liveness check timeout
    Given the user started liveness check
    When they don't complete actions in 30 seconds
    Then a timeout error should show
    And option to retry

  @liveness
  Scenario: Liveness check failed - no movement
    Given the user didn't follow prompts
    Then an error "Please follow the instructions" should show
    And they should retry

  # ============================================
  # REVIEW & SUBMIT
  # ============================================

  @review
  Scenario: Review submission
    Given all KYC steps completed
    When user reaches review screen
    Then they should see:
      | Document images |
      | Personal information |
      | Selfie |
    And "Edit" option for each section
    And "Submit" button

  @review
  Scenario: Edit before submission
    Given user is reviewing submission
    When they tap "Edit" on personal info
    Then they should return to that step
    And make corrections

  @review
  Scenario: Submit for review
    Given all information is correct
    When user taps "Submit"
    Then submission should be sent to backend
    And they should see submitted_view

  # ============================================
  # POST-SUBMISSION
  # ============================================

  @submitted
  Scenario: View submission confirmation
    Given KYC was submitted
    When submitted_view shows
    Then they should see:
      | "Submitted Successfully" |
      | Estimated review time |
      | Reference number |
      | "Done" button |

  @submitted
  Scenario: Receive KYC approval
    Given KYC was under review
    When it gets approved
    Then user should receive push notification
    And status should update to approved
    And limits should increase

  @submitted
  Scenario: Receive KYC rejection
    Given KYC was under review
    When it gets rejected
    Then user should receive notification
    And see rejection reason
    And option to resubmit

  @submitted
  Scenario: Request manual review
    Given automatic verification failed
    When user sees failed result
    Then they can request manual review
    With additional notes if needed

  # ============================================
  # KYC TIER UPGRADE
  # ============================================

  @upgrade
  Scenario: Initiate Tier 2 upgrade
    Given user is Tier 1 verified
    When they tap "Upgrade to Tier 2"
    Then they should see additional requirements:
      | Address verification |
      | Video verification |
      | Additional documents |

  @upgrade
  Scenario: Address verification
    Given user is upgrading to Tier 2
    When they reach address verification
    Then they should provide:
      | Current address |
      | Proof of address document |
    And utility bill or bank statement

  @upgrade
  Scenario: Video verification
    Given Tier 2 requires video call
    When user reaches video step
    Then they should schedule a video call
    Or complete async video submission

  # ============================================
  # EDGE CASES
  # ============================================

  @edge-case
  Scenario: Camera permission denied
    Given camera permission is not granted
    When user tries to capture document
    Then they should see permission request
    And instructions to enable in settings

  @edge-case
  Scenario: Offline during KYC
    Given network is unavailable
    When user tries to submit KYC
    Then an error "No internet connection" should show
    And data should be saved locally
    And option to submit when online

  @edge-case
  Scenario: KYC session timeout
    Given user started KYC 30 minutes ago
    When they try to proceed
    Then they may need to re-authenticate
    And progress should be preserved

  @edge-case
  Scenario: Document OCR failed
    Given OCR couldn't extract data
    Then user should manually enter information
    And proceed normally
