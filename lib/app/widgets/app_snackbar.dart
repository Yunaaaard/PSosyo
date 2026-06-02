import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  AppSnackbar._();

  // ── Tokens ──────────────────────────────────────────────────────────────────

  static const _radius = 16.0;
  static const _pillRadius = 10.0;

  // Accent colours (bar + icon + pill)
  static const _cInfo    = Color(0xFF38BDF8);
  static const _cSuccess = Color(0xFF4ADE80);
  static const _cWarning = Color(0xFFFBBF24);
  static const _cError   = Color(0xFFF87171);

  // Icon colours (slightly darker for contrast inside pill)
  static const _iInfo    = Color(0xFF0284C7);
  static const _iSuccess = Color(0xFF16A34A);
  static const _iWarning = Color(0xFFCA8A04);
  static const _iError   = Color(0xFFDC2626);

  // Pill background fills
  static const _pInfo    = Color(0xFFE0F5FE);
  static const _pSuccess = Color(0xFFDCFCE7);
  static const _pWarning = Color(0xFFFEF9C3);
  static const _pError   = Color(0xFFFEE2E2);

  // ── Public API ──────────────────────────────────────────────────────────────

  static void show({
    String title = '',
    String message = '',
    SnackType type = SnackType.info,
    SnackPosition position = SnackPosition.BOTTOM,
    EdgeInsets margin = const EdgeInsets.fromLTRB(16, 0, 16, 28),
    Duration duration = const Duration(seconds: 6),
  }) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    final cfg = _config(type);

    Get.rawSnackbar(
      snackPosition: position,
      margin: margin,
      padding: EdgeInsets.zero,
      duration: duration,
      backgroundColor: Colors.transparent,
      borderRadius: _radius,
      borderWidth: 0,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      snackStyle: SnackStyle.FLOATING,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      // titleText carries the full custom layout; messageText is hidden.
      titleText: _SnackLayout(
        title: title,
        message: message,
        accentColor: cfg.accent,
        pillColor: cfg.pill,
        iconColor: cfg.iconColor,
        icon: cfg.icon,
        radius: _radius,
        pillRadius: _pillRadius,
      ),
      messageText: const SizedBox.shrink(),
    );
  }

  static void info({
    String title = '',
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 4),
  }) => show(
        title: title,
        message: message,
        type: SnackType.info,
        position: position,
        duration: duration,
      );

  static void success({
    String title = '',
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 4),
  }) => show(
        title: title,
        message: message,
        type: SnackType.success,
        position: position,
        duration: duration,
      );

  static void warning({
    String title = '',
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 5),
  }) => show(
        title: title,
        message: message,
        type: SnackType.warning,
        position: position,
        duration: duration,
      );

  static void error({
    String title = '',
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 5),
  }) => show(
        title: title,
        message: message,
        type: SnackType.error,
        position: position,
        duration: duration,
      );

  // ── Internal config resolver ────────────────────────────────────────────────

  static _SnackConfig _config(SnackType type) {
    switch (type) {
      case SnackType.success:
        return const _SnackConfig(
          accent: _cSuccess, pill: _pSuccess, iconColor: _iSuccess,
          icon: Icons.check_circle_outline_rounded,
        );
      case SnackType.warning:
        return const _SnackConfig(
          accent: _cWarning, pill: _pWarning, iconColor: _iWarning,
          icon: Icons.warning_amber_rounded,
        );
      case SnackType.error:
        return const _SnackConfig(
          accent: _cError, pill: _pError, iconColor: _iError,
          icon: Icons.error_outline_rounded,
        );
      case SnackType.info:
        return const _SnackConfig(
          accent: _cInfo, pill: _pInfo, iconColor: _iInfo,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

// ── Type enum ──────────────────────────────────────────────────────────────────

enum SnackType { info, success, warning, error }

// ── Internal data class ────────────────────────────────────────────────────────

class _SnackConfig {
  const _SnackConfig({
    required this.accent,
    required this.pill,
    required this.iconColor,
    required this.icon,
  });
  final Color accent;
  final Color pill;
  final Color iconColor;
  final IconData icon;
}

// ── Layout widget ──────────────────────────────────────────────────────────────

class _SnackLayout extends StatelessWidget {
  const _SnackLayout({
    required this.title,
    required this.message,
    required this.accentColor,
    required this.pillColor,
    required this.iconColor,
    required this.icon,
    required this.radius,
    required this.pillRadius,
  });

  final String title;
  final String message;
  final Color accentColor;
  final Color pillColor;
  final Color iconColor;
  final IconData icon;
  final double radius;
  final double pillRadius;

  @override
  Widget build(BuildContext context) {
    final hasTitle = title.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.black.withOpacity(0.07), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(width: 3, color: accentColor),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon pill
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: pillColor,
                          borderRadius: BorderRadius.circular(pillRadius),
                        ),
                        alignment: Alignment.center,
                        child: Icon(icon, color: iconColor, size: 19),
                      ),
                      const SizedBox(width: 12),

                      // Text
                      Expanded(
                        child: hasTitle
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (message.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      message,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF64748B),
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ],
                              )
                            : Text(
                                message,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0F172A),
                                  height: 1.35,
                                ),
                              ),
                      ),

                      // Dismiss icon
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}