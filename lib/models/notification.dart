import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationObject {
  final String id;
  final String notifyUserId;
  final String notifyType;
  final String postId;
  final String postPhoto;
  final String comment;
  final Timestamp createTime;

  NotificationObject({required this.id, required this.notifyUserId, required this.notifyType, required this.postId, required this.postPhoto, required this.comment, required this.createTime});

  factory NotificationObject.toDocument(DocumentSnapshot doc) {
    var docData = doc.data() as Map<String, dynamic>;

    String? notifyUserId = docData['aktiviteYapanId'] as String?;
    String? notifyType = docData['aktiviteTipi'] as String?;
    String? postId = docData['gonderiId'] as String?;
    String? postPhoto = docData['gonderiFoto'] as String?;
    String? comment = docData['yorum'] as String?;
    Timestamp? createTime = docData['olusturulmaZamani'] as Timestamp?;

    return NotificationObject(
      id: doc.id,
      notifyUserId: notifyUserId ?? "",
      notifyType: notifyType ?? "",
      postId: postId ?? "",
      postPhoto: postPhoto ?? "",
      comment: comment ?? "",
      createTime: createTime ?? Timestamp.now(),
    );
  }


}