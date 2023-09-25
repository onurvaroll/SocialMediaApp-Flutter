import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/models/notification.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/pages/profile.dart';
import 'package:social_media/pages/single_post.dart';
import 'package:social_media/service/authorization_service.dart';
import 'package:social_media/service/firestore_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../theme/theme.dart';


class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<NotificationObject> _notificationsList;
  late String _activeUserId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _activeUserId = Provider.of<AuthorizationService>(context, listen: false).activeUserId!;
    getNotifications();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Future<void> getNotifications() async {
    List<NotificationObject> notificationsList = await FireStoreService().getNotifications(_activeUserId);
    if (mounted) {
      setState(() {
        _notificationsList = notificationsList;
        _loading = false;
      });
    }
  }

  showNotifications(){

    if(_loading){
      return const Center(child: CircularProgressIndicator());
    }

    if(_notificationsList.isEmpty){
      return const Center(child: Text("Hiç duyurunuz yok."));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: RefreshIndicator(
        onRefresh: getNotifications,
        child: ListView.builder(
            itemCount: _notificationsList.length,
            itemBuilder: (context, index){
              NotificationObject notification = _notificationsList[index];
              return notificationRow(notification);
            }
        ),
      ),
    );

  }

  notificationRow(NotificationObject notification){
    String message = createMessage(notification.notifyType);
    return FutureBuilder(
        future: FireStoreService().getUser(notification.notifyUserId),
        builder: (context, snapshot){

          if(!snapshot.hasData){
            return const SizedBox(height: 0.0,);
          }

          UserObject? notifyUser = snapshot.data;

          return ListTile(
            leading: InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(currentProfileId: notification.notifyUserId,)));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(notifyUser!.fotoUrl),
              ),
            ),
            title: RichText(
              text: TextSpan(
                  recognizer: TapGestureRecognizer()..onTap=(){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(currentProfileId: notification.notifyUserId,)));
                  },
                  text: notifyUser.kullaniciAdi,
                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: notification.comment == "" ? " $message" : " $message ${notification.comment}" ,
                        style: const TextStyle(fontWeight: FontWeight.normal,color: Colors.white))
                  ]
              ),
            ),
            subtitle: Text(timeago.format(notification.createTime.toDate(), locale: "tr")),
            trailing: showPostPhoto(notification.notifyType, notification.postPhoto, notification.postId),
          );

        }
    );
  }

  showPostPhoto(String notifyType, String postPhoto, String postId){
    if(notifyType == "takip"){
      return const SizedBox();
    } else if(notifyType == "begeni" || notifyType == "yorum"){
      if(postPhoto==""){
        return GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>SinglePost(postId: postId, sharedPostId: _activeUserId,)));
          },
          child: const SizedBox(
            height: 50,
            width: 50,
            child: Center(
                child: Text("Post",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.indigo),
                )
            ),
          ),
        );
      }
      return GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>SinglePost(postId: postId, sharedPostId: _activeUserId,)));
          },
          child: Image.network(postPhoto, width: 50.0, height: 50.0, fit: BoxFit.cover,)
      );
    }
  }

  createMessage(String notifyType){
    if(notifyType == "begeni"){
      return "gönderini beğendi.";
    } else if(notifyType == "takip"){
      return "seni takip etti.";
    } else if(notifyType == "yorum"){
      return "gönderine yorum yaptı";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ThemeOfSocialMedia().titleAppBarText(context),
          elevation: 0,
        centerTitle: true,
        toolbarHeight: MediaQuery.of(context).size.height * 0.06,
      ),
      body: showNotifications(),
    );
  }
}
