import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/components/post_card.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/service/authorization_service.dart';
import 'package:social_media/service/firestore_service.dart';
import '../components/bottom_sheet.dart';
import '../models/post.dart';
import '../theme/theme.dart';

// ignore: must_be_immutable
class Profile extends StatefulWidget {
  const Profile({
    Key? key,
    required this.currentProfileId,
  }) : super(key: key);
  final String? currentProfileId;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _followerSize = 0;
  int _followingSize = 0;
  int _postSize = 0;

  List<Post> _posts = [];
  late String activeUserId;
  late UserObject userProfile;
  bool _isFollow = false;

  _getFollowerSize() async {
    int followerSize =
        await FireStoreService().followerSize(widget.currentProfileId);
    if (mounted) {
      setState(() {
        _followerSize = followerSize;
      });
    }
  }

  _getFollowingSize() async {
    int followingSize =
        await FireStoreService().followingSize(widget.currentProfileId);
    if (mounted) {
      setState(() {
        _followingSize = followingSize;
      });
    }
  }

  _getPosts() async {
    List<Post> userPosts =
        await FireStoreService().getPosts(widget.currentProfileId);
    if (mounted) {
      setState(() {
        _posts = userPosts;
        _postSize = _posts.length;
      });
    }
  }
  followControl()async{
   bool isFollow= await FireStoreService().followControl(activeUserId: activeUserId, profileUserId: widget.currentProfileId);
   setState(() {
     _isFollow=isFollow;
   });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getFollowerSize();
    _getFollowingSize();
    _getPosts();
    activeUserId =
        Provider.of<AuthorizationService>(context, listen: false).activeUserId!;
    followControl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title:  ThemeOfSocialMedia().normalAppBarText('Profil', context),
          elevation: 0,
          actions: [
            widget.currentProfileId == activeUserId
                ? IconButton(
                    onPressed: () {
                      AddBottomSheet addBottomSheet = AddBottomSheet();
                      addBottomSheet.bottomSheet(context, userProfile);
                    },
                    icon: const Icon(Icons.settings))
                : followButton(),
          ],
          toolbarHeight: MediaQuery.of(context).size.height * 0.06,
        ),
        body: FutureBuilder(
            future: FireStoreService().getUser(widget.currentProfileId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              userProfile = snapshot.data!;
              return RefreshIndicator(onRefresh: _refreshPosts,
                child: ListView(children: <Widget>[
                  profileDetails(snapshot.data),
                  const Divider(
                    color: Colors.black,
                    height: 10,
                    thickness: 1,
                  ),
                  _showPosts(snapshot.data),
                ]),
              );
            }));
  }

  followButton() {
    return _isFollow ? notFollowedButton() : followedButton();
  }

  Widget followedButton() {
    return OutlinedButton(
        style: const ButtonStyle(
            elevation: MaterialStatePropertyAll(0),
            backgroundColor: MaterialStatePropertyAll(Colors.indigo)),
        onPressed: () {
          FireStoreService().followed(
              activeUserId: activeUserId,
              profileUserId: widget.currentProfileId);
          setState(() {
            _isFollow = true;
            _followerSize=_followerSize+1;
          });
        },
        child: const Text(
          "Takip Et",
          style: TextStyle(color: Colors.white),
        ));
  }

  Widget notFollowedButton() {
    return OutlinedButton(
        style: const ButtonStyle(
            elevation: MaterialStatePropertyAll(0),
            backgroundColor: MaterialStatePropertyAll(Colors.indigo)),
        onPressed: () {
          FireStoreService().notFollowed(
              activeUserId: activeUserId,
              profileUserId: widget.currentProfileId);
          setState(() {
            _isFollow = false;
            _followerSize=_followerSize-1;
          });
        },
        child: const Text(
          "Takipten Çık",
          style: TextStyle(color: Colors.white),
        ));
  }

  Widget profileDetails([UserObject? profileData]) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(
          height: 10,
        ),
        profileData!.fotoUrl.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(profileData.fotoUrl), radius: 50)
            : const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/avatar.png')),
        const SizedBox(
          height: 10,
        ),
        Text(profileData.kullaniciAdi,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(
          height: 10,
        ),
        Text(profileData.hakkinda, textAlign: TextAlign.center),
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.indigo),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                userDataCard(text: 'Takip', number: _followingSize),
                userDataCard(text: 'Takipçi', number: _followerSize),
                userDataCard(text: "Post", number: _postSize)
              ],
            ),
          ),
        ),
      ]),
    );
  }
  Future<void> _refreshPosts() async {
    _showPosts(userProfile);
    profileDetails();
  }

  Widget _showPosts(UserObject? profileData) {
    if(_posts.isEmpty){
      return const Center(
          child: Column(
            children: [
              Text("Kullanıcının Hiç Postu Yok",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                  fontStyle: FontStyle.italic)
              ),
            ],
          )
      );
    }else{
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return PostCard(post: _posts[index], shared: profileData);
        });
  }
  }
}

Widget userDataCard({required String text, required int number}) {
  return Expanded(
    flex: 1,
    child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Center(
            child: Text(
          '$text: $number',
          style: const TextStyle(fontSize: 18),
        ))),
  );
}
