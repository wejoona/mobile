import 'package:flutter/material.dart';

/// Design system spacing tokens.
class AppSpacing {
  AppSpacing._();

  // Base unit: 4px
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 40.0;
  static const massive = 48.0;
  static const giant = 64.0;

  // Common paddings
  static const pagePadding = EdgeInsets.symmetric(horizontal: lg);
  static const cardPadding = EdgeInsets.all(lg);
  static const sectionPadding = EdgeInsets.symmetric(vertical: xl);
  static const listItemPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const inputPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const chipPadding =
      EdgeInsets.symmetric(horizontal: md, vertical: xs);
  static const bottomSheetPadding = EdgeInsets.fromLTRB(lg, sm, lg, lg);

  // Vertical gaps
  static const gapXs = SizedBox(height: xs);
  static const gapSm = SizedBox(height: sm);
  static const gapMd = SizedBox(height: md);
  static const gapLg = SizedBox(height: lg);
  static const gapXl = SizedBox(height: xl);
  static const gapXxl = SizedBox(height: xxl);
  static const gapXxxl = SizedBox(height: xxxl);

  // Horizontal gaps
  static const hGapXs = SizedBox(width: xs);
  static const hGapSm = SizedBox(width: sm);
  static const hGapMd = SizedBox(width: md);
  static const hGapLg = SizedBox(width: lg);
  static const hGapXl = SizedBox(width: xl);
}
