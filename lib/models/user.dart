import 'package:guidely/models/registration_data.dart';

class User {
  final String uid;
  final String username;
  final String email;
  final String imageUrl;
  late bool isTourGuide = false;
  late RegistrationData registrationData;

  User({
    required this.uid,
    required this.username,
    required this.email,
    required this.imageUrl,
    this.isTourGuide = false,
    registrationData,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'imageUrl': imageUrl,
      'isTourGuide': isTourGuide,
    };
  }

  @override
  String toString() {
    return 'User{uid: $uid, username: $username, email: $email, isTourGuide: $isTourGuide}';
  }

  User copyWith({
    String? uid,
    String? username,
    String? email,
    String? imageUrl,
    bool? isTourGuide,
    required RegistrationData registrationData,
  }) {
    return User(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      isTourGuide: isTourGuide ?? this.isTourGuide,
      registrationData: registrationData,
    );
  }
}
