/// User-facing strings for wallet and transaction flows.
library;

abstract final class WalletStrings {
  // Balance
  static const balance = 'Balance';
  static const availableBalance = 'Available Balance';
  static const hideBalance = 'Hide Balance';
  static const showBalance = 'Show Balance';
  static const walletAddress = 'Wallet Address';

  // Actions
  static const send = 'Send';
  static const receive = 'Receive';
  static const deposit = 'Deposit';
  static const withdraw = 'Withdraw';
  static const scan = 'Scan';
  static const requestMoney = 'Request Money';

  // Send
  static const sendTitle = 'Send USDC';
  static const recipientLabel = 'Recipient';
  static const recipientHint = 'Phone number or wallet address';
  static const amountLabel = 'Amount';
  static const amountHint = 'Enter amount';
  static const noteLabel = 'Note (optional)';
  static const noteHint = 'What is this for?';
  static const networkFee = 'Network Fee';
  static const totalAmount = 'Total Amount';
  static const sendConfirmTitle = 'Confirm Transfer';
  static const sendSuccess = 'Transfer sent successfully';
  static const sendFailed = 'Transfer failed. Please try again.';

  // Receive
  static const receiveTitle = 'Receive USDC';
  static const shareAddress = 'Share Address';
  static const copyAddress = 'Copy Address';
  static const addressCopied = 'Address copied to clipboard';
  static const qrCodeLabel = 'Scan QR code to send USDC';

  // Deposit
  static const depositTitle = 'Deposit';
  static const depositMethod = 'Select Deposit Method';
  static const mobileMoney = 'Mobile Money';
  static const bankTransfer = 'Bank Transfer';
  static const depositInstructions = 'Follow the instructions below to complete your deposit';
  static const depositPending = 'Deposit Pending';
  static const depositComplete = 'Deposit Complete';
  static const depositFailed = 'Deposit Failed';
  static const processingTime = 'Processing Time';

  // Withdraw
  static const withdrawTitle = 'Withdraw';
  static const withdrawMethod = 'Select Withdrawal Method';
  static const withdrawSuccess = 'Withdrawal initiated successfully';
  static const withdrawFailed = 'Withdrawal failed. Please try again.';

  // Transactions
  static const transactions = 'Transactions';
  static const recentTransactions = 'Recent Transactions';
  static const allTransactions = 'All Transactions';
  static const noTransactions = 'No transactions yet';
  static const transactionDetail = 'Transaction Details';
  static const transactionId = 'Transaction ID';
  static const status = 'Status';
  static const date = 'Date';
  static const from = 'From';
  static const to = 'To';
  static const amount = 'Amount';
  static const fee = 'Fee';
  static const filterTransactions = 'Filter';
  static const exportTransactions = 'Export';

  // Status
  static const statusPending = 'Pending';
  static const statusCompleted = 'Completed';
  static const statusFailed = 'Failed';
  static const statusCancelled = 'Cancelled';
  static const statusProcessing = 'Processing';
}
