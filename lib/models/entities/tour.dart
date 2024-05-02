import 'package:guidely/models/data/tour_creation_data.dart';
import 'package:guidely/models/entities/user.dart';

enum TourState {
  upcoming,
  live,
  past,
}

class Tour {
  Tour({
    required this.tourDetails,
    this.duration = const Duration(hours: 2),
    this.images = const [],
    required this.organizer,
  });

  final TourCreationData tourDetails;
  final Duration duration;
  final List<String> images;
  final User organizer;

  final TourState state = TourState.upcoming;
  final double rating = 4.0;

  get area => 'Demo';
  // tourDetails.waypoints![0].address.split(',')[0]

  Map<String, dynamic> toMap() {
    return {
      'tourDetails': tourDetails.toMap(),
      'area': area,
      'duration': duration.inSeconds,
      'images': images,
      'organizer': organizer.toMap(),
      'state': state.toString().split('.').last,
      'rating': rating,
    };
  }
}
