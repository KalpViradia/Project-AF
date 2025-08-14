import '../utils/import_export.dart';

class ThemeController extends GetxController {
  final _themeMode = ThemeMode.system.obs;
  final _customTheme = Rx<ThemeData?>(null);

  ThemeMode get themeMode => _themeMode.value;
  ThemeData? get customTheme => _customTheme.value;

  void toggleTheme() {
    _customTheme.value = null;
    _themeMode.value =
    _themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setTheme(ThemeData themeData) {
    _customTheme.value = themeData;
  }

  void resetToDefault() {
    _customTheme.value = null;
    _themeMode.value = ThemeMode.system;
  }
}
