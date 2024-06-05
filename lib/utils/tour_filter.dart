import 'package:geolocator/geolocator.dart';
import 'package:guidely/models/data/activity.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/utils/tour_category.dart';
import 'package:guidely/utils/location_finder.dart';

enum TourType {
  live,
  upcoming,
  past,
}

enum FilterBy { title, location, activities, description }

class TourFilter {
  static filterSearchBar(String filterValue, List<Tour> tours) {
    return tours.where((tour) {
      return tour.tourDetails.title
              .toLowerCase()
              .contains(filterValue.toLowerCase()) ||
          tour.tourDetails.description
              .toLowerCase()
              .contains(filterValue.toLowerCase()) ||
          tour.tourDetails.activities.map((activity) {
            return activity.name
                .toLowerCase()
                .contains(filterValue.toLowerCase());
          }).contains(true);
    }).toList();
  }

  static List<Tour> filterTourType(TourType tourType, List<Tour> tours) {
    final now = DateTime.now();
    return tours.where((tour) {
      final startDateTime = DateTime(
        tour.tourDetails.startDate.year,
        tour.tourDetails.startDate.month,
        tour.tourDetails.startDate.day,
        tour.tourDetails.startTime.hour,
        tour.tourDetails.startTime.minute,
      );

      if (tourType == TourType.upcoming) {
        return startDateTime.isAfter(now.add(const Duration(minutes: 5)));
      } else if (tourType == TourType.past) {
        return startDateTime.isBefore(now.subtract(const Duration(minutes: 1)));
      } else {
        return startDateTime
                .isAfter(now.subtract(const Duration(minutes: 5))) &&
            startDateTime.isBefore(now.add(const Duration(minutes: 1)));
      }
    }).toList();
  }

  static TourState determineTourState(Tour tour) {
    final now = DateTime.now();
    final startDateTime = DateTime(
      tour.tourDetails.startDate.year,
      tour.tourDetails.startDate.month,
      tour.tourDetails.startDate.day,
      tour.tourDetails.startTime.hour,
      tour.tourDetails.startTime.minute,
    );

    if (startDateTime.isAfter(now.add(const Duration(minutes: 5)))) {
      return TourState.upcoming;
    } else if (startDateTime
        .isBefore(now.subtract(const Duration(minutes: 1)))) {
      return TourState.past;
    } else {
      return TourState.live;
    }
  }

  static List<Tour> filterTours({
    required List<Tour> tours,
    required String selectedFilterValue,
    required Position? currentPosition,
    required List<TourCategory> userCategories,
  }) {
    switch (selectedFilterValue) {
      case 'Nearby':
        if (currentPosition != null) {
          return LocationFinder.findClosestToursToPosition(
            tours,
            currentPosition,
            8,
          );
        }
        break;
      case 'Highest Rated':
        return TourFilter.sortByRating(tours);
      case 'Activities':
        return TourFilter.filterByActivities(userCategories, tours);
      case 'Starting Soon':
        return TourFilter.filterByStartingSoon(tours);
      default:
        break;
    }
    return [];
  }

  // filter by user's favorite activities
  static List<Tour> filterByActivities(
      List<TourCategory> activities, List<Tour> tours) {
    return tours.where((tour) {
      for (var activity in tour.tourDetails.activities) {
        for (var userActivity in Activity.mapActivityToTourCategory(activity)) {
          if (activities.contains(userActivity)) {
            return true;
          }
        }
      }
      return false; // Return false if no matching activities are found
    }).toList(); // Convert the filtered Iterable back to a List
  }

  // tours that are starting soon (within 3 days)
  static filterByStartingSoon(List<Tour> tours) {
    final threeDaysAgo = DateTime.now().add(const Duration(days: 3));

    return tours.where((tour) {
      bool isToday = _isSameDay(tour.tourDetails.startDate, DateTime.now());
      return isToday ||
          (tour.tourDetails.startDate.isAfter(DateTime.now()) &&
              tour.tourDetails.startDate.isBefore(threeDaysAgo));
    }).toList();
  }

  // sort by rating
  static sortByRating(List<Tour> tours) {
    tours.sort((a, b) => b.rating.compareTo(a.rating));
    return tours;
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }
}
