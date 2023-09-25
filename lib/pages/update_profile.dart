import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/service/authorization_service.dart';
import 'package:social_media/service/firestore_service.dart';
import 'package:social_media/service/storage_service.dart';

import '../theme/theme.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key, required this.user});
  final UserObject user;

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  var formKey=GlobalKey<FormState>();
  late String userName;
  late String content;
  File? checkedPhoto;
  bool loading=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        toolbarHeight: MediaQuery.of(context).size.height * 0.06,
        title: ThemeOfSocialMedia().normalAppBarText('Düzenle', context),
        leading: IconButton(
          icon: const Icon(Icons.close),onPressed: (){
            Navigator.pop(context);
        },
        ),
        actions: [
          IconButton(onPressed: _saveData,
              icon:const Icon(Icons.check))
        ],
      ),
      body: ListView(
        children: [
          loading==true?const LinearProgressIndicator():const SizedBox(),
          _profilePhoto(),
          const SizedBox(height: 20),
          _userData()
        ],
      ),
    );
  }

  _profilePhoto() {
    return Padding(
        padding: const EdgeInsets.only(top: 15,bottom: 20),
            child: Center(
              child: InkWell(
                onTap: _openGallery,
                // ignore: unnecessary_null_comparison
                child: checkedPhoto == null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(widget.user.fotoUrl),
                  radius: 50,
                ) :CircleAvatar(
                  backgroundImage: FileImage(checkedPhoto!),
                  radius: 50,
                ),
              ),
            ),
    );
  }

  _userData() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          const Text("Profil resminizin üzerine basarak yeni bir seçim yapabilirsiniz.",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 30),
          TextFormField(
          initialValue: widget.user.kullaniciAdi,
        decoration: InputDecoration(
          labelText: "Kullanıcı Adını Değiştir",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20)),
          hintText: "Kullanıcı Adını Değiştir",
        ),
          validator: (enteredText){
          return enteredText!.trim().length<3?"Kullanıcı adı en az 4 harf olmalı!":null;
          },
          onSaved: (enteredText){
          userName=enteredText!;
          },
      ),
          const SizedBox(height: 30),
          TextFormField(
            initialValue: widget.user.hakkinda,
            decoration: InputDecoration(
              labelText: "Hakkında İçeriğini Değiştir",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20)),
              hintText: "Hakkında İçeriğini Değiştir",
            ),
            validator: (enteredText){
              return enteredText!.trim().length>120?"En fazla 120 karakter olmalı":null;
            },
            onSaved: (enteredText){
              content=enteredText!;
            },
          ),

        ],
      ),
    );
  }


  _saveData() async{
    if(formKey.currentState!.validate()){
      setState(() {
        loading=true;
      });
      formKey.currentState!.save();
      String newProfilePhotoUrl;
      if(checkedPhoto==null){
        newProfilePhotoUrl=widget.user.fotoUrl;
      }else{
        newProfilePhotoUrl=await StorageService().uploadProfilePhoto(checkedPhoto!);
      }
      // ignore: use_build_context_synchronously
      String? activeUserId=Provider.of<AuthorizationService>(context,listen: false).activeUserId;
      FireStoreService().updateUser(userId: activeUserId, userName: userName, photoUrl: newProfilePhotoUrl, content: content);
      setState(() {
        loading=true;
      });
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  _openGallery () async {
  final image = await ImagePicker().pickImage(
  source: ImageSource.gallery,
  maxWidth: 800,
  maxHeight: 600,
  imageQuality: 80,
  );
  if (image != null) {
  setState(() {
  checkedPhoto = File(image.path);
  });
  }
}
}
