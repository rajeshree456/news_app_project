import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> isUserAdmin(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    print("User document data for $uid: ${doc.data()}");
    return doc.data()?['isAdmin'] ?? false;
  } catch (e) {
    print("Error fetching admin status: $e");
    return false;
  }
}
