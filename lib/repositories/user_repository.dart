import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guidely/models/entities/notification.dart';
import 'package:guidely/models/entities/user.dart' as myuser;
import 'package:guidely/models/enums/tour_guide_auth_state.dart';

// reponsible for crud operations on user data
class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<myuser.User> getUserData() async {
    final user = _auth.currentUser;
    final userData = await _firestore.collection('users').doc(user?.uid).get();
    final data = userData.data() as Map<String, dynamic>;

    final newUser = myuser.User(
      username: data['username'],
      imageUrl: data['imageUrl'],
      email: data['email'],
      uid: data['uid'],
      authState: TourGuideAuthState.values[data['authState'] ?? 0],
      registrationData: data['registrationData'] ?? {},
      bookedTours: List<String>.from(data['bookedTours'] ?? []),
      organizedTours: List<String>.from(data['organizedTours'] ?? []),
      notifications: List<Notification>.from(
        data['notifications']?.map((item) => Notification.fromMap(item)) ?? [],
      ),
      fcmToken: data['fcmToken'] ?? '',
    );
    return newUser;
  }

  Future<Map<String, dynamic>> updateUserData(
      String uid, Map<String, dynamic> data) async {
    print("Data is $data");
    try {
      await _firestore.collection('users').doc(uid).set(
            data,
            SetOptions(merge: true),
          );
      return {'success': true};
    } catch (e) {
      print("Yeah, I'm here");
      print(e);
      return {'success': false, 'error': e};
    }
  }

  // Retrieve user's via user id (uid)
  Future<myuser.User> getUserById(String uid) async {
    final userData = await _firestore.collection('users').doc(uid).get();
    final data = userData.data() as Map<String, dynamic>;

    final newUser = myuser.User(
      username: data['username'],
      imageUrl: data['imageUrl'],
      email: data['email'],
      uid: data['uid'],
      authState: TourGuideAuthState.values[data['authState'] ?? 0],
      registrationData: data['registrationData'] ?? {},
      bookedTours: List<String>.from(data['bookedTours'] ?? []),
      organizedTours: List<String>.from(data['organizedTours'] ?? []),
      notifications: List<Notification>.from(
        data['notifications']?.map((item) => Notification.fromMap(item)) ?? [],
      ),
      fcmToken: data['fcmToken'] ?? '',
    );
    return newUser;
  }
}
