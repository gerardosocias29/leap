import 'package:cloud_firestore/cloud_firestore.dart';

import '../_models/user_model.dart';

class UserServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  addUser(User userData) async {
    await _db.collection("users").add(userData.toMap());
  }
  updateUser(User userData) async {
    await _db.collection("users").doc(userData.id).update(userData.toMap());
  }
  Future<void> deleteUser(String documentId) async {
    await _db.collection("users").doc(documentId).delete();
  }
  Future<List<User>> retrieveUsers() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db.collection("users").get();
    return snapshot.docs.map((docSnapshot) => User.fromDocumentSnapshot(docSnapshot)).toList();
  }

  Future<Object?> retrieveIndividualUser(user_id) async {
    DocumentSnapshot snapshot = await _db.collection("users").doc(user_id).get();
    return snapshot.data();
  }
}
