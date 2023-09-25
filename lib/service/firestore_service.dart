
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/models/post.dart';
import 'package:social_media/service/storage_service.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../models/notification.dart';



class FireStoreService {
  final DateTime createTime = DateTime.now();
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  Future<void> saveUser ({id, email, userName, photoUrl=""}) async {
    await _firestore.collection("kullanicilar").doc(id).set({
      "kullaniciAdi": userName,
      "email": email,
      "fotoUrl": photoUrl,
      "hakkinda": "",
      "olusturulmaZamani": createTime
    });
  }
  Future<UserObject?>getUser(userId) async{
    DocumentSnapshot docUser= await _firestore.collection("kullanicilar").doc(userId).get();
    if(docUser.exists){
      UserObject user =UserObject.todocument(docUser);
      return user;
    }
return null;
  }

  void updateUser({required String? userId,required String userName, required String photoUrl,required String content}){
   _firestore.collection("kullanicilar").doc(userId).update({
     "kullaniciAdi": userName,
     "fotoUrl": photoUrl,
     "hakkinda": content,
   });
  }
 Future<List<UserObject>> searchUser(String text)async{
   QuerySnapshot snapshot= await _firestore.collection("kullanicilar").where("kullaniciAdi",isGreaterThanOrEqualTo: text).get();
   List<UserObject> users=snapshot.docs.map((doc) => UserObject.todocument(doc)).toList();
   return users;
  }
  void followed({required String? activeUserId, required String? profileUserId}){
    _firestore.collection("takipciler").doc(profileUserId).collection("kullanicinintakipcileri").doc(activeUserId).set({});
    _firestore.collection("takipedilenler").doc(activeUserId).collection("kullanicinintakipleri").doc(profileUserId).set({});

    addNotification(aktiviteYapanId: activeUserId, profilSahibiId: profileUserId, bildirimTipi: "takip");
  }


