import 'dart:async';
import 'package:samapp/services/capsule_check_service.dart';
import 'package:samapp/services/logging_service.dart';

/// Service that manages periodic checking of legacy capsules for automatic email sending.
/// 
/// This service runs in the background and periodically checks for legacy capsules
/// that need to be sent via email. It provides a reliable mechanism to ensure
/// capsules are sent even when the app is not actively being used.
/// 
/// Features:
/// - Hourly periodic checks using Timer
/// - App lifecycle integration (foreground/background events)
/// - Automatic startup and shutdown management
/// - Initial check on service start
/// - Connectivity-aware operations
/// 
/// Usage:
/// ```dart
/// // Start the service (typically in main.dart)
/// PeriodicCapsuleService.startPeriodicCheck();
/// 
/// // Handle app lifecycle events
/// PeriodicCapsuleService.onAppResumed();
/// PeriodicCapsuleService.onAppPaused();
/// 
/// // Stop the service when needed
/// PeriodicCapsuleService.stopPeriodicCheck();
/// ```
class PeriodicCapsuleService {
  /// Timer instance for periodic capsule checks
  static Timer? _timer;
  
  /// Interval between automatic capsule checks (1 hour)
  static const Duration _checkInterval = Duration(hours: 1);
  
  /// Starts the periodic capsule checking service.
  /// 
  /// This method initializes a timer that runs every hour to check for
  /// legacy capsules that need to be sent. It also performs an initial
  /// check immediately upon starting.
  /// 
  /// If a timer is already running, it will be cancelled and replaced
  /// with a new one to prevent multiple timers from running simultaneously.
  static void startPeriodicCheck() {
    // Cancel any existing timer
    stopPeriodicCheck();
    
    AppLogger.info('Starting periodic capsule checks every ${_checkInterval.inHours} hour(s)');
    
    // Start the periodic timer
    _timer = Timer.periodic(_checkInterval, (timer) async {
      AppLogger.debug('Running scheduled capsule check...');
      try {
        await CapsuleCheckService().checkAndSendCapsules();
      } catch (e, stackTrace) {
        AppLogger.error('Error during periodic check', e, stackTrace);
      }
    });
    
    // Also run an initial check
    _runInitialCheck();
  }
  
  static void stopPeriodicCheck() {
    if (_timer != null) {
      AppLogger.info('Stopping periodic capsule checks');
      _timer!.cancel();
      _timer = null;
    }
  }
  
  static void _runInitialCheck() async {
    AppLogger.debug('Running initial capsule check...');
    try {
      await CapsuleCheckService().checkAndSendCapsules();
    } catch (e, stackTrace) {
      AppLogger.error('Error during initial check', e, stackTrace);
    }
  }
  
  // Call this when app comes to foreground
  static void onAppResumed() {
    AppLogger.debug('App resumed, running capsule check...');
    _runInitialCheck();
  }
  
  // Call this when app goes to background
  static void onAppPaused() {
    AppLogger.debug('App paused - timer continues in background');
    // Keep timer running in background for periodic checks
  }
}
