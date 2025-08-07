import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'get_location.dart';
import 'battery_status.dart';
import 'connection_status.dart';
import 'run_background.dart';

Future<void> loginToNexus() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final deploymentID = prefs.getString('deploymentID') ?? '';

  final url = Uri.parse(
    'https://asia-southeast1-nexuspolice-13560.cloudfunctions.net/setUnit',
  );

  final body = jsonEncode({
    "deploymentCode": deploymentID,
    "action": "login",
    "call_sign": "R4A-211", // 🔒 Hardcoded Call Sign
    "personnel": [
      {"name": "Juan Dela Cruz", "phone": "09123456789"},
    ],
    "radioequipment": "Motorola GP328",
    "videoequipment": "Body Cam Pro",
  });

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: body,
  );

  print("✅ Nexus Login: ${response.statusCode} - ${response.body}");

  await startBackgroundTask();
}

Future<void> logoutFromNexus() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final deploymentID = prefs.getString('deploymentID') ?? '';

  final url = Uri.parse(
    'https://asia-southeast1-nexuspolice-13560.cloudfunctions.net/setUnit',
  );

  final body = jsonEncode({"deploymentCode": deploymentID, "action": "logout"});

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: body,
  );

  print("🚪 Nexus Logout: ${response.statusCode} - ${response.body}");

  // 🔁 Stop background tracking
  await stopBackgroundTask();
}

Future<void> updateLocation() async {
  final coords = await getCurrentLocation();

  if (coords == null) {
    print('❌ Skipped: location unavailable');
    return;
  }

  final battery = await getBatteryStatus();
  final signal = await getSignalStrength();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final deploymentID = prefs.getString('deploymentID') ?? '';

  final url = Uri.parse(
    'https://asia-southeast1-nexuspolice-13560.cloudfunctions.net/updateLocation',
  );

  final payload = {
    "deploymentCode": deploymentID,
    "location": {
      "latitude": coords.latitude,
      "longitude": coords.longitude,
      "accuracy": coords.accuracy ?? 0,
    },
    "batteryStatus": battery,
    "signal": signal,
  };

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(payload),
  );

  print("📍 Sent location: ${jsonEncode(payload)}");
  print("📡 Response: ${response.statusCode} - ${response.body}");
}

Future<void> startSendingLocation() async {
  // Optional: can be called once on login
  await updateLocation();
}

Future<void> stopSendingLocation() async {
  // Optional: handled by stopping timers
  print("🛑 Location sending stopped (timers cancelled).");
}
