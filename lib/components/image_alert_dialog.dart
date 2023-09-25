import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final VoidCallback openCamera;
  final VoidCallback openGallery;

  const CustomAlertDialog({super.key, required this.openCamera, required this.openGallery});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: const Text('Fotoğraf Seç',textAlign: TextAlign.center),
      content: SizedBox(
        height: MediaQuery.of(context).size.height*0.2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: openCamera,
                  icon: Icon(Icons.camera),
                  iconSize: 48.0,
                ),
                Text('Kamera')
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: openGallery,
                  icon: Icon(Icons.photo),
                  iconSize: 48.0,
                ),
                Text('Galeri')
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Vazgeç'),
        ),
      ],
    );
  }
}
