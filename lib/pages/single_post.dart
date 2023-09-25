import 'package:flutter/material.dart';
import 'package:social_media/components/post_card.dart';
import 'package:social_media/models/post.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/service/firestore_service.dart';

import '../theme/theme.dart';

class SinglePost extends StatefulWidget {
  final String postId;
  final String sharedPostId;

  const SinglePost({super.key, required this.postId, required this.sharedPostId});

  @override
  // ignore: library_private_types_in_public_api
  _SinglePostState createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  late Post _post;
  late UserObject _sharedPost;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getPost();
  }

  getPost() async {
    Post post = await FireStoreService().getSinglePost(widget.postId, widget.sharedPostId);
    UserObject? sharedPost = await FireStoreService().getUser(post.shareId);

    setState(() {
      _post = post;
      _sharedPost = sharedPost!;
      _loading = false;
    });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          toolbarHeight: MediaQuery.of(context).size.height * 0.06,
          title: ThemeOfSocialMedia().normalAppBarText('Post', context)
        ),
        body: !_loading ?
        PostCard(post: _post, shared: _sharedPost,)
            : const Center(child: CircularProgressIndicator())
    );
  }
}