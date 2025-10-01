import 'package:flutter/services.dart';

/// Service for haptic feedback throughout the app
class HapticService {
  /// Light impact feedback for button taps
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact feedback for selections
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact feedback for important actions
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click for toggles and checkboxes
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate feedback for errors or warnings
  static void vibrate() {
    HapticFeedback.vibrate();
  }

  /// Success feedback (medium impact)
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Error feedback (heavy impact + vibrate)
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Delete feedback (heavy impact)
  static void delete() {
    HapticFeedback.heavyImpact();
  }
}
