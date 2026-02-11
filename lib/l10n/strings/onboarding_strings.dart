/// User-facing strings for onboarding and KYC flows.
library;

abstract final class OnboardingStrings {
  static const welcome = 'Welcome to Korido';
  static const welcomeSubtitle = 'Your USDC wallet for West Africa';

  // Pages
  static const page1Title = 'Send Money Instantly';
  static const page1Subtitle = 'Transfer USDC to anyone in West Africa in seconds';
  static const page2Title = 'Pay Bills Easily';
  static const page2Subtitle = 'Pay for airtime, electricity, and more with USDC';
  static const page3Title = 'Save & Grow';
  static const page3Subtitle = 'Create savings pots and track your spending';

  // Registration
  static const getStarted = 'Get Started';
  static const alreadyHaveAccount = 'Already have an account?';
  static const countrySelect = 'Select Your Country';
  static const phoneInput = 'Enter Your Phone Number';
  static const phoneInputSubtitle = 'We will send you a verification code';
  static const profileSetup = 'Set Up Your Profile';
  static const firstNameLabel = 'First Name';
  static const lastNameLabel = 'Last Name';
  static const emailLabel = 'Email (optional)';
  static const createPinTitle = 'Create a PIN';
  static const createPinSubtitle = 'Choose a 4-digit PIN to secure your wallet';
  static const confirmPinTitle = 'Confirm Your PIN';
  static const registrationSuccess = 'Account created successfully!';
  static const firstDepositPrompt = 'Make your first deposit to get started';

  // KYC prompts
  static const verifyIdentity = 'Verify Your Identity';
  static const verifyIdentitySubtitle = 'Complete verification to unlock higher limits';
  static const laterButton = 'I\'ll do this later';
}

abstract final class KycStrings {
  static const title = 'Identity Verification';
  static const tier1 = 'Basic';
  static const tier1Description = 'Phone verification - up to 500 USDC/day';
  static const tier2 = 'Standard';
  static const tier2Description = 'ID document - up to 5,000 USDC/day';
  static const tier3 = 'Premium';
  static const tier3Description = 'Full verification - unlimited';

  // Document
  static const selectDocument = 'Select Document Type';
  static const nationalId = 'National ID';
  static const passport = 'Passport';
  static const driversLicense = 'Driver\'s License';
  static const captureDocument = 'Capture Document';
  static const captureDocumentInstructions = 'Place your document within the frame and take a clear photo';
  static const frontSide = 'Front Side';
  static const backSide = 'Back Side';
  static const retake = 'Retake';
  static const usePhoto = 'Use Photo';

  // Personal info
  static const personalInfo = 'Personal Information';
  static const dateOfBirth = 'Date of Birth';
  static const address = 'Address';
  static const city = 'City';
  static const region = 'Region/State';
  static const postalCode = 'Postal Code';

  // Selfie/Liveness
  static const selfieTitle = 'Take a Selfie';
  static const selfieInstructions = 'Look directly at the camera in a well-lit area';
  static const livenessTitle = 'Liveness Check';
  static const livenessInstructions = 'Follow the on-screen instructions to verify your identity';

  // Review
  static const reviewTitle = 'Review Your Information';
  static const reviewSubtitle = 'Make sure everything is correct before submitting';
  static const submitVerification = 'Submit Verification';
  static const verificationSubmitted = 'Verification Submitted';
  static const verificationSubmittedSubtitle = 'We will review your documents and notify you within 24 hours';
  static const verificationPending = 'Under Review';
  static const verificationApproved = 'Verified';
  static const verificationRejected = 'Verification Rejected';
  static const verificationRejectedSubtitle = 'Please review and resubmit your documents';
}
