import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'nexus_service.dart';

StreamSubscription<ConnectivityResult>? _connectionSubscription;

void startConnectionWatcher() {
  if (_connectionSubscription != null) {
    print("⚠️ Connection watcher already running");
    return;
  }

  _connectionSubscription = Connectivity().onConnectivityChanged.listen(
    (ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        print("✅ Internet reconnected — resuming location sending...");
        try {
          await updateLocation();
          await startSendingLocation();
        } catch (e) {
          print("⚠️ Error resuming location sending: $e");
        }
      } else {
        print("❌ Internet disconnected — location updates paused");
      }
    },
    onError: (error) {
      print("🚨 Connection watcher error: $error");
    },
  );

  print("🔍 Connection watcher started");
}

void stopConnectionWatcher() {
  if (_connectionSubscription != null) {
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    print("🛑 Connection watcher stopped");
  } else {
    print("⚠️ Connection watcher was not running");
  }
}
