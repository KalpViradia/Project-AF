import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModernSnackbar {
  static void show({
    required String title,
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = const Color(0xFF10B981);
        icon = Icons.check_circle;
        break;
      case SnackbarType.error:
        backgroundColor = const Color(0xFFEF4444);
        icon = Icons.error;
        break;
      case SnackbarType.warning:
        backgroundColor = const Color(0xFFF59E0B);
        icon = Icons.warning;
        break;
      case SnackbarType.info:
        backgroundColor = const Color(0xFF3B82F6);
        icon = Icons.info;
        break;
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: Icon(icon, color: textColor),
      snackPosition: SnackPosition.TOP,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 300),
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
