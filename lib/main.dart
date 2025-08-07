import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'nexus_main.dart';
import 'crash_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await handleCrashRecovery(); // ✅ Auto-logout if previous crash

  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'nexus_channel_id',
      channelName: 'Nexus Tracking',
      channelDescription: 'Background tracking is active.',
      channelImportance: NotificationChannelImportance.HIGH,
      priority: NotificationPriority.HIGH,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 3000,
      isOnceEvent: false,
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );

  runApp(const NexusApp());
}
