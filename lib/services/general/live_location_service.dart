import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class LiveLocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Location _location = Location();

  LiveLocationService() {
    _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 10000, // Update interval in milliseconds (10 seconds)
    );
  }

  // DUPLICATE CODE WILL FIX
  Future<void> updateLocation(String organizerId) async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
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
