import '../utils/import_export.dart';

class ThemeCustomizationPage extends StatefulWidget {
  const ThemeCustomizationPage({super.key});

  @override
  State<ThemeCustomizationPage> createState() => _ThemeCustomizationPageState();
}

class _ThemeCustomizationPageState extends State<ThemeCustomizationPage>
    with SingleTickerProviderStateMixin {
  final ThemeController themeController = Get.find<ThemeController>();

  late TabController _tabController;
  late ThemeData currentTheme;

  String selectedTheme = '';
  Color primaryColor = Colors.indigo;
  Color backgroundColor = Colors.white;
  Color appBarColor = Colors.indigo;
  Color textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    currentTheme = themeController.customTheme ?? lightTheme;

    _detectSelectedTheme();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _detectSelectedTheme() {
    if (themeController.customTheme != null) {
      selectedTheme = 'custom';
      // Initialize color values from custom theme
      primaryColor = themeController.customTheme!.primaryColor;
      backgroundColor = themeController.customTheme!.scaffoldBackgroundColor;
      appBarColor = themeController.customTheme!.appBarTheme.backgroundColor ?? primaryColor;
      textColor = themeController.customTheme!.textTheme.bodyLarge?.color ?? Colors.black;
    } else {
      final currentTheme = Get.theme;
      if (currentTheme == darkTheme) {
        selectedTheme = 'dark';
      } else if (currentTheme == oceanTheme) {
        selectedTheme = 'ocean';
      } else if (currentTheme == sunsetTheme) {
        selectedTheme = 'sunset';
      } else if (currentTheme == mintTheme) {
        selectedTheme = 'mint';
      } else if (currentTheme == highContrastTheme) {
        selectedTheme = 'high_contrast';
      } else {
        selectedTheme = 'light';
      }

      // Initialize color values from current theme
      primaryColor = currentTheme.primaryColor;
      backgroundColor = currentTheme.scaffoldBackgroundColor;
      appBarColor = currentTheme.appBarTheme.backgroundColor ?? primaryColor;
      textColor = currentTheme.textTheme.bodyLarge?.color ?? Colors.black;
    }
  }

  void _applyPredefinedTheme(String theme) {
    setState(() => selectedTheme = theme);
    switch (theme) {
      case 'light':
        themeController.setTheme(lightTheme);
        break;
      case 'dark':
        themeController.setTheme(darkTheme);
        break;
      case 'ocean':
        themeController.setTheme(oceanTheme);
        break;
      case 'sunset':
        themeController.setTheme(sunsetTheme);
        break;
      case 'mint':
        themeController.setTheme(mintTheme);
        break;
      case 'high_contrast':
        themeController.setTheme(highContrastTheme);
        break;
    }
    ModernSnackbar.success(
      title: "Theme Applied",
      message: "${theme.replaceAll('_', ' ')} theme has been applied",
    );
  }

  void _applyCustomTheme() {
    final ThemeData custom = ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(color: appBarColor, foregroundColor: textColor),
      textTheme: TextTheme(bodyLarge: TextStyle(color: textColor)),
    );
    themeController.setTheme(custom);
    ModernSnackbar.success(
      title: "Custom Theme Applied",
      message: "Your custom theme has been applied successfully",
    );
  }

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

  Widget _buildColorPicker(
      BuildContext context, String label, Color currentColor, ValueChanged<Color> onColorChanged) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: BlockPicker(
                pickerColor: currentColor,
                onColorChanged: onColorChanged,
                availableColors: const [
                  Colors.red,
                  Colors.pink,
                  Colors.purple,
                  Colors.deepPurple,
                  Colors.indigo,
                  Colors.blue,
                  Colors.lightBlue,
                  Colors.cyan,
                  Colors.teal,
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lime,
                  Colors.yellow,
                  Colors.amber,
                  Colors.orange,
                  Colors.deepOrange,
                  Colors.brown,
                  Colors.grey,
                  Colors.blueGrey,
                  Colors.black,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Customization'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Predefined'),
            Tab(text: 'Custom'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// ====== PREDEFINED TAB ======
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select a Theme', 
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
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
                    if (themeController.customTheme != null)
                      _buildThemeOption('custom', Icons.palette, primaryColor),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.menu, color: Theme.of(context).primaryTextTheme.titleLarge?.color),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Preview App Bar',
                                      style: TextStyle(color: Theme.of(context).primaryTextTheme.titleLarge?.color),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                color: Theme.of(context).scaffoldBackgroundColor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Sample Text', style: Theme.of(context).textTheme.bodyLarge),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: const Text('Sample Button'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ====== CUSTOM TAB ======
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Your Theme',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildColorPicker(
                  context,
                  'Primary Color',
                  primaryColor,
                  (color) => setState(() => primaryColor = color),
                ),
                _buildColorPicker(
                  context,
                  'Background Color',
                  backgroundColor,
                  (color) => setState(() => backgroundColor = color),
                ),
                _buildColorPicker(
                  context,
                  'AppBar Color',
                  appBarColor,
                  (color) => setState(() => appBarColor = color),
                ),
                _buildColorPicker(
                  context,
                  'Text Color',
                  textColor,
                  (color) => setState(() => textColor = color),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Theme Preview',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: primaryColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: appBarColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Sample AppBar',
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sample Text Content',
                                style: TextStyle(color: textColor),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: textColor,
                                ),
                                child: const Text('Sample Button'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => selectedTheme = 'custom');
                      _applyCustomTheme();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.brush),
                    label: const Text('Apply Custom Theme'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
