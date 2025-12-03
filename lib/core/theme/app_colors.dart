import 'package:flutter/material.dart';

/// FreeGo IoT Dashboard Color Palette
/// 
/// A modern, clean color scheme designed for IoT smart-device dashboards.
class AppColors {
  const AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2D9CDB); // Cool blue
  static const Color secondary = Color(0xFF27AE60); // Green for "healthy" status
  static const Color accent = Color(0xFFF2C94C); // Warning yellow
  static const Color danger = Color(0xFFEB5757); // Red for alerts

  // Background & Surface
  static const Color background = Color(0xFFF7F9FC); // Light background
  static const Color surface = Color(0xFFFFFFFF); // Card surface
  static const Color surfaceVariant = Color(0xFFF0F3F8); // Alt surface

  // Text Colors
  static const Color textDark = Color(0xFF1A1A1A); // Primary text
  static const Color textSecondary = Color(0xFF6B7280); // Secondary text
  static const Color textMuted = Color(0xFF9CA3AF); // Muted text
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Text on primary

  // Status Colors
  static const Color online = Color(0xFF27AE60); // Online/connected
  static const Color offline = Color(0xFFEB5757); // Offline/disconnected
  static const Color warning = Color(0xFFF2C94C); // Warning state
  static const Color info = Color(0xFF2D9CDB); // Info state

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2D9CDB), Color(0xFF56CCF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF27AE60), Color(0xFF6FCF97)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF2994A), Color(0xFFF2C94C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEB5757), Color(0xFFFF8888)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF7F9FC), Color(0xFFEDF2F7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Temperature-specific colors
  static const Color tempCold = Color(0xFF56CCF2); // Cold temperature
  static const Color tempNormal = Color(0xFF27AE60); // Normal temperature
  static const Color tempWarm = Color(0xFFF2994A); // Warm temperature
  static const Color tempHot = Color(0xFFEB5757); // Hot temperature

  // Battery colors
  static const Color batteryFull = Color(0xFF27AE60);
  static const Color batteryMedium = Color(0xFFF2C94C);
  static const Color batteryLow = Color(0xFFEB5757);

  // Chart colors
  static const Color chartTemperature = Color(0xFFEB5757);
  static const Color chartHumidity = Color(0xFF2D9CDB);
  static const Color chartBattery = Color(0xFF27AE60);
  static const Color chartSolar = Color(0xFFF2C94C);
}
