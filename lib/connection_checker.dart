import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

Future<bool> isInternetAvailable() async {
  final result = await Connectivity().checkConnectivity();
  final hasConnection = await InternetConnectionChecker().hasConnection;

  if (result == ConnectivityResult.none || !hasConnection) {
    return false;
  }
  return true;
}
