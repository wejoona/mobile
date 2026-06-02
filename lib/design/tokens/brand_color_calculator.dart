import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Color utilities for transferring brand feeling across light and dark themes.
///
/// The logo color is derived in OKLCH so the hue/chroma of the dark-theme gold
/// survive the move to a light background. Raw RGB/HSL shifts drift too easily
/// into yellow or brown.
class BrandColorCalculator {
  BrandColorCalculator._();

  static Color deriveLightIdentityGold({
    required Color darkIdentityGold,
    required Color darkCanvas,
    required Color lightCanvas,
    double contrastCompression = 0.72,
    double minContrast = 2.0,
    double maxContrast = 2.35,
  }) {
    final darkContrast = contrastRatio(darkIdentityGold, darkCanvas);
    final targetContrast = _clampDouble(
      math.sqrt(darkContrast) * contrastCompression,
      minContrast,
      maxContrast,
    );
    final source = _oklchFromColor(darkIdentityGold);

    return _colorWithContrastOnLightBackground(
      hueRadians: source.hueRadians,
      chroma: source.chroma,
      background: lightCanvas,
      targetContrast: targetContrast,
    );
  }

  static List<Color> deriveLightIdentityGoldRamp({
    required Color baseGold,
    double highlightLightnessShift = 0.04,
    double highlightChromaScale = 0.9,
    double shadowLightnessShift = -0.05,
    double shadowChromaScale = 0.88,
  }) {
    final source = _oklchFromColor(baseGold);

    return [
      _colorFromOklch(
        lightness: _clampDouble(
          source.lightness + highlightLightnessShift,
          0,
          1,
        ),
        chroma: source.chroma * highlightChromaScale,
        hueRadians: source.hueRadians,
      ),
      baseGold,
      _colorFromOklch(
        lightness: _clampDouble(source.lightness + shadowLightnessShift, 0, 1),
        chroma: source.chroma * shadowChromaScale,
        hueRadians: source.hueRadians,
      ),
    ];
  }

  static double contrastRatio(Color foreground, Color background) {
    final foregroundLuminance = _relativeLuminance(foreground);
    final backgroundLuminance = _relativeLuminance(background);
    final lighter = math.max(foregroundLuminance, backgroundLuminance);
    final darker = math.min(foregroundLuminance, backgroundLuminance);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static String toHex(Color color) {
    final r = _toByte(color.r).toRadixString(16).padLeft(2, '0');
    final g = _toByte(color.g).toRadixString(16).padLeft(2, '0');
    final b = _toByte(color.b).toRadixString(16).padLeft(2, '0');
    return '#${r.toUpperCase()}${g.toUpperCase()}${b.toUpperCase()}';
  }

  static Color _colorWithContrastOnLightBackground({
    required double hueRadians,
    required double chroma,
    required Color background,
    required double targetContrast,
  }) {
    var low = 0.0;
    var high = 1.0;
    var candidate = _colorFromOklch(
      lightness: 0.75,
      chroma: chroma,
      hueRadians: hueRadians,
    );

    for (var i = 0; i < 42; i++) {
      final mid = (low + high) / 2;
      candidate = _colorFromOklch(
        lightness: mid,
        chroma: chroma,
        hueRadians: hueRadians,
      );
      final contrast = contrastRatio(candidate, background);

      if (contrast > targetContrast) {
        low = mid;
      } else {
        high = mid;
      }
    }

    return candidate;
  }

  static _Oklch _oklchFromColor(Color color) {
    final r = _srgbToLinear(color.r);
    final g = _srgbToLinear(color.g);
    final b = _srgbToLinear(color.b);

    final l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
    final m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
    final s = 0.0389862123 * r + 0.2817188376 * g + 0.6779980715 * b;

    final lRoot = _cubeRoot(l);
    final mRoot = _cubeRoot(m);
    final sRoot = _cubeRoot(s);

    final lightness =
        0.2104542553 * lRoot + 0.7936177850 * mRoot - 0.0040720468 * sRoot;
    final a =
        1.9779984951 * lRoot - 2.4285922050 * mRoot + 0.4505937099 * sRoot;
    final bAxis =
        0.0259040371 * lRoot + 0.7827717662 * mRoot - 0.8086757660 * sRoot;

    return _Oklch(
      lightness: lightness,
      chroma: math.sqrt(a * a + bAxis * bAxis),
      hueRadians: math.atan2(bAxis, a),
    );
  }

  static Color _colorFromOklch({
    required double lightness,
    required double chroma,
    required double hueRadians,
  }) {
    final a = chroma * math.cos(hueRadians);
    final b = chroma * math.sin(hueRadians);

    final lRoot = lightness + 0.3963377774 * a + 0.2158037573 * b;
    final mRoot = lightness - 0.1055613458 * a - 0.0638541728 * b;
    final sRoot = lightness - 0.0894841775 * a - 1.2914855480 * b;

    final l = lRoot * lRoot * lRoot;
    final m = mRoot * mRoot * mRoot;
    final s = sRoot * sRoot * sRoot;

    final red = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
    final green = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
    final blue = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;

    return Color.fromARGB(
      0xFF,
      _toByte(_linearToSrgb(red)),
      _toByte(_linearToSrgb(green)),
      _toByte(_linearToSrgb(blue)),
    );
  }

  static double _relativeLuminance(Color color) {
    final r = _srgbToLinear(color.r);
    final g = _srgbToLinear(color.g);
    final b = _srgbToLinear(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _srgbToLinear(double channel) {
    if (channel <= 0.04045) {
      return channel / 12.92;
    }
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  static double _linearToSrgb(double channel) {
    final clamped = _clampDouble(channel, 0, 1);
    if (clamped <= 0.0031308) {
      return 12.92 * clamped;
    }
    return 1.055 * math.pow(clamped, 1 / 2.4).toDouble() - 0.055;
  }

  static int _toByte(double channel) =>
      (_clampDouble(channel, 0, 1) * 255).round();

  static double _cubeRoot(double value) {
    if (value < 0) {
      return -math.pow(-value, 1 / 3).toDouble();
    }
    return math.pow(value, 1 / 3).toDouble();
  }

  static double _clampDouble(double value, double min, double max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }
}

class _Oklch {
  const _Oklch({
    required this.lightness,
    required this.chroma,
    required this.hueRadians,
  });

  final double lightness;
  final double chroma;
  final double hueRadians;
}
