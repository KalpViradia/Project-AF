import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.indigo,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    color: Colors.indigo,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.deepPurple,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    color: Colors.deepPurple,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
);

final ThemeData oceanTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.teal,
  scaffoldBackgroundColor: Colors.cyan,
  appBarTheme: const AppBarTheme(
    color: Colors.teal,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
);

final ThemeData sunsetTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.deepOrange,
  scaffoldBackgroundColor: Color(0xFFFFF3E0),
  appBarTheme: const AppBarTheme(
    color: Colors.deepOrange,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
);

final ThemeData mintTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.green,
  scaffoldBackgroundColor: Color(0xFFE8F5E9),
  appBarTheme: const AppBarTheme(
    color: Colors.green,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
);

final ThemeData highContrastTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.amber,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    color: Colors.amber,
    foregroundColor: Colors.black,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
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
