import 'package:cloud_firestore/cloud_firestore.dart';
class UserProfile {
  final String uid;
  final String username;
  final String email;

  UserProfile({
    required this.uid,
    required this.username,
    required this.email,
  });
  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    return UserProfile(uid: doc['uid'], username: doc['username'], email: doc['email']);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
    };
  }
}
