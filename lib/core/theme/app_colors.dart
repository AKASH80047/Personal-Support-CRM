import 'package:flutter/material.dart';

/// SupportCRM — App Colors
/// Ultra-premium SaaS design system tokens.
class AppColors {
  AppColors._();

  // ─── Brand ───────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4F46E5);         // Indigo-600
  static const Color primaryLight = Color(0xFF6366F1);    // Indigo-500
  static const Color primaryDark = Color(0xFF3730A3);     // Indigo-800
  static const Color primarySurface = Color(0xFFEEF2FF);  // Indigo-50

  static const Color secondary = Color(0xFF7C3AED);       // Violet-600
  static const Color secondaryLight = Color(0xFF8B5CF6);  // Violet-500
  static const Color secondarySurface = Color(0xFFF5F3FF);// Violet-50

  static const Color accent = Color(0xFF06B6D4);          // Cyan-500
  static const Color accentSurface = Color(0xFFECFEFF);   // Cyan-50

  // ─── Neutrals ────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0F172A);

  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);
  static const Color neutral950 = Color(0xFF0B0F19);

  // ─── Status ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);         // Emerald-500
  static const Color successLight = Color(0xFF34D399);    // Emerald-400
  static const Color successSurface = Color(0xFFECFDF5);  // Emerald-50

  static const Color warning = Color(0xFFF59E0B);         // Amber-500
  static const Color warningLight = Color(0xFFFBBF24);    // Amber-400
  static const Color warningSurface = Color(0xFFFFFBEB);  // Amber-50

  static const Color danger = Color(0xFFF43F5E);          // Rose-500
  static const Color dangerLight = Color(0xFFFB7185);     // Rose-400
  static const Color dangerSurface = Color(0xFFFFF1F2);   // Rose-50

  static const Color info = Color(0xFF3B82F6);            // Blue-500
  static const Color infoLight = Color(0xFF60A5FA);       // Blue-400
  static const Color infoSurface = Color(0xFFEFF6FF);     // Blue-50

  // ─── Ticket Priority ─────────────────────────────────────────────────
  static const Color priorityCritical = Color(0xFFBE123C);  // Rose-700
  static const Color priorityHigh = Color(0xFFE11D48);      // Rose-600
  static const Color priorityMedium = Color(0xFFD97706);    // Amber-600
  static const Color priorityLow = Color(0xFF059669);       // Emerald-600

  static const Color priorityCriticalSurface = Color(0xFFFFF1F2);
  static const Color priorityHighSurface = Color(0xFFFFF1F2);
  static const Color priorityMediumSurface = Color(0xFFFFFBEB);
  static const Color priorityLowSurface = Color(0xFFECFDF5);

  // ─── Ticket Status ───────────────────────────────────────────────────
  static const Color statusOpen = Color(0xFF3B82F6);          // Blue
  static const Color statusOpenSurface = Color(0xFFEFF6FF);
  static const Color statusPending = Color(0xFFF59E0B);       // Amber
  static const Color statusPendingSurface = Color(0xFFFFFBEB);
  static const Color statusResolved = Color(0xFF10B981);      // Emerald
  static const Color statusResolvedSurface = Color(0xFFECFDF5);
  static const Color statusClosed = Color(0xFF64748B);        // Slate
  static const Color statusClosedSurface = Color(0xFFF1F5F9);
  static const Color statusBreached = Color(0xFFF43F5E);      // Rose
  static const Color statusBreachedSurface = Color(0xFFFFF1F2);
  static const Color statusOnHold = Color(0xFF8B5CF6);        // Purple
  static const Color statusOnHoldSurface = Color(0xFFF5F3FF);

  // ─── Light Theme Surfaces ─────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color iconDefault = Color(0xFF64748B);
  static const Color iconMuted = Color(0xFF94A3B8);

  // ─── Sidebar ─────────────────────────────────────────────────────────
  static const Color sidebarBackground = Color(0xFF0B0F19);
  static const Color sidebarItemDefault = Color(0xFF94A3B8);
  static const Color sidebarItemActive = Color(0xFFFFFFFF);
  static const Color sidebarItemActiveBg = Color(0xFF4F46E5);
  static const Color sidebarItemHoverBg = Color(0xFF1E293B);
  static const Color sidebarDivider = Color(0xFF1E293B);
  static const Color sidebarBadge = Color(0xFF4F46E5);

  // ─── Dark Theme Surfaces ──────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceVariant = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF1F2937);
  static const Color darkDivider = Color(0xFF1F2937);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // ─── AI Copilot Card ─────────────────────────────────────────────────
  static const Color aiCardBackground = Color(0xFF0F172A);
  static const Color aiCardBorder = Color(0xFF312E81);
  static const Color aiGradientStart = Color(0xFF4F46E5);
  static const Color aiGradientEnd = Color(0xFF7C3AED);

  // ─── Charts ──────────────────────────────────────────────────────────
  static const List<Color> chartPalette = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFF43F5E),
  ];

  // ─── Gradients ───────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF0B0F19)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
