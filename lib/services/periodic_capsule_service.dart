import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:samapp/services/capsule_check_service.dart';

class PeriodicCapsuleService {
  static Timer? _timer;
  static const Duration _checkInterval = Duration(hours: 1); // Check every hour
  
  static void startPeriodicCheck() {
    // Cancel any existing timer
    stopPeriodicCheck();
    
    print('[PeriodicCapsuleService] Starting periodic capsule checks every ${_checkInterval.inHours} hour(s)');
    
    // Start the periodic timer
    _timer = Timer.periodic(_checkInterval, (timer) async {
      print('[PeriodicCapsuleService] Running scheduled capsule check...');
      try {
        await CapsuleCheckService().checkAndSendCapsules();
      } catch (e) {
        print('[PeriodicCapsuleService] Error during periodic check: $e');
      }
    });
    
    // Also run an initial check
    _runInitialCheck();
  }
  
  static void stopPeriodicCheck() {
    if (_timer != null) {
      print('[PeriodicCapsuleService] Stopping periodic capsule checks');
      _timer!.cancel();
      _timer = null;
    }
  }
  
  static void _runInitialCheck() async {
    print('[PeriodicCapsuleService] Running initial capsule check...');
    try {
      await CapsuleCheckService().checkAndSendCapsules();
    } catch (e) {
      print('[PeriodicCapsuleService] Error during initial check: $e');
    }
  }
  
  // Call this when app comes to foreground
  static void onAppResumed() {
    print('[PeriodicCapsuleService] App resumed, running capsule check...');
    _runInitialCheck();
  }
  
  // Call this when app goes to background
  static void onAppPaused() {
    print('[PeriodicCapsuleService] App paused');
    // Keep timer running in background for periodic checks
  }
}
