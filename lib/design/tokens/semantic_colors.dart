import 'package:flutter/material.dart';

/// Semantic color tokens for financial operations
class SemanticColors {
  // Money in (deposits, received)
  static const Color moneyIn = Color(0xFF16A34A);       // green-600
  static const Color moneyInLight = Color(0xFFDCFCE7);  // green-100
  
  // Money out (transfers, withdrawals)
  static const Color moneyOut = Color(0xFFDC2626);       // red-600
  static const Color moneyOutLight = Color(0xFFFEE2E2);  // red-100
  
  // Pending operations
  static const Color pending = Color(0xFFF59E0B);        // amber-500
  static const Color pendingLight = Color(0xFFFEF3C7);   // amber-100
  
  // Info/neutral
  static const Color info = Color(0xFF3B82F6);           // blue-500
  static const Color infoLight = Color(0xFFDBEAFE);      // blue-100
  
  // Success
  static const Color success = Color(0xFF22C55E);        // green-500
  static const Color successLight = Color(0xFFF0FDF4);   // green-50
  
  // Warning
  static const Color warning = Color(0xFFEAB308);        // yellow-500
  static const Color warningLight = Color(0xFFFEFCE8);   // yellow-50
  
  // Error
  static const Color error = Color(0xFFEF4444);          // red-500
  static const Color errorLight = Color(0xFFFEF2F2);     // red-50
  
  /// Get color for transaction type
  static Color forTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
      case 'received':
        return moneyIn;
      case 'withdrawal':
      case 'sent':
      case 'transfer':
        return moneyOut;
      case 'pending':
        return pending;
      default:
        return info;
    }
  }
  
  /// Get background color for transaction type
  static Color backgroundForTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
      case 'received':
        return moneyInLight;
      case 'withdrawal':
      case 'sent':
      case 'transfer':
        return moneyOutLight;
      case 'pending':
        return pendingLight;
      default:
        return infoLight;
    }
  }
}
