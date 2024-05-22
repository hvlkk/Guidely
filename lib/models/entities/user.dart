import 'package:guidely/models/data/registration_data.dart';
import 'package:guidely/models/utils/language.dart';
import 'package:guidely/models/utils/tour_category.dart';

class User {
  final String uid;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  List<Language> languages;
  List<TourCategory> categories = [];
  final DateTime? dateJoined;
  final String imageUrl;
  final String fcmToken;
  late bool isTourGuide = false;
  late RegistrationData registrationData =
      RegistrationData(description: '', uid: '', uploadedIdURL: '');
  List<String> bookedTours;
  List<String> organizedTours; // for organized tours of the host

  User({
    required this.uid,
    required this.username,
    required this.email,
    required this.imageUrl,
    required this.fcmToken,
    this.isTourGuide = false,
    required this.bookedTours,
    required this.organizedTours,
    registrationData,
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.dateOfBirth,
    this.dateJoined,
    this.languages = const [],
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
      'dateJoined': dateJoined?.toString(),
      'imageUrl': imageUrl,
      'isTourGuide': isTourGuide,
      'bookedTours': bookedTours,
      'organizedTours': organizedTours,
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
      phoneNumber: map['phoneNumber'] ?? '',
      languages: List<Language>.from(map['languages'] ?? []),
      dateJoined:
          map['dateJoined'] != null ? DateTime.parse(map['dateJoined']) : null,
      imageUrl: map['imageUrl'] ?? '',
      isTourGuide: map['isTourGuide'] ?? false,
      bookedTours: List<String>.from(map['bookedTours'] ?? []),
      organizedTours: List<String>.from(map['organizedTours'] ?? []),
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
    String? imageUrl,
    bool? isTourGuide,
    required List<String> bookedTours,
    required List<String> organizedTours,
    RegistrationData? registrationData,
  }) {
    return User(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      isTourGuide: isTourGuide ?? this.isTourGuide,
      bookedTours: bookedTours,
      organizedTours: organizedTours,
      registrationData: registrationData,
      fcmToken: fcmToken,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dateJoined: dateJoined ?? this.dateJoined,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      languages: languages ?? this.languages,
    );
  }

  get isGuide => isTourGuide;

  @override
  String toString() {
    return 'User{uid: $uid, username: $username, email: $email, isTourGuide: $isTourGuide, bookedTours: $bookedTours, organizedTours: $organizedTours, registrationData: $registrationData}';
  }
}
