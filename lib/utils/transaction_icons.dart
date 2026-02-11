import 'package:flutter/material.dart';

/// Get icon for transaction type
IconData transactionIcon(String type) {
  switch (type.toLowerCase()) {
    case 'deposit':
      return Icons.arrow_downward_rounded;
    case 'withdrawal':
      return Icons.arrow_upward_rounded;
    case 'transfer':
    case 'sent':
      return Icons.send_rounded;
    case 'received':
      return Icons.call_received_rounded;
    case 'payment':
      return Icons.shopping_cart_rounded;
    case 'bill_payment':
      return Icons.receipt_long_rounded;
    case 'refund':
      return Icons.replay_rounded;
    default:
      return Icons.swap_horiz_rounded;
  }
}

/// Get label for transaction type
String transactionLabel(String type) {
  switch (type.toLowerCase()) {
    case 'deposit': return 'Deposit';
    case 'withdrawal': return 'Withdrawal';
    case 'transfer': return 'Transfer';
    case 'sent': return 'Sent';
    case 'received': return 'Received';
    case 'payment': return 'Payment';
    case 'bill_payment': return 'Bill Payment';
    case 'refund': return 'Refund';
    default: return type;
  }
}
