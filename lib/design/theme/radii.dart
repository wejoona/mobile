import 'package:flutter/material.dart';

/// Design system border radius tokens.
class AppRadii {
  AppRadii._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const full = 999.0;

  // BorderRadius presets
  static final borderXs = BorderRadius.circular(xs);
  static final borderSm = BorderRadius.circular(sm);
  static final borderMd = BorderRadius.circular(md);
  static final borderLg = BorderRadius.circular(lg);
  static final borderXl = BorderRadius.circular(xl);
  static final borderXxl = BorderRadius.circular(xxl);
  static final borderFull = BorderRadius.circular(full);

  // Bottom sheet top radius
  static final bottomSheet = const BorderRadius.vertical(
    top: Radius.circular(lg),
  );
}
