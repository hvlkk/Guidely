import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class LiveLocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Location _location = Location();

  LiveLocationService() {
    _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 10000,
    );
  }

  Future<void> updateLocation(String organizerId) async {
    if (!(await _location.serviceEnabled() &&
        await _location.requestService())) {
      return;
    }
    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return; // Return early if permission was not granted
      }
    }
    LocationData locationData = await _location.getLocation();
    await _firestore.collection('locations').doc(organizerId).set({
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<LocationData> getLocationStream() {
    return _location.onLocationChanged;
  }
}
