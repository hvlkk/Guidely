import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:geolocator/geolocator.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/utils/tour_filter.dart';
import 'package:guidely/models/utils/tour_category.dart';

class ToursHomeBloc {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> userStream;
  List<TourCategory> userCategories = [];

  ToursHomeBloc() {
    final user = FirebaseAuth.instance.currentUser;
    userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots();
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      return null;
    }
  }

  void setUserCategories(List<TourCategory> userCategories) {
    this.userCategories = userCategories;
  }

  List<Tour> filterTours(
      List<Tour> tours, String selectedFilterValue, Position? currentPosition) {
    return TourFilter.filterTours(
        tours: tours,
        selectedFilterValue: selectedFilterValue,
        currentPosition: currentPosition,
        userCategories: userCategories);
  }

  List<Tour> filterSearchBar(String query, List<Tour> tours) {
    return TourFilter.filterSearchBar(query, tours);
  }
}
