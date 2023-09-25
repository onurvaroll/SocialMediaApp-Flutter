import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String fotoUrl;
  final String content;
  final String shareId;
  final int likeSize;
  final String location;
  final Timestamp createTime;

  Post({
    required this.id,
    required this.fotoUrl,
    required this.content,
    required this.shareId,
    required this.likeSize,
    required this.location,
    required this.createTime
  });

  factory Post.toDocument(DocumentSnapshot doc) {
    var docData = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      fotoUrl: docData['fotoUrl'] as String,
      content: docData['aciklama'] as String,
      shareId: docData['yayinlayanId'] as String,
      likeSize: docData['begeniSayisi'] as int,
      location: docData['konum'] as String,
      createTime: docData['olusturulmaZamanı']
    );
  }
}
