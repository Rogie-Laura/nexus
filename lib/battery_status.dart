import 'package:battery_plus/battery_plus.dart';

Future<int> getBatteryStatus() async {
  final battery = Battery();
  return await battery.batteryLevel;
}
