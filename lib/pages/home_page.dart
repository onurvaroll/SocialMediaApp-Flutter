import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/service/firestore_service.dart';

import '../components/post_card.dart';
import '../models/post.dart';
import '../service/authorization_service.dart';
import '../theme/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> _posts=[];
  getFlowPost() async {
    String activeUserId =
    Provider.of<AuthorizationService>(context, listen: false).activeUserId!;
    List<Post> posts = await FireStoreService().getFlowPost(activeUserId);
    if(mounted){
    setState(() {
      _posts = posts;
    });}
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFlowPost();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title:  ThemeOfSocialMedia().titleAppBarText(context),
        elevation: 0,
        toolbarHeight: MediaQuery.of(context).size.height * 0.06,
        centerTitle: true,
      ),
      body:  ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: _posts.length,
          itemBuilder: (context, index) {
           Post post=_posts[index];
            return FutureBuilder(
                future: FireStoreService().getUser(post.shareId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData) {

                    return const Center(child: Text("Veri bulunamadı"));
                  }
                  UserObject? postUser = snapshot.data;
                  return PostCard(post: post, shared: postUser);
                }

            );
          })
    );
  }
}
