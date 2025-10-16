import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:samapp/services/periodic_capsule_service.dart';

class ConnectivityService {
  StreamSubscription<ConnectivityResult>? _subscription;
  bool _isOffline = false;

  void startListening() {
    // Check initial state
    Connectivity().checkConnectivity().then((result) {
      _isOffline = !(result == ConnectivityResult.mobile || result == ConnectivityResult.wifi || result == ConnectivityResult.ethernet);
    });

    _subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      final bool isOnline = result == ConnectivityResult.mobile || result == ConnectivityResult.wifi || result == ConnectivityResult.ethernet;

      // If the status changes from offline to online, trigger the check.
      if (_isOffline && isOnline) {
        print('[ConnectivityService] Connection restored. Retrying capsule check...');
        PeriodicCapsuleService.onAppResumed();
      }

      _isOffline = !isOnline;
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<bool> hasActiveInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile ||
           connectivityResult == ConnectivityResult.wifi ||
           connectivityResult == ConnectivityResult.ethernet;
  }
}
