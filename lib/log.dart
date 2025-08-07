import 'connection_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nexus_service.dart';
import 'connection_checker.dart';

Future<void> handleLoginLogout({
  required BuildContext context,
  required String token,
  required String deployment,
  required bool isLoggedIn,
  required void Function(void Function()) setState,
  required Future<void> Function() loginToNexus,
  required Future<void> Function() logoutFromNexus,
  required Future<void> Function() startSendingLocation,
  required Future<void> Function() stopSendingLocation,
  required Future<void> Function() loadStatus,
  required void Function() startTimers,
  required void Function() stopTimers,
  required void Function(bool) updateLoginState,
  required void Function(bool) updateButtonState,
  required void Function(String) updateCountdown,
  required void Function(bool) updateTextFieldEnabled,
}) async {
  // ✅ Check Internet First
  if (!await isInternetAvailable()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '❌ You are currently not connected to the internet.\nPlease make sure that your mobile data is ON and has active connection.',
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 80, left: 16, right: 16),
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }

  if (token.isEmpty || deployment.isEmpty) {
    return;
  }

  // ✅ STOP
  if (isLoggedIn) {
    final stopConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Stop Operation?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to Stop the Current Operation?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Stop', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (stopConfirm != true) {
      updateButtonState(false);
      updateCountdown('');
      return;
    }

    await logoutFromNexus();
    await stopSendingLocation();
    stopTimers();
    stopConnectionWatcher(); // 🛑 stop watching internet connection

    updateLoginState(false);
    updateButtonState(false);
    updateTextFieldEnabled(true); // 🔓 enable after logout
    return;
  }

  // ✅ LOGIN
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text('Confirm Login', style: TextStyle(color: Colors.white)),
      content: Text(
        'Log to Nexus Server?\n\nDeployment ID: $deployment',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('No', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Yes', style: TextStyle(color: Colors.green)),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  updateButtonState(true);
  updateTextFieldEnabled(false); // 🔒 disable after login confirmed
  updateCountdown('Enabling in 3...');
  await Future.delayed(const Duration(seconds: 1));
  updateCountdown('Enabling in 2...');
  await Future.delayed(const Duration(seconds: 1));
  updateCountdown('Enabling in 1...');
  await Future.delayed(const Duration(seconds: 1));
  updateCountdown('');

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  await prefs.setString('deploymentID', deployment);

  await loginToNexus();
  await loadStatus();
  await startSendingLocation();
  startTimers();
  startConnectionWatcher(); // 🔁 start watching internet connection

  updateLoginState(true);
  updateButtonState(false);
}
