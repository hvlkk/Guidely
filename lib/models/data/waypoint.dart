class Waypoint {
  final String address;
  final double latitude;
  final double longitude;

  Waypoint(
      {required this.address, required this.latitude, required this.longitude});

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    return Waypoint(
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
