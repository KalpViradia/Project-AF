import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Modern snackbar utility for consistent design across the app
class ModernSnackbar {
  // Deduplication: track last shown time per message key
  static final Map<String, DateTime> _lastShownAt = {};
  // Throttling window for identical messages
  static Duration minIntervalPerMessage = const Duration(seconds: 3);

  static void show({
    required String title,
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
    bool isDismissible = true,
  }) {
    // Generate a stable key for this snackbar content
    final key = '${type.name}|$title|$message|${position.name}';
    final now = DateTime.now();
    final last = _lastShownAt[key];
    if (last != null && now.difference(last) < minIntervalPerMessage) {
      // Skip showing duplicate within the cooldown window
      return;
    }
    _lastShownAt[key] = now;

    final theme = Get.theme;
    final colorScheme = theme.colorScheme;
    
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (type) {
      case SnackbarType.success:
        backgroundColor = const Color(0xFF10B981); // Green
        textColor = Colors.white;
        icon = Icons.check_circle_rounded;
        break;
      case SnackbarType.error:
        backgroundColor = const Color(0xFFEF4444); // Red
        textColor = Colors.white;
        icon = Icons.error_rounded;
        break;
      case SnackbarType.warning:
        backgroundColor = const Color(0xFFF59E0B); // Orange
        textColor = Colors.white;
        icon = Icons.warning_rounded;
        break;
      case SnackbarType.info:
        backgroundColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        icon = Icons.info_rounded;
        break;
    }
    
    // Avoid stacking too many snackbars visually
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      duration: duration,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      colorText: textColor,
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: textColor,
          size: 20,
        ),
      ),
      shouldIconPulse: false,
      boxShadows: [
        BoxShadow(
          color: backgroundColor.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      titleText: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: textColor.withValues(alpha: 0.9),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
  
  static void success({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      type: SnackbarType.success,
      duration: duration,
    );
  }
  
  static void error({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      title: title,
      message: message,
      type: SnackbarType.error,
      duration: duration,
    );
  }
  
  static void warning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
    );
  }
  
  static void info({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      type: SnackbarType.info,
      duration: duration,
    );
  }
}

enum SnackbarType {
  success,
  error,
  warning,
  info,
}