  void notFollowed({required String? activeUserId, required String? profileUserId}){
    _firestore.collection("takipciler").doc(profileUserId).collection("kullanicinintakipcileri").doc(activeUserId).get().then((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }});
    _firestore.collection("takipedilenler").doc(activeUserId).collection("kullanicinintakipleri").doc(profileUserId).get().then((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }});

  }

   Future<bool> followControl({required String? activeUserId, required String? profileUserId})async{
   DocumentSnapshot doc= await _firestore.collection("takipedilenler").doc(activeUserId).collection("kullanicinintakipleri").doc(profileUserId).get();
   if(doc.exists){
     return true;
   }
   return false;
  }

  Future<int> followerSize(userId)async{
   QuerySnapshot snapshot= await _firestore.collection("takipciler").doc(userId).collection("kullanicinintakipcileri").get();
   return snapshot.docs.length;
  }
  Future<int> followingSize(userId)async{
    QuerySnapshot snapshot= await _firestore.collection("takipedilenler").doc(userId).collection("kullanicinintakipleri").get();
    return snapshot.docs.length;
  }
  Future<void> createPost({fotoUrl,content,shareId,location})async{
   await _firestore.collection("gonderiler").doc(shareId).collection("kullaniciningonderileri").add({
      "fotoUrl":fotoUrl,
      "aciklama":content,
      "yayinlayanId":shareId,
      "begeniSayisi":0,
      "konum":location,
      "olusturulmaZamanı":createTime
    });

  }
  
  Future<List<Post>>getPosts(userId)async{
    QuerySnapshot snapshot= await _firestore.collection("gonderiler").doc(userId).collection("kullaniciningonderileri").orderBy("olusturulmaZamanı",descending: true).get();
    List<Post> posts= snapshot.docs.map((doc) => Post.toDocument(doc)).toList();
    return posts;
  }


  Future<Post>getSinglePost(String postId, String sharedPostId) async {
    DocumentSnapshot doc= await _firestore.collection("gonderiler").doc(sharedPostId).collection("kullaniciningonderileri").doc(postId).get();
    Post post=Post.toDocument(doc);
    return post;

  }


  Future<List<Post>>getFlowPost(userId)async{
    QuerySnapshot snapshot = await _firestore
        .collection("akislar")
        .doc(userId)
        .collection("kullaniciAkisGonderileri")
        .orderBy("olusturulmaZamanı", descending: true)
        .get();
    List<Post> posts= snapshot.docs.map((doc) => Post.toDocument(doc)).toList();
    return posts;

  }

  Future<void> deletePost({required String activeUserId,required Post post})async{
    _firestore.collection("gonderiler").doc(activeUserId).collection("kullaniciningonderileri").doc(post.id).get().then((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });

    QuerySnapshot commentSnapshot= await _firestore.collection("yorumlar").doc(post.id).collection("gonderiYorumlari").get();
    for (var doc in commentSnapshot.docs) {
      if(doc.exists){
        doc.reference.delete();
      }
    }

    QuerySnapshot notifySnapshot = await _firestore.collection("bildirimler").doc(post.shareId).collection("kullanicininbildirimleri").where("gonderiId", isEqualTo: post.id).get();
    notifySnapshot.docs.forEach((DocumentSnapshot doc) {
      if(doc.exists){
        doc.reference.delete();
      }
    });

    StorageService().deletePostImage(post.fotoUrl);

  }

  Future <void> postLike(Post post,String activeUserId)async{
    DocumentReference docRef= _firestore.collection("gonderiler").doc(post.shareId).collection("kullaniciningonderileri").doc(post.id);
    DocumentSnapshot doc= await docRef.get();
   if(doc.exists){
     Post post=Post.toDocument(doc);
     int newLikeSize= post.likeSize+1;
     docRef.update({"begeniSayisi": newLikeSize});
     _firestore.collection("begeniler").doc(post.id).collection("gonderiBegenileri").doc(activeUserId).set({});
     addNotification(aktiviteYapanId: activeUserId, profilSahibiId: post.shareId, bildirimTipi: "begeni",  post: post,comment: "");
   }
  }
  Future <void> postUnlike(Post post,String activeUserId)async{
    DocumentReference docRef= _firestore.collection("gonderiler").doc(post.shareId).collection("kullaniciningonderileri").doc(post.id);
    DocumentSnapshot doc= await docRef.get();
    if(doc.exists){
      Post post=Post.toDocument(doc);
      int newLikeSize= post.likeSize-1;
       docRef.update({"begeniSayisi": newLikeSize});
      DocumentSnapshot docLike= await _firestore.collection("begeniler").doc(post.id).collection("gonderiBegenileri").doc(activeUserId).get();
      if(docLike.exists){
        docLike.reference.delete();
      }
    }
  }

  postLikeStatus(Post post,String activeUserId)async{
    DocumentSnapshot docLike= await _firestore.collection("begeniler").doc(post.id).collection("gonderiBegenileri").doc(activeUserId).get();
    if(docLike.exists){
      return true;
    }else{
      return false;
    }
  }

  Stream<QuerySnapshot>getComments(String? postId){
   return _firestore.collection("yorumlar").doc(postId).collection("gonderiYorumlari").orderBy("olusturulmaZamani",descending: true).snapshots();
  }
  Future<List<Comment>>getComment(String postId)async{
    QuerySnapshot snapshot= await _firestore.collection("yorumlar").doc(postId).collection("gonderiYorumlari").orderBy("olusturulmaZamani",descending: true).get();
    List<Comment> comments= snapshot.docs.map((doc) => Comment.toDocument(doc)).toList();
    return comments;
  }

  void addComment( {String? activeUserId,required Post post,required String content}){
    _firestore.collection("yorumlar").doc(post.id).collection("gonderiYorumlari").add({
      "icerik":content,
      "yayinlayanId":activeUserId,
      "olusturulmaZamani":createTime
    });
    addNotification(
        comment:content,
        aktiviteYapanId: activeUserId,
        profilSahibiId: post.shareId,
        bildirimTipi: "yorum",
        post: post);
  }

  void addNotification({String? aktiviteYapanId, String? profilSahibiId, String? bildirimTipi, String? comment, Post? post}){

    if(aktiviteYapanId == profilSahibiId){
      return;
    }

    _firestore.collection("bildirimler").doc(profilSahibiId).collection("kullanicininbildirimleri").add({
      "aktiviteYapanId": aktiviteYapanId??"",
      "aktiviteTipi": bildirimTipi??"",
      "gonderiId": post?.id??"",
      "gonderiFoto": post?.fotoUrl??"",
      "yorum": comment??"",
      "olusturulmaZamani": createTime
    });
  }

  Future<List<NotificationObject>> getNotifications(String profilSahibiId) async {
    QuerySnapshot snapshot = await _firestore.collection("bildirimler").doc(profilSahibiId).collection("kullanicininbildirimleri").orderBy("olusturulmaZamani", descending: true).limit(20).get();

    List<NotificationObject> notificationsList = [];

    snapshot.docs.forEach((DocumentSnapshot doc) {
      NotificationObject notification = NotificationObject.toDocument(doc);
      notificationsList.add(notification);
    });

    return notificationsList;

  }





}