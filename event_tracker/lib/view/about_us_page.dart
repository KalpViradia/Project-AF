import '../utils/import_export.dart';

class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> with TickerProviderStateMixin {
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();

    // Add gradient animation controller
    _gradientController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat();
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
        title: Text('About Us'),
      ),
      body: Container(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: _buildShiningAppTitle(theme),
              ),
              
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoCard(
                      theme: theme,
                      title: 'Meet Our Team',
                      icon: Icons.people,
                      children: _buildTeamInfo(theme),
                    ),
                    SizedBox(height: 16),
                    _buildInfoCard(
                      theme: theme,
                      title: 'About Event Tracker',
                      icon: Icons.event,
                      children: _buildAppInfo(theme),
                    ),
                    SizedBox(height: 16),
                    _buildInfoCard(
                      theme: theme,
                      title: 'About ASWDC',
                      icon: Icons.school,
                      children: _buildAswdcInfo(theme),
                    ),
                    SizedBox(height: 16),
                    _buildInfoCard(
                      theme: theme,
                      title: 'Contact Us',
                      icon: Icons.contact_mail,
                      children: _buildContactInfo(theme),
                    ),
                    SizedBox(height: 16),
                    _buildInfoCard(
                      theme: theme,
                      title: 'Quick Links',
                      icon: Icons.link,
                      children: _buildOtherLinks(theme),
                    ),
                    SizedBox(height: 24),
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
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.event_available,
            size: 60,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        SizedBox(height: 24),
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
                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
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
                      offset: Offset(0, 2),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                SizedBox(width: 12),
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
            padding: EdgeInsets.all(16),
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
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          SizedBox(width: 12),
          Text(
            info,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(ThemeData theme, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.bodyMedium,
          ),
        ],
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
      padding: EdgeInsets.symmetric(vertical: 16),
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
      _buildParagraph(theme, 'Event Tracker is a comprehensive event management application designed to help users create, manage, and track events efficiently.'),
      _buildParagraph(theme, 'Features include event creation, user invitations, event tracking, profile management, and real-time notifications.'),
      _buildParagraph(theme, 'Built with Flutter for cross-platform compatibility and modern user experience.'),
    ];
  }

  List<Widget> _buildAswdcInfo(ThemeData theme) {
    return [
      _buildParagraph(theme, 'ASWDC is an Application, Software, and Website Development Center at Darshan University.'),
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
      _buildLinkRow(theme, Icons.thumb_up, 'Like us on Facebook'),
      _buildLinkRow(theme, Icons.update, 'Check For Update'),
    ];
  }
}
