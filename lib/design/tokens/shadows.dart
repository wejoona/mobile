import 'package:flutter/material.dart';
import 'colors.dart';

/// Shadow System for Elevation
/// Shadows adapt to light/dark themes - use theme-aware getters when possible
class AppShadows {
  AppShadows._();

  // ═══════════════════════════════════════════════════════════════════════════
  // STANDARD SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> get none => [];

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.4),
          blurRadius: 6,
          offset: const Offset(0, 4),
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha:0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.5),
          blurRadius: 15,
          offset: const Offset(0, 10),
          spreadRadius: -3,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha:0.4),
          blurRadius: 6,
          offset: const Offset(0, 4),
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> get xl => [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.5),
          blurRadius: 25,
          offset: const Offset(0, 20),
          spreadRadius: -5,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha:0.4),
          blurRadius: 10,
          offset: const Offset(0, 8),
          spreadRadius: -6,
        ),
      ];

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.4),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha:0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardHover => [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.5),
          blurRadius: 48,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha:0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // ═══════════════════════════════════════════════════════════════════════════
  // GLOW EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: AppColors.gold500.withValues(alpha:0.3),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get goldGlowStrong => [
        BoxShadow(
          color: AppColors.gold500.withValues(alpha:0.4),
          blurRadius: 40,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get successGlow => [
        BoxShadow(
          color: AppColors.successBase.withValues(alpha:0.3),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get errorGlow => [
        BoxShadow(
          color: AppColors.errorBase.withValues(alpha:0.3),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT MODE SHADOWS (lighter opacity for better contrast on light backgrounds)
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> get lightSm => [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get lightMd => [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.08),
          blurRadius: 6,
          offset: const Offset(0, 4),
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha:0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> get lightLg => [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.12),
          blurRadius: 15,
          offset: const Offset(0, 10),
          spreadRadius: -3,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha:0.06),
          blurRadius: 6,
          offset: const Offset(0, 4),
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> get lightXl => [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.14),
          blurRadius: 25,
          offset: const Offset(0, 20),
          spreadRadius: -5,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha:0.08),
          blurRadius: 10,
          offset: const Offset(0, 8),
          spreadRadius: -6,
        ),
      ];

  static List<BoxShadow> get lightCard => [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha:0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
}
