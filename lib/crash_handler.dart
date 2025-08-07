import 'package:shared_preferences/shared_preferences.dart';
import 'nexus_service.dart';

/// ✅ Crash Handler
/// Automatically logs out from Nexus backend if the app was terminated without proper logout.
Future<void> handleCrashRecovery() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (isLoggedIn) {
    print("🛑 App crash or forced close detected. Auto-logging out...");

    try {
      await logoutFromNexus();
      print("✅ Successfully logged out from Nexus backend.");
    } catch (e) {
      print("❌ Failed to auto-logout: \$e");
    }

    await prefs.setBool('isLoggedIn', false);
  } else {
    print("✅ App closed normally or already logged out.");
  }
}
