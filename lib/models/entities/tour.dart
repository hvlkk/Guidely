import 'package:guidely/models/data/tour_event_location.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/models/utils/language.dart';

enum TourState {
  upcoming,
  live,
  past,
}

class Tour {
  const Tour({
    required this.title,
    required this.area,
    required this.description,
    required this.duration,
    required this.images,
    required this.languages,
    required this.startLocation,
    required this.locations,
    required this.organizer,
  });

  final String title;
  final String area;
  final String description;
  final Duration duration;
  final List<String> images;
  final List<Language> languages;
  final TourEventLocation startLocation;
  final List<TourEventLocation> locations;
  final User organizer;

  final TourState state = TourState.upcoming;
  final double rating = 4.0;
}
