import 'package:flutter/material.dart';

/// SupportCRM — App Shadows
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get none => [];

  static List<BoxShadow> get xs => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.06),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.07),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.04),
          blurRadius: 3,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get xl => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.10),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get modal => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.15),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 8),
        ),
      ];

  // Card hover shadow (slightly deeper)
  static List<BoxShadow> get cardHover => [
        BoxShadow(
          color: const Color(0xFF3B5BDB).withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  // Primary button glow
  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: const Color(0xFF3B5BDB).withOpacity(0.30),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
