import '../utils/import_export.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final _themeMode = ThemeMode.system.obs;
  // Holds a predefined theme key like 'ocean', 'sunset', 'mint', 'high_contrast'.
  // Empty string means no predefined theme is selected; use themeMode (light/dark/system).
  final _selectedThemeKey = ''.obs;

  static const String _themeModeKey = 'theme_mode';
  static const String _selectedThemePrefKey = 'selected_theme';

  ThemeMode get themeMode => _themeMode.value;
  String get selectedThemeKey => _selectedThemeKey.value;
  ThemeData get currentTheme =>
      _selectedThemeKey.value.isEmpty
          ? lightTheme
          : (predefinedThemes[_selectedThemeKey.value] ?? lightTheme);

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode
      final themeModeString = prefs.getString(_themeModeKey);
      if (themeModeString != null) {
        _themeMode.value = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }

      // Load selected predefined theme key
      _selectedThemeKey.value = prefs.getString(_selectedThemePrefKey) ?? '';
      update();
    } catch (e) {
      print('Error loading theme from preferences: $e');
    }
  }

  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save theme mode
      await prefs.setString(_themeModeKey, _themeMode.value.toString());

      // Save selected predefined theme key
      await prefs.setString(_selectedThemePrefKey, _selectedThemeKey.value);
    } catch (e) {
      print('Error saving theme to preferences: $e');
    }
  }

  Future<void> toggleTheme() async {
    _selectedThemeKey.value = '';
    update();
    _themeMode.value = _themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveThemeToPrefs();
  }

  Future<void> applyPredefinedTheme(String key) async {
    // For light/dark selections, just use themeMode and clear selected theme key.
    if (key == 'light') {
      _selectedThemeKey.value = '';
      _themeMode.value = ThemeMode.light;
    } else if (key == 'dark') {
      _selectedThemeKey.value = '';
      _themeMode.value = ThemeMode.dark;
    } else {
      // For other predefined themes, force light mode and store the key
      _selectedThemeKey.value = key;
      _themeMode.value = ThemeMode.light;
    }
    update();
    await _saveThemeToPrefs();
  }

  Future<void> resetToDefault() async {
    _selectedThemeKey.value = '';
    update();
    _themeMode.value = ThemeMode.system;
    await _saveThemeToPrefs();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _selectedThemeKey.value = '';
    _themeMode.value = mode;
    await _saveThemeToPrefs();
  }
}
