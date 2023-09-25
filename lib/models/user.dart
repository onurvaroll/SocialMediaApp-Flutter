import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserObject {
  final String id;
  final String kullaniciAdi;
  final String fotoUrl;
  final String email;
  final String hakkinda;

  UserObject({
    required this.id,
    required this.kullaniciAdi,
    required this.fotoUrl,
    required this.email,
    required this.hakkinda,
  });

  factory UserObject.tofirebase(User kullanici) {
    return UserObject(
      id: kullanici.uid,
      kullaniciAdi: kullanici.displayName ?? '',
      fotoUrl: kullanici.photoURL ?? '',
      email: kullanici.email ?? '',
      hakkinda: '',
    );
  }

  factory UserObject.todocument(DocumentSnapshot? doc) {
    if (doc == null || doc.data() == null) {
      return UserObject(
        id: '',
        kullaniciAdi: '',
        fotoUrl: '',
        email: '',
        hakkinda: '',
      );
    }

    var docData = doc.data() as Map<String, dynamic>;
    return UserObject(
      id: doc.id,
      kullaniciAdi: docData['kullaniciAdi'] ?? '',
      email: docData['email'] ?? '',
      fotoUrl: docData['fotoUrl'] ?? '',
      hakkinda: docData['hakkinda'] ?? '',
    );
  }
}
