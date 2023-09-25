import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/models/post.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/pages/comments_page.dart';
import 'package:social_media/pages/map_page.dart';
import 'package:social_media/pages/profile.dart';
import 'package:social_media/service/authorization_service.dart';
import 'package:social_media/service/firestore_service.dart';

import '../pages/single_post.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post, required this.shared});

  final Post post;
  final UserObject? shared;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _likeSize = 0;
  bool _isLike = false;
  late String _activeUserId;

  @override
  void initState() {
    super.initState();
    _likeSize = widget.post.likeSize;
    _activeUserId =
    Provider.of<AuthorizationService>(context, listen: false).activeUserId!;
    likeStatus();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  likeStatus() async {
    bool likeStatus =
    await FireStoreService().postLikeStatus(widget.post, _activeUserId);
    if (likeStatus) {
      if (mounted) {
        setState(() {
          _isLike = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(currentProfileId:widget.post.shareId)));
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: widget.shared!.fotoUrl.isNotEmpty
                      ? NetworkImage(widget.shared!.fotoUrl)
                      : const NetworkImage(
                      'https://firebasestorage.googleapis.com/v0/b/firstproject-d42cf.appspot.com/o/bosprofilresmi%2Favatar.png?alt=media&token=47616d3b-99cf-4989-92e5-f316704aad9c'),
                ),
              ),
              title: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(currentProfileId:widget.post.shareId)));
                },
                child: Text(
                  widget.shared!.kullaniciAdi,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              subtitle: Text(timeago.format(widget.post.createTime.toDate(), locale: "tr")),
              trailing: _activeUserId==widget.post.shareId? PopupMenuButton<int>(
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<int>>[
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Text("Postu Sil"),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 1) {
                    // Show confirmation dialog and delete post on confirmation.
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Postu Sil"),
                          content: const Text("Bu gönderiyi silmek istediğinize emin misiniz?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("İptal"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Call the delete post method here.
                                FireStoreService().deletePost(post: widget.post,activeUserId: _activeUserId);
                                Navigator.of(context).pop();
                              },
                              child: const Text("Sil"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ):null,
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SinglePost(postId: widget.post.id,sharedPostId: widget.post.shareId)),
              );},
              onDoubleTap: _likeStatus,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 5, left: 20, right: 20, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.post.content,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                  widget.post.fotoUrl.isNotEmpty
                      ? SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width,
                    child: Image.network(
                      widget.post.fotoUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const SizedBox(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Text(
                      '$_likeSize',
                      style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: !_isLike
                          ? const Icon(Icons.favorite_border)
                          : const Icon(Icons.favorite, color: Colors.red),
                      onPressed: _likeStatus,
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CommentsPage(post: widget.post)),
                    );
                  },
                  icon: const Icon(Icons.comment_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                ),
                widget.post.location.isNotEmpty
                    ? TextButton(
                  onPressed: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MapWidget(city: widget.post.location),
                      ),
                    );
                  },
                  child: Text(
                    widget.post.location,
                    style: const TextStyle(
                        color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                )
                    : const SizedBox(width: 60),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _likeStatus() {
    if (_isLike) {
      setState(() {
        _isLike = false;
        _likeSize = _likeSize - 1;
      });
      FireStoreService().postUnlike(widget.post, _activeUserId);
    } else {
      setState(() {
        _isLike = true;
        _likeSize = _likeSize + 1;
      });
      FireStoreService().postLike(widget.post, _activeUserId);
    }
  }
}
