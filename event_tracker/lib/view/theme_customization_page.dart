import '../utils/import_export.dart';

class ThemeCustomizationPage extends StatefulWidget {
  const ThemeCustomizationPage({super.key});

  @override
  State<ThemeCustomizationPage> createState() => _ThemeCustomizationPageState();
}

class _ThemeCustomizationPageState extends State<ThemeCustomizationPage> {
  final ThemeController themeController = Get.find<ThemeController>();

  String selectedTheme = '';


  @override
  void initState() {
    super.initState();
    _initializeTheme();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeTheme() {
    final key = themeController.selectedThemeKey;
    if (key.isNotEmpty) {
      selectedTheme = key;
      return;
    }
    // Default based on themeMode or system brightness
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final mode = themeController.themeMode;
    if (mode == ThemeMode.dark || brightness == Brightness.dark) {
      selectedTheme = 'dark';
    } else {
      selectedTheme = 'light';
    }
  }

  // No custom theme preview needed anymore

  // Removed live preview widget

  void _applyPredefinedTheme(String theme) async {
    setState(() => selectedTheme = theme);
    await themeController.applyPredefinedTheme(theme);
    ModernSnackbar.success(
      title: "Theme Applied",
      message: "${theme.replaceAll('_', ' ')} theme has been applied",
    );
    setState(() {});
  }

  // Removed custom theme apply

  // Removed custom theme save

  Widget _buildThemeOption(String theme, IconData icon, Color color) {
    return Builder(
      builder: (BuildContext context) {
        final isSelected = selectedTheme == theme;
        final themeName = theme.replaceAll('_', ' ');
        
        return GestureDetector(
          onTap: () => _applyPredefinedTheme(theme),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.8) : color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ] : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[800],
                ),
                const SizedBox(height: 8),
                Text(
                  themeName.toUpperCase(),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Removed color picker UI


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Customization'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a Theme',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildThemeOption('light', Icons.light_mode, Colors.blue[100]!),
                _buildThemeOption('dark', Icons.dark_mode, Colors.grey[800]!),
                _buildThemeOption('ocean', Icons.water, Colors.teal[100]!),
                _buildThemeOption('sunset', Icons.wb_sunny, Colors.orange[100]!),
                _buildThemeOption('mint', Icons.eco, Colors.green[100]!),
                _buildThemeOption('high_contrast', Icons.contrast, Colors.yellow[700]!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
