import 'package:guidely/models/data/registration_data.dart';

class User {
  final String uid;
  final String username;
  final String email;
  final String imageUrl;
  late bool isTourGuide = false;
  late RegistrationData registrationData =
      RegistrationData(description: '', uid: '', uploadedIdURL: '');
  List<String> bookedTours;

  User({
    required this.uid,
    required this.username,
    required this.email,
    required this.imageUrl,
    this.isTourGuide = false,
    required this.bookedTours,
    registrationData,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'imageUrl': imageUrl,
      'isTourGuide': isTourGuide,
      'bookedTours': bookedTours,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isTourGuide: map['isTourGuide'] ?? false,
      bookedTours: List<String>.from(map['bookedTours'] ?? []),
      registrationData: RegistrationData.fromMap(map['registrationData'] ?? {}),
    );
  }

  User copyWith({
    String? uid,
    String? username,
    String? email,
    String? imageUrl,
    bool? isTourGuide,
    required List<String> bookedTours,
    RegistrationData? registrationData,
  }) {
    return User(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      isTourGuide: isTourGuide ?? this.isTourGuide,
      bookedTours: bookedTours,
      registrationData: registrationData,
    );
  }

  get isGuide => isTourGuide;

  @override
  String toString() {
    return 'User{uid: $uid, username: $username, email: $email, isTourGuide: $isTourGuide, bookedTours: $bookedTours, registrationData: $registrationData}';
  }
}
