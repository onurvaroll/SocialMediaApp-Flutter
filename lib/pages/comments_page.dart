import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/service/authorization_service.dart';
import 'package:social_media/service/firestore_service.dart';
import '../models/post.dart';
import '../models/comment.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../theme/theme.dart';


class CommentsPage extends StatefulWidget {
  const CommentsPage({Key? key, required this.post}) : super(key: key);
  final Post post;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  TextEditingController commentController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        toolbarHeight: MediaQuery.of(context).size.height * 0.06,
        title: ThemeOfSocialMedia().normalAppBarText('Yorumlar', context),
        iconTheme: const IconThemeData(color: Colors.indigo),
      ),
      body: Column(
          children: [
            _showComments(),
            _addComments()
          ]
      ),
    );
  }

  _showComments() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FireStoreService().getComments(widget.post.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 0,
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Yorum Yok"),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Comment comment = Comment.toDocument(snapshot.data!.docs[index]);
              return _commentCard(comment);
            },
          );
        },
      ),
    );
  }


  Widget _commentCard(Comment comment) {
    return FutureBuilder<UserObject?>(
        future: FireStoreService().getUser(comment.sharedId),
        builder: (context, snapshot) {
          UserObject? sharedComment = snapshot.data;
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 0,
            );
          }
          return Expanded(
              child: Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: sharedComment!.fotoUrl.isNotEmpty
                        ? NetworkImage(sharedComment.fotoUrl)
                        : const NetworkImage(
                            'https://firebasestorage.googleapis.com/v0/b/firstproject-d42cf.appspot.com/o/bosprofilresmi%2Favatar.png?alt=media&token=47616d3b-99cf-4989-92e5-f316704aad9c'),
                  ),
                  title: RichText(
                      text: TextSpan(
                          text: "${sharedComment.kullaniciAdi}  ",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                          children: [
                        TextSpan(
                            text: comment.content,
                            style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.white))
                      ]
                      )
                  ),
                  subtitle:Text(timeago.format(comment.createTime.toDate(), locale: "tr")) ,
                ),
              )
          );
        });
  }

  _addComments() {
    return ListTile(
      title: TextFormField(
        controller: commentController,
        decoration: const InputDecoration(hintText: "Yorum Yaz"),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.send),
        onPressed: sendComment,
      ),
    );
  }

  void sendComment() {
    String? activeUserId =
        Provider.of<AuthorizationService>(context, listen: false).activeUserId;
    FireStoreService().addComment(
        activeUserId: activeUserId,
        post: widget.post,
        content: commentController.text);
    commentController.clear();
  }
}
