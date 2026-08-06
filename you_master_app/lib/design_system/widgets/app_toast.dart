import 'dart:async';

import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';

enum AppToastType { success, error, warning, info, neutral }

abstract final class AppToast {
  static OverlayEntry? _activeEntry;

  static void show(
    BuildContext context, {
    required String title,
    String? message,
    AppToastType type = AppToastType.neutral,
    Duration duration = const Duration(seconds: 4),
  }) {
    _activeEntry?.remove();
    _activeEntry = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    var removed = false;

    void remove() {
      if (removed) return;
      removed = true;
      entry.remove();
      if (identical(_activeEntry, entry)) _activeEntry = null;
    }

    entry = OverlayEntry(
      builder: (context) => _AppToastOverlay(
        title: title,
        message: message,
        type: type,
        duration: duration,
        onDismissed: remove,
      ),
    );
    _activeEntry = entry;
    overlay.insert(entry);
  }

  static void success(
    BuildContext context, {
    required String title,
    String? message,
  }) =>
      show(context, title: title, message: message, type: AppToastType.success);

  static void error(
    BuildContext context, {
    required String title,
    String? message,
  }) => show(
    context,
    title: title,
    message: message,
    type: AppToastType.error,
    duration: const Duration(seconds: 6),
  );

  static void warning(
    BuildContext context, {
    required String title,
    String? message,
  }) =>
      show(context, title: title, message: message, type: AppToastType.warning);

  static void info(
    BuildContext context, {
    required String title,
    String? message,
  }) => show(context, title: title, message: message, type: AppToastType.info);
}

class _AppToastOverlay extends StatefulWidget {
  const _AppToastOverlay({
    required this.title,
    required this.type,
    required this.duration,
    required this.onDismissed,
    this.message,
  });

  final String title;
  final String? message;
  final AppToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 180),
    )..forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visual = _ToastVisual.forType(widget.type);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12,
      left: 16,
      right: 16,
      child: IgnorePointer(
        ignoring: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: FadeTransition(
              opacity: reduceMotion
                  ? const AlwaysStoppedAnimation(1)
                  : CurvedAnimation(parent: _controller, curve: Curves.easeOut),
              child: SlideTransition(
                position: reduceMotion
                    ? const AlwaysStoppedAnimation(Offset.zero)
                    : Tween(
                        begin: const Offset(0, -0.25),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                child: Semantics(
                  liveRegion: true,
                  container: true,
                  label: '${widget.title}. ${widget.message ?? ''}',
                  child: Material(
                    color: AppColors.surface,
                    elevation: 10,
                    shadowColor: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(width: 5, color: visual.color),
                          const SizedBox(width: 18),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: visual.background,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              visual.icon,
                              color: visual.color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (widget.message != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.message!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.35,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Закрыть уведомление',
                            onPressed: _dismiss,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastVisual {
  const _ToastVisual(this.color, this.background, this.icon);
  final Color color;
  final Color background;
  final IconData icon;

  factory _ToastVisual.forType(AppToastType type) => switch (type) {
    AppToastType.success => const _ToastVisual(
      Color(0xFF12B76A),
      Color(0xFFE8F8F0),
      Icons.check_rounded,
    ),
    AppToastType.error => const _ToastVisual(
      Color(0xFFF04438),
      Color(0xFFFFE9E8),
      Icons.priority_high_rounded,
    ),
    AppToastType.warning => const _ToastVisual(
      Color(0xFFF79009),
      Color(0xFFFFF1DE),
      Icons.warning_amber_rounded,
    ),
    AppToastType.info => const _ToastVisual(
      Color(0xFF2E90FA),
      Color(0xFFE8F2FF),
      Icons.info_outline_rounded,
    ),
    AppToastType.neutral => const _ToastVisual(
      Color(0xFF667085),
      Color(0xFFF2F4F7),
      Icons.more_horiz_rounded,
    ),
  };
}
