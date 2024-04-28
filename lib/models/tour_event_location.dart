class TourEventLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String address;

  TourEventLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory TourEventLocation.fromJson(Map<String, dynamic> json) {
    return TourEventLocation(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
    );
  }
}
