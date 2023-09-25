import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/models/user.dart';

class Auth extends ChangeNotifier {
  final _firebaseAuth = FirebaseAuth.instance;
  late String activeUserId;

  UserObject? _createUser(User? user) {
    return user == null ? null : UserObject.tofirebase(user);
  }

  User? get currentUser => FirebaseAuth.instance.currentUser;

  String get userUid => currentUser?.uid ?? '';

  Future<UserObject?> createUserWithEmailAndPassword(
      String email, String password) async {
    final userCredentials = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return _createUser(userCredentials.user);
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    final userCredentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    activeUserId = userCredentials.user!.uid;
    return userCredentials.user;
  }


  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  Stream<User?> authStatus() {
    return _firebaseAuth.authStateChanges();
  }

  Future<void>? updateName(String displayName) {
    return currentUser?.updateDisplayName(displayName);
  }
}
