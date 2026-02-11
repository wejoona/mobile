/// Centralized semantic labels for accessibility.
/// Used across all feature views for consistent screen reader support.
library;

abstract final class A11yLabels {
  // Navigation
  static const home = 'Home';
  static const back = 'Go back';
  static const close = 'Close';
  static const menu = 'Menu';
  static const search = 'Search';
  static const filter = 'Filter';
  static const sort = 'Sort';
  static const refresh = 'Refresh';
  static const more = 'More options';
  static const settings = 'Settings';
  static const notifications = 'Notifications';

  // Actions
  static const send = 'Send money';
  static const receive = 'Receive money';
  static const deposit = 'Deposit funds';
  static const withdraw = 'Withdraw funds';
  static const scan = 'Scan QR code';
  static const share = 'Share';
  static const copy = 'Copy to clipboard';
  static const edit = 'Edit';
  static const delete = 'Delete';
  static const add = 'Add';
  static const remove = 'Remove';
  static const retry = 'Retry';
  static const confirm = 'Confirm';
  static const cancel = 'Cancel';

  // Status
  static const loading = 'Loading';
  static const error = 'Error';
  static const success = 'Success';
  static const pending = 'Pending';
  static const failed = 'Failed';
  static const completed = 'Completed';

  // Wallet
  static const balanceVisible = 'Balance visible';
  static const balanceHidden = 'Balance hidden';
  static const toggleBalance = 'Toggle balance visibility';
  static const walletAddress = 'Wallet address';
  static const qrCode = 'QR code';
  static const transactionItem = 'Transaction';

  // Cards
  static const virtualCard = 'Virtual card';
  static const cardNumber = 'Card number';
  static const cardFrozen = 'Card is frozen';
  static const cardActive = 'Card is active';
  static const freezeCard = 'Freeze card';
  static const unfreezeCard = 'Unfreeze card';

  // Forms
  static const phoneInput = 'Phone number input';
  static const amountInput = 'Amount input';
  static const pinInput = 'PIN input';
  static const noteInput = 'Note input';
  static const searchInput = 'Search input';

  // Icons
  static const sendIcon = 'Send';
  static const receiveIcon = 'Receive';
  static const depositIcon = 'Deposit';
  static const withdrawIcon = 'Withdraw';
  static const billPayIcon = 'Pay bills';
  static const savingsIcon = 'Savings';
  static const cardsIcon = 'Cards';
  static const insightsIcon = 'Insights';
  static const referralIcon = 'Referrals';
  static const helpIcon = 'Help';
  static const securityIcon = 'Security';
  static const profileIcon = 'Profile';
  static const checkIcon = 'Checkmark';
  static const warningIcon = 'Warning';
  static const infoIcon = 'Information';
  static const errorIcon = 'Error';
}
