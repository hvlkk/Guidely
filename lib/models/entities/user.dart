import 'package:guidely/models/data/registration_data.dart';
import 'package:guidely/models/entities/notification.dart';
import 'package:guidely/models/enums/tour_guide_auth_state.dart';

class User {
  final String uid;
  final String username;
  final String email;
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
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'imageUrl': imageUrl,
      'authState': authState.index,
      'bookedTours': bookedTours,
      'organizedTours': organizedTours,
      'notifications': notifications.map((notification) => notification.toMap()).toList(),
      'fcmToken': fcmToken,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      authState: TourGuideAuthState.values[map['tourGuideAuthState'] ?? 0],
      bookedTours: List<String>.from(map['bookedTours'] ?? []),
      organizedTours: List<String>.from(map['organizedTours'] ?? []),
      notifications: List<Notification>.from(map['notifications']?.map((item) => Notification.fromMap(item)) ?? []),
      registrationData: RegistrationData.fromMap(map['registrationData'] ?? {}),
      fcmToken: map['fcmToken'] ?? '',
    );
  }

  User copyWith({
    String? uid,
    String? username,
    String? email,
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
    );
  }

  @override
  String toString() {
    return 'User{uid: $uid, username: $username, email: $email, tourGuideAuthState: $authState, bookedTours: $bookedTours, organizedTours: $organizedTours, registrationData: $registrationData}';
  }
}
