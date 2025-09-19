import 'package:flutter/material.dart';

/// App-wide constants for consistent design
class AppConstants {
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Border Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;
  
  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
  
  // Elevation
  static const double lowElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double highElevation = 8.0;
  
  // Icon Sizes
  static const double smallIcon = 16.0;
  static const double mediumIcon = 24.0;
  static const double largeIcon = 32.0;
  static const double extraLargeIcon = 48.0;
  
}

/// Common animations for the app
class AppAnimations {
  static Widget fadeIn({
    required Widget child,
    Duration duration = AppConstants.normalAnimation,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  static Widget slideIn({
    required Widget child,
    Duration duration = AppConstants.normalAnimation,
    Offset begin = const Offset(0, 20),
    Offset end = Offset.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  static Widget scaleIn({
    required Widget child,
    Duration duration = AppConstants.normalAnimation,
    double begin = 0.8,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Common gradients used throughout the app
class AppGradients {
  static LinearGradient primary(BuildContext context) {
    final theme = Theme.of(context);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.colorScheme.primary,
        theme.colorScheme.secondary,
      ],
    );
  }
  
  static LinearGradient surface(BuildContext context) {
    final theme = Theme.of(context);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.colorScheme.surface,
        theme.colorScheme.surfaceContainerHighest,
      ],
    );
  }
  
  static LinearGradient accent(BuildContext context) {
    final theme = Theme.of(context);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.colorScheme.secondary,
        theme.colorScheme.tertiary,
      ],
    );
  }
}

/// Common shadows used throughout the app
class AppShadows {
  static List<BoxShadow> small(BuildContext context) {
    return [
      BoxShadow(
        color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }
  
  static List<BoxShadow> medium(BuildContext context) {
    return [
      BoxShadow(
        color: Theme.of(context).shadowColor.withValues(alpha: 0.15),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }
  
  static List<BoxShadow> large(BuildContext context) {
    return [
      BoxShadow(
        color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ];
  }
}

/// Status colors for consistent use across the app
class StatusColors {
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  static const Color pending = Color(0xFFF59E0B);
  static const Color accepted = Color(0xFF10B981);
  static const Color rejected = Color(0xFFEF4444);
  static const Color cancelled = Color(0xFF6B7280);
  static const Color completed = Color(0xFF8B5CF6);
}
