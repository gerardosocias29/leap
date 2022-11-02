import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth;
  Auth(this._firebaseAuth);

  final databaseReference = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //Get Current User UID
  Future<String> userUid() async {
    return _firebaseAuth.currentUser!.uid;
  }

  //Get Current User
  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<String?> login(
    String email,
    String password,
  ) async {
      try {
        await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password
        );
        return 'Signed in';
      } on FirebaseAuthException catch (error) {
        print(error.message);
        return error.message;
      }
  }

  Future<String?> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    bool isAdmin,
  ) async {
    try {
      // Create a new user
      final currentUser = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Update user
      await databaseReference
          .collection("users")
          .doc(currentUser.user?.uid)
          .set({
        'firstName': firstName,
        'lastName': lastName,
        'email': currentUser.user?.email,
        'isAdmin': isAdmin,
      });
    } on FirebaseAuthException catch (error) {
      return error.message;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}