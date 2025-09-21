import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();

    // Initialize gradient animation controller
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Load app version
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = 'v${packageInfo.version}';
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to load app version');
      }
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: Container(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: _buildShiningAppTitle(theme),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoCard(
                      theme: theme,
                      title: 'Meet Our Team',
                      icon: Icons.people,
                      children: _buildTeamInfo(theme),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      theme: theme,
                      title: 'About Event Tracker',
                      icon: Icons.event,
                      children: _buildAppInfo(theme),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      theme: theme,
                      title: 'About ASWDC',
                      icon: Icons.school,
                      children: _buildAswdcInfo(theme),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      theme: theme,
                      title: 'Contact Us',
                      icon: Icons.contact_mail,
                      children: _buildContactInfo(theme),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      theme: theme,
                      title: 'Quick Links',
                      icon: Icons.link,
                      children: _buildOtherLinks(theme),
                    ),
                    const SizedBox(height: 24),
                    _buildFooter(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiningAppTitle(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/AppLogo.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.event_available,
                    size: 60,
                    color: theme.colorScheme.onPrimary,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_appVersion.isNotEmpty)
          Text(
            _appVersion,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: _gradientController,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.6),
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                  theme.colorScheme.tertiary,
                  theme.colorScheme.primary,
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(_gradientController.value * 6.283185),
              ).createShader(bounds),
              child: Text(
                'Event Tracker',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      offset: const Offset(0, 2),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyValueRow(ThemeData theme, String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$key:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(ThemeData theme, IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _handleContactTap(icon, info),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  info,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkRow(ThemeData theme, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _handleLinkTap(title),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParagraph(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        '© 2025 Darshan University\nAll Rights Reserved - Privacy Policy',
        style: theme.textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Widget> _buildTeamInfo(ThemeData theme) {
    return [
      _buildKeyValueRow(theme, 'Developed by', 'Kalp Viradia (23010101299)'),
      _buildKeyValueRow(theme, 'Mentored by', 'Prof. Mehul Bhundiya'),
      _buildKeyValueRow(theme, 'Explored by', 'ASWDC, School Of Computer Science'),
      _buildKeyValueRow(theme, 'Eulogized by', 'Darshan University'),
    ];
  }

  List<Widget> _buildAppInfo(ThemeData theme) {
    return [
      _buildParagraph(
          theme,
          'Event Tracker is a comprehensive event management application designed to help users create, manage, and track events efficiently.'),
      _buildParagraph(
          theme,
          'Features include event creation, user invitations, event tracking, profile management, and real-time notifications.'),
      _buildParagraph(
          theme, 'Built with Flutter for cross-platform compatibility and modern user experience.'),
    ];
  }

  List<Widget> _buildAswdcInfo(ThemeData theme) {
    return [
      _buildParagraph(
          theme, 'ASWDC is an Application, Software, and Website Development Center at Darshan University.'),
      _buildParagraph(theme, 'It bridges the gap between academics and industry with real-world projects.'),
    ];
  }

  List<Widget> _buildContactInfo(ThemeData theme) {
    return [
      _buildContactRow(theme, Icons.email, 'aswdc@darshan.ac.in'),
      _buildContactRow(theme, Icons.phone, '+91-9727747317'),
      _buildContactRow(theme, Icons.language, 'www.darshan.ac.in'),
    ];
  }

  List<Widget> _buildOtherLinks(ThemeData theme) {
    return [
      _buildLinkRow(theme, Icons.share, 'Share App'),
      _buildLinkRow(theme, Icons.apps, 'More Apps'),
      _buildLinkRow(theme, Icons.star, 'Rate Us'),
      _buildLinkRow(theme, Icons.update, 'Check For Update'),
    ];
  }

  Future<void> _handleContactTap(IconData icon, String info) async {
    try {
      Uri? uri;
      if (icon == Icons.email) {
        uri = Uri.parse('mailto:$info');
      } else if (icon == Icons.phone) {
        uri = Uri.parse('tel:$info');
      } else if (icon == Icons.language) {
        uri = Uri.parse(info.startsWith('http') ? info : 'https://$info');
        print('uri::::::: $uri');
      }

      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open $info');
      }
    } catch (e) {
      _showErrorSnackBar('Could not open $info');
    }
  }

  Future<void> _handleLinkTap(String title) async {
    try {
      switch (title) {
        case 'Share App':
          await _shareApp();
          break;
        case 'More Apps':
          await _openMoreApps();
          break;
        case 'Rate Us':
          await _rateApp();
          break;
        case 'Check For Update':
          await _checkForUpdate();
          break;
        default:
          _showErrorSnackBar('Unknown action');
      }
    } catch (e) {
      _showErrorSnackBar('Could not perform action');
    }
  }

  Future<void> _shareApp() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;
      final playStoreUrl = Platform.isAndroid
          ? 'https://play.google.com/store/apps/details?id=${packageInfo.packageName}'
          : 'https://apps.apple.com/app/id${packageInfo.packageName}';

      await Share.share(
        'Check out $appName - A comprehensive event management app!\n\nDownload it now: $playStoreUrl',
        subject: 'Check out $appName!',
      );
    } catch (e) {
      _showErrorSnackBar('Could not share app');
    }
  }

  Future<void> _openMoreApps() async {
    try {
      final uri = Platform.isAndroid
          ? Uri.parse('https://play.google.com/store/apps/developer?id=Darshan+University')
          : Uri.parse('https://apps.apple.com/developer/darshan-university/id123456789');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open more apps');
      }
    } catch (e) {
      _showErrorSnackBar('Could not open more apps');
    }
  }

  Future<void> _rateApp() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final uri = Platform.isAndroid
          ? Uri.parse('https://play.google.com/store/apps/details?id=${packageInfo.packageName}')
          : Uri.parse('https://apps.apple.com/app/id${packageInfo.packageName}');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open app store');
      }
    } catch (e) {
      _showErrorSnackBar('Could not open app store');
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final uri = Platform.isAndroid
          ? Uri.parse('https://play.google.com/store/apps/details?id=${packageInfo.packageName}')
          : Uri.parse('https://apps.apple.com/app/id${packageInfo.packageName}');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not check for updates');
      }
    } catch (e) {
      _showErrorSnackBar('Could not check for updates');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}