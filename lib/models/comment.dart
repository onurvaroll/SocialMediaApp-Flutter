import 'package:cloud_firestore/cloud_firestore.dart';

class Comment{
  final String id;
  final String content;
  final String sharedId;
  final Timestamp createTime;

  Comment({required this.id, required this.content, required this.sharedId, required this.createTime});

  factory Comment.toDocument(DocumentSnapshot doc) {
    var docData = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      content: docData['icerik'] as String? ??'Veri Tipi Uyuşmazlığı',
      sharedId: docData['yayinlayanId'] as String? ?? '',
      createTime: docData['olusturulmaZamani'] as Timestamp? ?? Timestamp.now(),
    );
  }

}