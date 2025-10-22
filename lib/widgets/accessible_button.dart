import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samapp/utils/accessibility_utils.dart';

/// An accessible button widget with enhanced screen reader support.
/// 
/// This widget extends the standard ElevatedButton with additional
/// accessibility features including semantic labels, haptic feedback,
/// and screen reader announcements.
/// 
/// Features:
/// - Automatic semantic labeling
/// - Haptic feedback on press
/// - Screen reader announcements
/// - Loading state support
/// - Custom accessibility hints
/// 
/// Usage:
/// ```dart
/// AccessibleButton(
///   onPressed: () => _addTask(),
///   child: Text('Add Task'),
///   semanticLabel: 'Add new task to your list',
///   hapticFeedback: true,
///   announceOnPress: 'Task added successfully',
/// )
/// ```
class AccessibleButton extends StatelessWidget {
  /// The callback function when button is pressed
  final VoidCallback? onPressed;
  
  /// The child widget to display inside the button
  final Widget child;
  
  /// Custom semantic label for screen readers
  final String? semanticLabel;
  
  /// Hint text for screen readers
  final String? semanticHint;
  
  /// Whether to provide haptic feedback on press
  final bool hapticFeedback;
  
  /// Message to announce after button press
  final String? announceOnPress;
  
  /// Whether the button is in loading state
  final bool isLoading;
  
  /// Loading widget to show when isLoading is true
  final Widget? loadingWidget;
  
  /// Button style
  final ButtonStyle? style;
  
  /// Focus node for keyboard navigation
  final FocusNode? focusNode;
  
  /// Auto focus flag
  final bool autofocus;

  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.hapticFeedback = true,
    this.announceOnPress,
    this.isLoading = false,
    this.loadingWidget,
    this.style,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: onPressed != null && !isLoading,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handlePress(context),
        style: style,
        focusNode: focusNode,
        autofocus: autofocus,
        child: isLoading 
          ? (loadingWidget ?? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ))
          : child,
      ),
    );
  }

  VoidCallback? _handlePress(BuildContext context) {
    if (onPressed == null) return null;
    
    return () {
      // Provide haptic feedback
      if (hapticFeedback) {
        HapticFeedback.lightImpact();
      }
      
      // Call the original callback
      onPressed!();
      
      // Announce to screen reader if specified
      if (announceOnPress != null) {
        AccessibilityUtils.announceToScreenReader(context, announceOnPress!);
      }
    };
  }
}

/// An accessible floating action button with enhanced features.
class AccessibleFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final String? tooltip;
  final bool hapticFeedback;
  final String? announceOnPress;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final FocusNode? focusNode;

  const AccessibleFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.tooltip,
    this.hapticFeedback = true,
    this.announceOnPress,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? tooltip,
      button: true,
      enabled: onPressed != null && !isLoading,
      child: FloatingActionButton(
        onPressed: isLoading ? null : _handlePress(context),
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        focusNode: focusNode,
        child: isLoading 
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : child,
      ),
    );
  }

  VoidCallback? _handlePress(BuildContext context) {
    if (onPressed == null) return null;
    
    return () {
      if (hapticFeedback) {
        HapticFeedback.lightImpact();
      }
      
      onPressed!();
      
      if (announceOnPress != null) {
        AccessibilityUtils.announceToScreenReader(context, announceOnPress!);
      }
    };
  }
}

/// An accessible icon button with enhanced features.
class AccessibleIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String? semanticLabel;
  final String? tooltip;
  final bool hapticFeedback;
  final String? announceOnPress;
  final Color? color;
  final double? iconSize;
  final FocusNode? focusNode;

  const AccessibleIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.semanticLabel,
    this.tooltip,
    this.hapticFeedback = true,
    this.announceOnPress,
    this.color,
    this.iconSize,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? tooltip,
      button: true,
      enabled: onPressed != null,
      child: IconButton(
        onPressed: onPressed != null ? _handlePress(context) : null,
        icon: icon,
        tooltip: tooltip,
        color: color,
        iconSize: iconSize,
        focusNode: focusNode,
      ),
    );
  }

  VoidCallback _handlePress(BuildContext context) {
    return () {
      if (hapticFeedback) {
        HapticFeedback.lightImpact();
      }
      
      onPressed!();
      
      if (announceOnPress != null) {
        AccessibilityUtils.announceToScreenReader(context, announceOnPress!);
      }
    };
  }
}
