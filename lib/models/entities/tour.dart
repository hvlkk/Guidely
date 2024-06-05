import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guidely/models/data/quiz/quiz.dart';
import 'package:guidely/models/data/tour_creation_data.dart';
import 'package:guidely/models/entities/review.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/models/utils/tour_category.dart';
import 'package:guidely/services/business_layer/tour_service.dart';

enum TourState {
  upcoming,
  live,
  inSession,
  past,
}

class Tour {
  Tour({
    required this.tourDetails,
    required this.uid,
    required this.organizer,
    required this.reviews,
    required this.state,
    required this.creationDate,
    this.images = const [],
    this.categories = const [],
    this.registeredUsers = const [],
    this.quizzes = const [],
    this.hasStarted = false,
  }) {
    state = determineTourState();
  }

  final TourCreationData tourDetails;
  final List<String> images;
  final User organizer;
  final String uid;
  List<String> registeredUsers;
  final List<Review> reviews;
  final List<TourCategory> categories;
  final List<Quiz> quizzes;
  final bool hasStarted;

  final DateTime creationDate;

  TourState state;

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
      'quizzes': quizzes.map((quiz) => quiz.toMap()).toList(),
      'creationDate': DateTime.now(),
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
      quizzes: List<Quiz>.from(
        map['quizzes']?.map((quiz) => Quiz.fromMap(quiz)) ?? [],
      ),
      hasStarted: map['hasStarted'] ?? false,
      creationDate: map['creationDate'].toDate(),
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
      quizzes: List<Quiz>.from(
        data['quizzes']?.map((quiz) => Quiz.fromMap(quiz)) ?? [],
      ),
      hasStarted: data['hasStarted'] ?? false,
      creationDate: data['creationDate'].toDate(),
    );
    return tour;
  }

  get sessionId =>
      uid +
      organizer.uid +
      tourDetails.startDate.toString() +
      tourDetails.startTime.toString();

  bool isTourGuide(String uid) {
    return organizer.uid == uid;
  }

  @override
  String toString() {
    return 'Tour(tour, images: $images, organizer: $organizer, state: $state, rating: $rating, uid: $uid, registeredUsers: $registeredUsers, reviews: $reviews)';
  }

  TourState determineTourState() {
    if (state == TourState.past) {
      return TourState.past;
    }

    DateTime now = DateTime.now();
    final startDateTime = DateTime(
      tourDetails.startDate.year,
      tourDetails.startDate.month,
      tourDetails.startDate.day,
      tourDetails.startTime.hour,
      tourDetails.startTime.minute,
    );
    var durationInMinutes =
        tourDetails.duration.hour * 60 + tourDetails.duration.minute + 5;

    if (startDateTime.isBefore(now.add(const Duration(minutes: 5))) &&
        startDateTime
            .isAfter(now.subtract(Duration(minutes: durationInMinutes)))) {
      TourService.updateTourData(uid, {'state': 'live'});
      return TourState.live;
    } else if (startDateTime
        .isAfter(now.subtract(const Duration(minutes: 5)))) {
      TourService.updateTourData(uid, {'state': 'upcoming'});
      return TourState.upcoming;
    }
    TourService.updateTourData(uid, {'state': 'past'});
    return TourState.past;
  }
}
