/// Common user-facing strings for localization prep.
/// All strings are centralized here for future l10n extraction.
library;

abstract final class CommonStrings {
  // General
  static const appName = 'Korido';
  static const tagline = 'USDC Wallet for West Africa';
  static const ok = 'OK';
  static const cancel = 'Cancel';
  static const confirm = 'Confirm';
  static const done = 'Done';
  static const next = 'Next';
  static const back = 'Back';
  static const close = 'Close';
  static const save = 'Save';
  static const edit = 'Edit';
  static const delete = 'Delete';
  static const remove = 'Remove';
  static const retry = 'Retry';
  static const loading = 'Loading...';
  static const search = 'Search';
  static const noResults = 'No results found';
  static const seeAll = 'See All';
  static const viewAll = 'View All';
  static const submit = 'Submit';
  static const apply = 'Apply';
  static const reset = 'Reset';
  static const refresh = 'Pull to refresh';
  static const share = 'Share';
  static const copy = 'Copy';
  static const copied = 'Copied to clipboard';
  static const yes = 'Yes';
  static const no = 'No';
  static const continueText = 'Continue';
  static const skip = 'Skip';

  // Errors
  static const genericError = 'Something went wrong. Please try again.';
  static const networkError = 'No internet connection. Please check your network.';
  static const timeoutError = 'Request timed out. Please try again.';
  static const serverError = 'Server error. Please try again later.';
  static const sessionExpired = 'Your session has expired. Please log in again.';
  static const unauthorized = 'You are not authorized to perform this action.';
  static const notFound = 'The requested resource was not found.';
  static const rateLimited = 'Too many requests. Please wait and try again.';
  static const maintenanceMode = 'Korido is under maintenance. Please try again later.';

  // Validation
  static const fieldRequired = 'This field is required';
  static const invalidEmail = 'Please enter a valid email address';
  static const invalidPhone = 'Please enter a valid phone number';
  static const invalidAmount = 'Please enter a valid amount';
  static const amountTooLow = 'Amount is below the minimum';
  static const amountTooHigh = 'Amount exceeds the maximum';
  static const insufficientBalance = 'Insufficient balance';
  static const invalidPin = 'Please enter a valid PIN';
  static const pinMismatch = 'PINs do not match';
  static const invalidAddress = 'Please enter a valid wallet address';
}
