import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_media/pages/home_page.dart';
import 'package:social_media/pages/main_page.dart';
import 'package:social_media/service/authorization_service.dart';
import 'package:social_media/service/firestore_service.dart';
import 'package:social_media/service/storage_service.dart';

import '../components/image_alert_dialog.dart';
import '../theme/theme.dart';


class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final TextEditingController textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  File? file;
  bool loading=false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }



  void _showCustomDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          openGallery: () async {
            Navigator.pop(context);
            final image = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              maxWidth: 800,
              maxHeight: 600,
              imageQuality: 80,
            );
            if (image != null) {
              setState(() {
                file = File(image.path);
              });
            }
          },
          openCamera: () async {
            Navigator.pop(context);
            final image = await ImagePicker().pickImage(
              source: ImageSource.camera,
              maxWidth: 800,
              maxHeight: 600,
              imageQuality: 80,
            );
            if (image != null) {
              setState(() {
                file = File(image.path);
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: MediaQuery.of(context).size.height*0.06,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: (){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainPage(),
                    ),
                  );
                },
                icon: const Icon(
                    Icons.close)
            ),Align(
              alignment: Alignment.center,
              child: ThemeOfSocialMedia().normalAppBarText('Yeni Post', context),),
            TextButton(
                onPressed: _createPost,
                child: const Text('Paylaş')
            )
          ],
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 20),
              child: TextField(
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Bir şeyler yazın...',
                ),
                controller: textController,
              ),
            ),
            Column(
              children: [
                IconButton(
                  alignment: Alignment.center,
                  focusNode: _focusNode,
                  icon: const Icon(Icons.camera_alt_outlined),
                  onPressed: () {
                    _showCustomDialog(context);
                  },
                ),
                const Text('Fotoğraf Ekleyin'),
                file == null
                    ? const SizedBox()
                    : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AspectRatio(
                  aspectRatio: 16.0 / 9.0,
                  child: Image.file(file!, fit: BoxFit.cover),
                ),
                    ),
              ],
            ),]
        ),
      ),
    );
  }

  void _createPost() async {
    if (!loading) {
      setState(() {
        loading = true;
      });

      String? fotoUrl;
      if (file != null) {
        fotoUrl = await StorageService().uploadPostImage(file!);
      } else {
        fotoUrl = "";
      }

      if (textController.text.isEmpty && fotoUrl.isEmpty) {
        // Text ve fotoğraf boş ise uyarı göster
        _showAlertDialog("Uyarı", "Boş post atamazsınız.");
      } else {
        // ignore: use_build_context_synchronously
        String? activeUserId = Provider.of<AuthorizationService>(context, listen: false).activeUserId;

        await FireStoreService().createPost(
          fotoUrl: fotoUrl,
          content: textController.text,
          shareId: activeUserId,
          location: "İstanbul",
        );

        setState(() {
          loading = false;
          textController.clear();
        });

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
        );
      }
    }
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              child: const Text("Tamam"),
            ),
          ],
        );
      },
    );
  }
}
