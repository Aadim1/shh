import 'package:flutter/material.dart';

ColorScheme lightSlateBlueThemeColors() {
  return const ColorScheme.light(
    primary: Color(0xFF6A5ACD),
    primaryContainer: Color(0xFFB3AEDF), // Lighter Shade of Slate Blue
    secondary: Color(0xFF88BDBF), // Sea Green for secondary elements
    secondaryContainer:
        Color(0xFFCFD8DC), // Light Grey for secondary containers
    background: Color(0xFFFAF9F6), // Off-White for background
    surface: Color(0xFFF7F7F7), // Pure White for cards, sheets, etc.
    onPrimary: Color(0xFFFFFFFF), // White text/icons on primary color
    onSecondary: Color(0xFF000000), // Black text/icons on secondary color
    onBackground: Color(0xFF000000), // Black text/icons on background

    onSurface: Color(0xFF000000), // Black text/icons on surface
    error: Color(0xFFD32F2F), // Red for errors
    onError: Color(0xFFFFFFFF), // White text/icons on error color
    tertiary: Color(0xFF735a96),
  );
}

ColorScheme darkSlateBlueThemeColors() {
  return const ColorScheme.dark(
    primary: Color(0xFF6A5ACD), // Slate Blue (preserving from light theme)
    primaryContainer:
        Color(0xFF484C7F), // Darker Shade of Slate Blue for containers
    secondary:
        Color(0xFF9E9E9E), // Grey for secondary elements (as in light theme)
    secondaryContainer:
        Color(0xFF636363), // Darker Grey for secondary containers
    background:
        Color(0xFF121212), // Very dark grey, almost black, for background
    surface: Color(0xFF1E1E1E), // Dark grey for cards, sheets, etc.
    onPrimary: Color(0xFFFFFFFF), // White text/icons on primary color
    onSecondary: Color(0xFF000000), // Black text/icons on secondary color
    onBackground: Color(0xFFFFFFFF), // White text/icons on background
    onSurface: Color(0xFFFFFFFF), // White text/icons on surface
    error: Color(0xFFCF6679), // Standard error color in dark theme
    onError: Color(0xFF000000), // Black text/icons on error color
    brightness: Brightness.dark,
    tertiary: Color(0xFF735a96),
  );
}
