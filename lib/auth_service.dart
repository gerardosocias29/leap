import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _dbauth = FirebaseAuth.instance;

  Future<dynamic> signInWithEmailAndPassword(_emailTextController, _passwordTextController) async {
    return _dbauth
        .signInWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text
    );
  }

  Future<dynamic> createUserWithEmailAndPassword(_emailTextController, _passwordTextController) async {
    return _dbauth
        .createUserWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text
    );
  }

  Future<dynamic> getCurrentUser() async {
    return _dbauth.currentUser;
  }

  Future<dynamic> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: <String>['email']).signIn();

    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _dbauth.signInWithCredential(credential);
  }

  Future<dynamic> sendPasswordResetEmail({required String email}) async {
    return _dbauth.sendPasswordResetEmail(email: email);
  }

  Future<dynamic> signOut() async {
    _dbauth.signOut();
  }

  Future<dynamic> getUserData(user_id) async {
    final DocumentReference document = FirebaseFirestore.instance.collection("users").doc(user_id);
    await document.get().then<dynamic>(( DocumentSnapshot snapshot) async{
      return snapshot.data;
    });
  }

  getUserId() async{
    return _dbauth.currentUser?.uid;
  }
}