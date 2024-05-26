import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guidely/models/data/tour_creation_data.dart';
import 'package:guidely/models/entities/review.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/models/utils/tour_category.dart';

enum TourState {
  upcoming,
  live,
  past,
}

class Tour {
  Tour({
    required this.tourDetails,
    required this.uid,
    required this.organizer,
    required this.reviews,
    required this.state,
    this.images = const [],
    this.categories = const [],
    this.registeredUsers = const [],
  });

  final TourCreationData tourDetails;
  final List<String> images;
  final User organizer;
  final String uid;

  List<String> registeredUsers;
  final List<Review> reviews;
  final List<TourCategory> categories;

  TourState state = TourState.upcoming;

  get country => tourDetails.waypoints![0].address.split(',').last;
  get location => tourDetails.waypoints![0].address.split(',').first;
  get rating => reviews.isEmpty
      ? 0.0
      : reviews.map((review) => review.grade).reduce((a, b) => a + b) /
          reviews.length;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'tourDetails': tourDetails.toMap(),
      'location': location,
      'country': country,
      'images': images,
      'organizer': organizer.toMap(),
      'state': state.toString().split('.').last,
      'rating': rating,
      'categories':
          categories.map((category) => tourCategoryToString[category]).toList(),
      'registeredUsers': registeredUsers,
    };
  }

  factory Tour.fromMap(Map<String, dynamic> map) {
    return Tour(
      tourDetails: TourCreationData.fromMap(map['tourDetails']),
      images: List<String>.from(map['images'] ?? []),
      organizer: User.fromMap(map['organizer']),
      uid: map['uid'],
      registeredUsers: List<String>.from(map['registeredUsers'] ?? []),
      reviews: List<Review>.from(
        map['reviews']?.map((review) => Review.fromMap(review)) ?? [],
      ),
      categories: List<TourCategory>.from(
        map['categories']
                ?.map((category) => tourCategoryFromString[category]) ??
            [],
      ),
      state: TourState.values.firstWhere(
        (element) => element.toString() == 'TourState.${map['state']}',
      ),
    );
  }

  factory Tour.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    Tour tour = Tour(
      uid: data['uid'],
      state: TourState.values.firstWhere(
        (element) => element.toString() == 'TourState.${data['state']}',
      ),
      tourDetails: TourCreationData.fromMap(data['tourDetails']),
      images: List<String>.from(data['images'] ?? []),
      organizer: User.fromMap(data['organizer']),
      reviews: List<Review>.from(
          data['reviews']?.map((review) => Review.fromMap(review)) ?? []),
      categories: List<TourCategory>.from(
        data['categories']
                ?.map((category) => tourCategoryFromString[category]) ??
            [],
      ),
      registeredUsers: List<String>.from(data['registeredUsers'] ?? []),
    );
    return tour;
  }

  @override
  String toString() {
    return 'Tour(tour, images: $images, organizer: $organizer, state: $state, rating: $rating, uid: $uid, registeredUsers: $registeredUsers, reviews: $reviews)';
  }
}
