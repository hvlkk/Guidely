import 'package:guidely/models/entities/tour.dart';

enum TourType {
  live,
  upcoming,
  past,
}

enum FilterBy { title, location, activities, description }

class TourFilterService {
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
        return tour.tourDetails.startDate.day == (DateTime.now().day) &&
            tour.tourDetails.startDate.month == (DateTime.now().month) &&
            tour.tourDetails.startDate.year == (DateTime.now().year);
      }).toList();
    }
  }
}
