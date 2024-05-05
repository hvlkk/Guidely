class Waypoint {
  final String address;
  final double latitude;
  final double longitude;

  const Waypoint({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory Waypoint.fromMap(Map<String, dynamic> map) {
    return Waypoint(
      address: map['address'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
    );
  }

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    return Waypoint(
      address: json['address'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  get area => address.split(',').first;
}
