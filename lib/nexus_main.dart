import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connection_type.dart';
import 'connection_status.dart';
import 'battery_status.dart';
import 'location_accuracy.dart';
import 'get_location.dart';
import 'dart:async';
import 'nexus_service.dart';
import 'run_background.dart';
import 'txt_checking.dart';
import 'log.dart';

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Nexus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E1E1E),
          border: OutlineInputBorder(),
          hintStyle: TextStyle(color: Colors.white54),
        ),
      ),
      home: const NexusLoginScreen(),
    );
  }
}

class NexusLoginScreen extends StatefulWidget {
  const NexusLoginScreen({super.key});

  @override
  State<NexusLoginScreen> createState() => _NexusLoginScreenState();
}

class _NexusLoginScreenState extends State<NexusLoginScreen> {
  final tokenController = TextEditingController();
  final deploymentController = TextEditingController();

  final tokenFocusNode = FocusNode();
  final deploymentFocusNode = FocusNode();

  String _connectionType = '';
  String _connectionStrength = '';
  String _batteryStatus = '';
  String _locationAccuracy = '';
  bool _isLoggedIn = false;
  bool _buttonDisabled = false;

  Timer? _locationTimer;
  Timer? _batteryTimer;
  Timer? _signalTimer;
  bool _textFieldsEnabled = true;

  String _countdownText = '';

  @override
  void initState() {
    super.initState();
    _loadStatus();

    tokenController.addListener(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', tokenController.text);
    });

    deploymentController.addListener(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('deploymentID', deploymentController.text);
    });
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    tokenController.text = prefs.getString('token') ?? '';
    deploymentController.text = prefs.getString('deploymentID') ?? '';

    final type = await getConnectionType();
    final strength = await getSignalStrength();
    final battery = await getBatteryStatus();
    final accuracy = await getLocationAccuracy();

    setState(() {
      _connectionType = type;
      _connectionStrength = strength;
      _batteryStatus = '$battery%';
      _locationAccuracy = accuracy >= 0
          ? '${accuracy.toStringAsFixed(1)} m'
          : 'Unavailable';
    });
  }

  void startTimers() {
    _locationTimer?.cancel();
    _batteryTimer?.cancel();
    _signalTimer?.cancel();

    _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await updateLocation();
    });

    _batteryTimer = Timer.periodic(const Duration(seconds: 180), (_) async {
      final battery = await getBatteryStatus();
      print('🔋 Battery: $battery%');
    });

    _signalTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final signal = await getSignalStrength();
      final type = await getConnectionType();
      setState(() {
        _connectionStrength = signal;
        _connectionType = type;
      });
      print('📶 Signal: $signal');
      print('📶 Type: $type');
    });
  }

  void stopTimers() {
    _locationTimer?.cancel();
    _batteryTimer?.cancel();
    _signalTimer?.cancel();
  }

  @override
  void dispose() {
    stopTimers();
    tokenController.dispose();
    deploymentController.dispose();
    tokenFocusNode.dispose();
    deploymentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        const platform = MethodChannel('android_app_retain');
        try {
          await platform.invokeMethod('moveToBackground');
        } on PlatformException catch (e) {
          print("❌ Failed to move to background: ${e.message}");
        }
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/pnp_logo.png', height: 40),
              const Text('Project Nexus'),
              Image.asset('assets/pro4a_logo.png', height: 40),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                TextField(
                  controller: tokenController,
                  focusNode: tokenFocusNode,
                  enabled: _textFieldsEnabled,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter your Token',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: deploymentController,
                  focusNode: deploymentFocusNode,
                  enabled: _textFieldsEnabled,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter Deployment ID',
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _buttonDisabled
                        ? null
                        : () => handleLoginLogout(
                            context: context,
                            token: tokenController.text.trim(),
                            deployment: deploymentController.text.trim(),
                            isLoggedIn: _isLoggedIn,
                            setState: setState,
                            loginToNexus: loginToNexus,
                            logoutFromNexus: logoutFromNexus,
                            startSendingLocation: startSendingLocation,
                            stopSendingLocation: stopSendingLocation,
                            loadStatus: _loadStatus,

                            startTimers: startTimers,
                            stopTimers: stopTimers,
                            updateLoginState: (value) =>
                                setState(() => _isLoggedIn = value),
                            updateButtonState: (value) =>
                                setState(() => _buttonDisabled = value),
                            updateCountdown: (value) =>
                                setState(() => _countdownText = value),
                            updateTextFieldEnabled: (value) =>
                                setState(() => _textFieldsEnabled = value),
                          ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoggedIn ? Colors.red : Colors.teal,
                    ),
                    child: Text(
                      _isLoggedIn
                          ? 'Stop Operation'
                          : (_countdownText.isEmpty
                                ? 'Log in to Nexus'
                                : _countdownText),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  color: Colors.grey[900],
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connection Status: $_connectionStrength',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Battery Status: $_batteryStatus',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Location Accuracy: $_locationAccuracy',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'DEVELOPED BY RCC4A AND RICTMD4A',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color.fromARGB(95, 130, 227, 242)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
