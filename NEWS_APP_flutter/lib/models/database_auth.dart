
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_3/models/user.dart';

class DatabaseAuth {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> saveUserInfoInFirebase({
    required String username,
    required String email,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile user = UserProfile(
        uid: uid,
        username: username,
        email: email,
      );

      final userMap = user.toMap();
      await _db.collection("Users").doc(uid).set(userMap);
    } catch (e) {
      throw Exception("Failed to save user information: $e");
    }
  }

  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();

      if (userDoc.exists) {
        return UserProfile.fromDocument(userDoc);
      } else {
        throw Exception("User with UID $uid does not exist.");
      }
    } catch (e) {
      throw Exception("Failed to fetch user information: $e");
    }
  }
}
