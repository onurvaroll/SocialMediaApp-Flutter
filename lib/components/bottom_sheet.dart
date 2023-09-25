import 'package:flutter/material.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/pages/update_profile.dart';
import 'package:social_media/service/authorization_service.dart';

class AddBottomSheet {

  void bottomSheet(BuildContext context, UserObject userObject) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      context: context,
      elevation: 0,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Padding(
            padding: const EdgeInsets.only(left: 10,right: 10,top: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.tonal(
                   style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.indigo)),
                   onPressed: (){
                 Navigator.push(context, MaterialPageRoute(builder:(context)=> UpdateProfile(user:userObject)));
               },
                   child: const Text("Profili Düzenle")),
                const SizedBox(height: 30,),
                FilledButton.tonal(style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.indigo)),
                    onPressed: ()async{
                      await AuthorizationService().signOut();
                      // ignore: use_build_context_synchronously
                      Navigator.of (context) .popUntil ((route) => route.isFirst);
                    },
                    child: const Text('Çıkış Yap'))
              ],
            ),
          ),
        );
      },
    );
  }
}



