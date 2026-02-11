/// User-facing strings for feature-specific screens.
library;

abstract final class SavingsPotsStrings {
  static const title = 'Savings Pots';
  static const createPot = 'Create Pot';
  static const editPot = 'Edit Pot';
  static const deletePot = 'Delete Pot';
  static const deletePotConfirm = 'Are you sure you want to delete this pot? Funds will be returned to your wallet.';
  static const potName = 'Pot Name';
  static const potNameHint = 'e.g. Emergency Fund';
  static const targetAmount = 'Target Amount';
  static const addFunds = 'Add Funds';
  static const withdrawFunds = 'Withdraw Funds';
  static const potCreated = 'Pot created successfully';
  static const noPots = 'No savings pots yet';
  static const noPotsSubtitle = 'Create a pot to start saving toward your goals';
  static const progress = 'Progress';
  static const goalReached = 'Goal reached!';
}

abstract final class PaymentLinksStrings {
  static const title = 'Payment Links';
  static const createLink = 'Create Link';
  static const linkAmount = 'Amount';
  static const linkDescription = 'Description';
  static const linkDescriptionHint = 'What is this payment for?';
  static const linkCreated = 'Payment link created';
  static const shareLink = 'Share Link';
  static const copyLink = 'Copy Link';
  static const linkCopied = 'Link copied to clipboard';
  static const noLinks = 'No payment links yet';
  static const linkActive = 'Active';
  static const linkExpired = 'Expired';
  static const linkPaid = 'Paid';
  static const deactivateLink = 'Deactivate Link';
  static const linkDeactivated = 'Link deactivated';
}

abstract final class BillPaymentsStrings {
  static const title = 'Bill Payments';
  static const selectProvider = 'Select Provider';
  static const selectCategory = 'Select Category';
  static const accountNumber = 'Account Number';
  static const meterNumber = 'Meter Number';
  static const validateAccount = 'Validate Account';
  static const payBill = 'Pay Bill';
  static const billPaid = 'Bill paid successfully';
  static const paymentHistory = 'Payment History';
  static const noBills = 'No bill payments yet';
  static const processingFee = 'Processing Fee';
  static const receipt = 'Receipt';
  static const token = 'Token Number';
}

abstract final class CardsStrings {
  static const title = 'Virtual Cards';
  static const requestCard = 'Request Card';
  static const cardDetails = 'Card Details';
  static const cardNumber = 'Card Number';
  static const expiryDate = 'Expiry Date';
  static const cvv = 'CVV';
  static const freezeCard = 'Freeze Card';
  static const unfreezeCard = 'Unfreeze Card';
  static const cardFrozen = 'Card frozen';
  static const cardUnfrozen = 'Card unfrozen';
  static const cancelCard = 'Cancel Card';
  static const cancelCardConfirm = 'Are you sure? This cannot be undone.';
  static const noCards = 'No virtual cards yet';
  static const noCardsSubtitle = 'Request a virtual card for online payments';
  static const spendingLimit = 'Spending Limit';
  static const cardTransactions = 'Card Transactions';
}

abstract final class RecurringTransfersStrings {
  static const title = 'Recurring Transfers';
  static const create = 'Create Recurring Transfer';
  static const edit = 'Edit Recurring Transfer';
  static const pause = 'Pause';
  static const resume = 'Resume';
  static const cancel = 'Cancel Transfer';
  static const cancelConfirm = 'Are you sure you want to cancel this recurring transfer?';
  static const frequency = 'Frequency';
  static const daily = 'Daily';
  static const weekly = 'Weekly';
  static const biweekly = 'Every 2 Weeks';
  static const monthly = 'Monthly';
  static const startDate = 'Start Date';
  static const endDate = 'End Date (optional)';
  static const noRecurring = 'No recurring transfers';
  static const nextExecution = 'Next Execution';
  static const executionHistory = 'Execution History';
}

abstract final class ReferralsStrings {
  static const title = 'Referrals';
  static const referralCode = 'Your Referral Code';
  static const shareCode = 'Share Code';
  static const inviteFriends = 'Invite Friends';
  static const reward = 'You earn';
  static const rewardPerReferral = 'per successful referral';
  static const totalEarned = 'Total Earned';
  static const totalReferred = 'Friends Referred';
  static const leaderboard = 'Leaderboard';
  static const noReferrals = 'No referrals yet';
  static const noReferralsSubtitle = 'Share your code and earn rewards';
}

abstract final class BeneficiariesStrings {
  static const title = 'Beneficiaries';
  static const addBeneficiary = 'Add Beneficiary';
  static const editBeneficiary = 'Edit Beneficiary';
  static const deleteBeneficiary = 'Delete Beneficiary';
  static const deleteConfirm = 'Are you sure you want to delete this beneficiary?';
  static const name = 'Name';
  static const nameHint = 'Enter beneficiary name';
  static const walletAddress = 'Wallet Address';
  static const phoneNumber = 'Phone Number';
  static const noBeneficiaries = 'No saved beneficiaries';
  static const noBeneficiariesSubtitle = 'Save contacts for quick transfers';
  static const beneficiaryAdded = 'Beneficiary added';
  static const beneficiaryDeleted = 'Beneficiary removed';
}

abstract final class InsightsStrings {
  static const title = 'Spending Insights';
  static const thisWeek = 'This Week';
  static const thisMonth = 'This Month';
  static const last3Months = 'Last 3 Months';
  static const totalSpent = 'Total Spent';
  static const totalReceived = 'Total Received';
  static const byCategory = 'By Category';
  static const topRecipients = 'Top Recipients';
  static const spendingTrend = 'Spending Trend';
  static const noInsights = 'Not enough data for insights';
  static const noInsightsSubtitle = 'Start making transactions to see your spending patterns';
}
