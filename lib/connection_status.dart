import 'connection_type.dart';

Future<String> getSignalStrength() async {
  final type = await getConnectionType();
  return (type == "WiFi" || type == "Mobile Data") ? "Strong" : "Weak";
}
