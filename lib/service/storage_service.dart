import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService{
  final Reference _storage= FirebaseStorage.instance.ref();
  late String imageId;

  Future<String> uploadPostImage(File image)async{
    imageId= const Uuid().v4();
    UploadTask uploadManager=  _storage.child("resimler/gonderi/gonderi_$imageId.jpg").putFile(image);
    String loadingImageUrl = await (await uploadManager).ref.getDownloadURL();
    return loadingImageUrl;
  }

  Future<String> uploadProfilePhoto(File image)async{
    imageId= const Uuid().v4();
    UploadTask uploadManager=  _storage.child("resimler/profil/profilfoto_$imageId.jpg").putFile(image);
    String loadingImageUrl = await (await uploadManager).ref.getDownloadURL();
    return loadingImageUrl;
  }
  void deletePostImage(String postImageUrl){
    RegExp search=RegExp(r"gonderi_.+\.jpg");
    var match=search.firstMatch(postImageUrl);
    String? fileName=match![0];
    if(fileName !=null){
      _storage.child("resimler/gonderi/$fileName").delete();
    }
  }

}
