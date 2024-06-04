import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/repositories/tour_repository.dart';

final tourRepositoryProvider = Provider((ref) => TourRepository());

final toursStreamProvider = StreamProvider.autoDispose<List<Tour>>((ref) {
  final repository = ref.read(tourRepositoryProvider);
  return repository.getToursStream();
});

final pastToursProvider = StreamProvider.autoDispose<List<Tour>>((ref) {
  final repository = ref.read(tourRepositoryProvider);
  return repository.getFilteredToursStream(TourState.past);
});

final liveToursProvider = StreamProvider.autoDispose<List<Tour>>((ref) {
  final repository = ref.read(tourRepositoryProvider);
  return repository.getFilteredToursStream(TourState.live);
});

final upcomingToursProvider = StreamProvider.autoDispose<List<Tour>>((ref) {
  final repository = ref.read(tourRepositoryProvider);
  return repository.getFilteredToursStream(TourState.upcoming);
});
