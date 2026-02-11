import 'package:flutter/material.dart';

/// Design system shadow tokens.
class AppShadows {
  AppShadows._();

  /// Subtle shadow for cards.
  static const card = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Medium elevation shadow.
  static const elevated = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Strong shadow for modals, FABs.
  static const modal = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Bottom sheet shadow.
  static const bottomSheet = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, -4),
    ),
  ];

  /// Glow effect for primary buttons.
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// No shadow.
  static const none = <BoxShadow>[];
}
