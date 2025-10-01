import 'package:flutter/material.dart';

class InAppNotification {
  static OverlayEntry? _currentOverlay;

  /// Show a WhatsApp-style notification banner
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.notifications,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    // Remove any existing notification
    hide();

    final overlay = Overlay.of(context);
    final theme = Theme.of(context);
    
    _currentOverlay = OverlayEntry(
      builder: (context) => _NotificationBanner(
        title: title,
        message: message,
        icon: icon,
        backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
        onTap: onTap,
        onDismiss: hide,
      ),
    );

    overlay.insert(_currentOverlay!);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      hide();
    });
  }

  /// Hide the current notification
  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _NotificationBanner extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _NotificationBanner({
    required this.title,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  widget.onTap?.call();
                  _dismiss();
                },
                onVerticalDragUpdate: (details) {
                  // Swipe up to dismiss
                  if (details.delta.dy < -5) {
                    _dismiss();
                  }
                },
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  color: widget.backgroundColor,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Close button
                        IconButton(
                          onPressed: _dismiss,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
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

/// Different notification types with predefined colors and icons
class NotificationType {
  static void success(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    InAppNotification.show(
      context,
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: const Color(0xFF10B981), // Modern green
      onTap: onTap,
    );
  }

  static void error(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    InAppNotification.show(
      context,
      title: title,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: const Color(0xFFEF4444), // Modern red
      onTap: onTap,
    );
  }

  static void warning(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    InAppNotification.show(
      context,
      title: title,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: const Color(0xFFF59E0B), // Modern amber
      onTap: onTap,
    );
  }

  static void info(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    InAppNotification.show(
      context,
      title: title,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: const Color(0xFF3B82F6), // Modern blue
      onTap: onTap,
    );
  }

  static void taskReminder(
    BuildContext context, {
    required String taskTitle,
    VoidCallback? onTap,
  }) {
    InAppNotification.show(
      context,
      title: 'Task Reminder',
      message: taskTitle,
      icon: Icons.task_alt,
      onTap: onTap,
    );
  }

  static void waterReminder(
    BuildContext context, {
    VoidCallback? onTap,
  }) {
    InAppNotification.show(
      context,
      title: 'Stay Hydrated!',
      message: 'Time to drink some water 💧',
      icon: Icons.local_drink_rounded,
      backgroundColor: const Color(0xFF06B6D4), // Modern cyan
      onTap: onTap,
    );
  }

  static void habitReminder(
    BuildContext context, {
    required String habitTitle,
    VoidCallback? onTap,
  }) {
    InAppNotification.show(
      context,
      title: 'Habit Reminder',
      message: habitTitle,
      icon: Icons.repeat_rounded,
      backgroundColor: const Color(0xFF8B5CF6), // Modern purple
      onTap: onTap,
    );
  }
}
