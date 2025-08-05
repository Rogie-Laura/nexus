import 'package:connectivity_plus/connectivity_plus.dart';

Future<String> getConnectionType() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.mobile) {
    return "Mobile Data";
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return "WiFi";
  } else {
    return "No Connection";
  }
}
