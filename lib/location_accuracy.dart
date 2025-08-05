import 'package:location/location.dart';

Future<double> getLocationAccuracy() async {
  final location = Location();

  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) return -1; // if user denies
  }

  PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) return -1;
  }

  final currentLocation = await location.getLocation();
  return currentLocation.accuracy ?? -1;
}
