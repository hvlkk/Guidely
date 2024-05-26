import 'package:guidely/models/data/registration_data.dart';
import 'package:guidely/models/utils/language.dart';
import 'package:guidely/models/utils/tour_category.dart';
import 'package:guidely/models/entities/notification.dart';
import 'package:guidely/models/enums/tour_guide_auth_state.dart';

// TODO: Decompose the personal information of the user into a separate entity

class User {
  final String uid;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  List<Language> languages;
  List<TourCategory> preferredTourCategories;
  final DateTime? dateJoined;
  final String imageUrl;
  final String fcmToken;
  TourGuideAuthState authState;
  late RegistrationData registrationData =
      RegistrationData(description: '', uid: '', uploadedIdURL: '');
  List<String> bookedTours;
  List<String> organizedTours; // for organized tours of the host
  List<Notification> notifications;

  User({
    required this.uid,
    required this.username,
    required this.email,
    required this.imageUrl,
    required this.fcmToken,
    this.authState = TourGuideAuthState.unauthenticated,
    required this.bookedTours,
    required this.organizedTours,
    required this.notifications,
    registrationData,
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber,
    this.dateOfBirth,
    this.dateJoined,
    this.languages = const [],
    this.preferredTourCategories = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toString(),
      'phoneNumber': phoneNumber,
      'languages': languages.map((language) => language.toMap()).toList(),
      'preferredTourCategories': preferredTourCategories.map(
        (tourCategory) => tourCategoryToString[tourCategory],
      ),
      'dateJoined': dateJoined?.toString(),
      'imageUrl': imageUrl,
      'authState': authState.index,
      'bookedTours': bookedTours,
      'organizedTours': organizedTours,
      'notifications':
          notifications.map((notification) => notification.toMap()).toList(),
      'fcmToken': fcmToken,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'])
          : null,
      phoneNumber: map['phoneNumber'],
      languages: List<Language>.from(
        (map['languages'] ?? []).map(
          (language) => Language.fromMap(language),
        ),
      ),
      preferredTourCategories: List<TourCategory>.from(
        (map['preferredTourCategories'] ?? []).map(
          (category) => tourCategoryFromString[category],
        ),
      ),
      dateJoined:
          map['dateJoined'] != null ? DateTime.parse(map['dateJoined']) : null,
      imageUrl: map['imageUrl'] ?? '',
      authState: TourGuideAuthState.values[map['tourGuideAuthState'] ?? 0],
      bookedTours: List<String>.from(map['bookedTours'] ?? []),
      organizedTours: List<String>.from(map['organizedTours'] ?? []),
      notifications: List<Notification>.from(
          map['notifications']?.map((item) => Notification.fromMap(item)) ??
              []),
      registrationData: RegistrationData.fromMap(map['registrationData'] ?? {}),
      fcmToken: map['fcmToken'] ?? '',
    );
  }

  User copyWith({
    String? uid,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    DateTime? dateJoined,
    String? phoneNumber,
    List<Language>? languages,
    List<TourCategory>? preferredTourCategories,
    String? imageUrl,
    required TourGuideAuthState authState,
    required List<String> bookedTours,
    required List<String> organizedTours,
    required List<Notification> notifications,
    RegistrationData? registrationData,
  }) {
    return User(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      authState: authState,
      bookedTours: bookedTours,
      organizedTours: organizedTours,
      notifications: notifications,
      registrationData: registrationData,
      fcmToken: fcmToken,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dateJoined: dateJoined ?? this.dateJoined,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      languages: languages ?? this.languages,
      preferredTourCategories:
          preferredTourCategories ?? this.preferredTourCategories,
    );
  }

  @override
  String toString() {
    return 'User{uid: $uid, username: $username, email: $email, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, phoneNumber: $phoneNumber, languages: $languages, preferredTourCategories: $preferredTourCategories, imageUrl: $imageUrl, tourGuideAuthState: $authState, bookedTours: $bookedTours, organizedTours: $organizedTours, registrationData: $registrationData}';
  }
}
