import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:social_media/models/user.dart';

class AuthorizationService with ChangeNotifier{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
   String? activeUserId;

  UserObject? _createUser(User? user) {
    return user == null ? null : UserObject.tofirebase(user);
  }
  Future<UserObject?> createUser(
      String email, String password) async {
    var userCredentials = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return _createUser(userCredentials.user);
  }

  Stream<UserObject?> get authStatus {
    return _firebaseAuth.authStateChanges().map(_createUser);
  }


  Future<UserObject?> signIn (String email, String password) async {
    var userCredentials = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return _createUser(userCredentials.user);
  }

  Future<void> signOut(){
    return _firebaseAuth.signOut();
  }

  Future<void> passwordReset(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}