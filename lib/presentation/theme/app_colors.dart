import 'package:flutter/material.dart';

/// Soft & cute pastel palette: mint greens, butter yellows, sky
/// blues, and soft lavender. No pink, no romantic framing.
class AppColors {
  AppColors._();

  static const Color mint = Color(0xFFB8ECD9);
  static const Color mintDark = Color(0xFF6FCBA6);
  static const Color butterYellow = Color(0xFFFDEDB0);
  static const Color skyBlue = Color(0xFFBFE3F5);
  static const Color lavender = Color(0xFFD9CFF2);

  static const Color background = Color(0xFFF7FBF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2E3A38);
  static const Color textSecondary = Color(0xFF6C7A77);

  static const List<Color> ringingGradient = [
    skyBlue,
    mint,
    lavender,
  ];

  static const List<Color> homeGradient = [
    background,
    Color(0xFFEFF8F2),
  ];
}
