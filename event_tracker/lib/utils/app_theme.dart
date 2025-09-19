import 'package:flutter/material.dart';

// Modern Color Schemes
const ColorScheme _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF6366F1), // Modern indigo
  onPrimary: Colors.white,
  secondary: Color(0xFF8B5CF6), // Purple accent
  onSecondary: Colors.white,
  tertiary: Color(0xFF06B6D4), // Cyan accent
  onTertiary: Colors.white,
  error: Color(0xFFEF4444),
  onError: Colors.white,
  surface: Color(0xFFFAFAFA),
  onSurface: Color(0xFF1F2937),
  surfaceContainerHighest: Color(0xFFF3F4F6),
  outline: Color(0xFFD1D5DB),
  shadow: Color(0x1A000000),
);

const ColorScheme _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF818CF8), // Lighter indigo for dark mode
  onPrimary: Color(0xFF1E1B4B),
  secondary: Color(0xFFA78BFA), // Lighter purple
  onSecondary: Color(0xFF3C1A78),
  tertiary: Color(0xFF22D3EE), // Lighter cyan
  onTertiary: Color(0xFF164E63),
  error: Color(0xFFF87171),
  onError: Color(0xFF7F1D1D),
  surface: Color(0xFF111827),
  onSurface: Color(0xFFF9FAFB),
  surfaceContainerHighest: Color(0xFF1F2937),
  outline: Color(0xFF4B5563),
  shadow: Color(0x33000000),
);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _lightColorScheme,
  scaffoldBackgroundColor: _lightColorScheme.surface,

  // App Bar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: _lightColorScheme.surface,
    foregroundColor: _lightColorScheme.onSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1F2937),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF1F2937),
      size: 24,
    ),
  ),

  // Card Theme
  cardTheme: CardThemeData(
    elevation: 2,
    shadowColor: _lightColorScheme.shadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: _lightColorScheme.surface,
  ),

  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _lightColorScheme.surfaceContainerHighest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _lightColorScheme.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _lightColorScheme.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _lightColorScheme.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _lightColorScheme.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      elevation: 2,
      shadowColor: _lightColorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  ),

  // Typography
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Color(0xFF111827),
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Color(0xFF111827),
      letterSpacing: -0.25,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Color(0xFF111827),
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFF111827),
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFF111827),
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF111827),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Color(0xFF374151),
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFF6B7280),
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFF9CA3AF),
      height: 1.3,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF374151),
    ),
  ),
);

// Dark Theme Implementation
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _darkColorScheme,
  scaffoldBackgroundColor: _darkColorScheme.surface,

  // App Bar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: _darkColorScheme.surface,
    foregroundColor: _darkColorScheme.onSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF9FAFB),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFF9FAFB),
      size: 24,
    ),
  ),

  // Card Theme
  cardTheme: CardThemeData(
    elevation: 2,
    shadowColor: _darkColorScheme.shadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: _darkColorScheme.surfaceContainerHighest,
  ),

  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _darkColorScheme.surfaceContainerHighest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _darkColorScheme.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _darkColorScheme.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _darkColorScheme.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _darkColorScheme.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
      elevation: 2,
      shadowColor: _darkColorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  ),

  // Typography
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Color(0xFFF9FAFB),
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Color(0xFFF9FAFB),
      letterSpacing: -0.25,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF9FAFB),
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF9FAFB),
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF9FAFB),
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFFF9FAFB),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Color(0xFFD1D5DB),
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFF9CA3AF),
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFF6B7280),
      height: 1.3,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFFD1D5DB),
    ),
  ),
);

// Ocean Theme - Modern Teal/Cyan
final ThemeData oceanTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF0891B2), // Cyan-600
    onPrimary: Colors.white,
    secondary: Color(0xFF0D9488), // Teal-600
    onSecondary: Colors.white,
    surface: Color(0xFFF0FDFA), // Cyan-50
    onSurface: Color(0xFF164E63), // Cyan-900
    surfaceContainerHighest: Color(0xFFE6FFFA), // Teal-50
    outline: Color(0xFF5EEAD4), // Teal-300
  ),
  scaffoldBackgroundColor: const Color(0xFFF0FDFA),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF0FDFA),
    foregroundColor: Color(0xFF164E63),
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
  ),
);

// Sunset Theme - Modern Orange/Red
final ThemeData sunsetTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFEA580C), // Orange-600
    onPrimary: Colors.white,
    secondary: Color(0xFFDC2626), // Red-600
    onSecondary: Colors.white,
    surface: Color(0xFFFFF7ED), // Orange-50
    onSurface: Color(0xFF9A3412), // Orange-800
    surfaceContainerHighest: Color(0xFFFEF3F2), // Red-50
    outline: Color(0xFFFED7AA), // Orange-200
  ),
  scaffoldBackgroundColor: const Color(0xFFFFF7ED),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFF7ED),
    foregroundColor: Color(0xFF9A3412),
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
  ),
);

// Mint Theme - Modern Green
final ThemeData mintTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF059669), // Emerald-600
    onPrimary: Colors.white,
    secondary: Color(0xFF16A34A), // Green-600
    onSecondary: Colors.white,
    surface: Color(0xFFF0FDF4), // Green-50
    onSurface: Color(0xFF14532D), // Green-900
    surfaceContainerHighest: Color(0xFFECFDF5), // Emerald-50
    outline: Color(0xFFA7F3D0), // Emerald-200
  ),
  scaffoldBackgroundColor: const Color(0xFFF0FDF4),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF0FDF4),
    foregroundColor: Color(0xFF14532D),
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
  ),
);

// High Contrast Theme - Modern Dark with High Contrast
final ThemeData highContrastTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFFBBF24), // Amber-400
    onPrimary: Color(0xFF000000),
    secondary: Color(0xFFF59E0B), // Amber-500
    onSecondary: Color(0xFF000000),
    surface: Color(0xFF000000),
    onSurface: Color(0xFFFFFFFF),
    surfaceContainerHighest: Color(0xFF1F1F1F),
    outline: Color(0xFFFCD34D), // Amber-300
    error: Color(0xFFFF6B6B),
  ),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: const Color(0xFF1F1F1F),
  ),
);

/// Map for easy access
final Map<String, ThemeData> predefinedThemes = {
  'light': lightTheme,
  'dark': darkTheme,
  'ocean': oceanTheme,
  'sunset': sunsetTheme,
  'mint': mintTheme,
  'high_contrast': highContrastTheme,
};
