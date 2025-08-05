import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'nexus_service.dart';

class NexusTaskHandler extends TaskHandler {
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) {
    print('✅ TaskHandler started: $timestamp');
    sendPort?.send(null); // optional
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    print('📍 Sending location at $timestamp');
    updateLocation();
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    print('🛑 TaskHandler destroyed: $timestamp');
    sendPort?.send(null);
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  @override
  void onButtonPressed(String id) {}
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(NexusTaskHandler());
}

Future<void> startBackgroundTask() async {
  await FlutterForegroundTask.startService(
    notificationTitle: 'Nexus Tracking Active',
    notificationText: 'Location updates are running.',
    callback: startCallback,
  );
}

Future<void> stopBackgroundTask() async {
  await FlutterForegroundTask.stopService();
}
