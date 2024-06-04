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

  static filterTourType(TourType tourType, List<Tour> tours) {
    if (tourType == TourType.upcoming) {
      return tours.where((tour) {
        return tour.tourDetails.startDate.isAfter(DateTime.now());
      }).toList();
    } else if (tourType == TourType.past) {
      return tours.where((tour) {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        return tour.tourDetails.startDate.isBefore(yesterday);
      }).toList();
    } else {
      // live tours
      return tours.where((tour) {
        return _isSameDay(tour.tourDetails.startDate, DateTime.now());
      }).toList();
    }
  }

  static List<Tour> filterTours({
    required List<Tour> tours,
    required String selectedFilterValue,
    required Position? currentPosition,
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
        return TourFilter.filterByActivities([TourCategory.family], tours);
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
