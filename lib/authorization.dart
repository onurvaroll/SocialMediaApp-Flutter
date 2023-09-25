import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/pages/login_page.dart';
import 'package:social_media/pages/main_page.dart';
import 'package:social_media/service/authorization_service.dart';

class Authorization extends StatelessWidget {
  const Authorization({super.key});

  @override
  Widget build(BuildContext context) {
    final authorizationservice=Provider.of<AuthorizationService>(context,listen: false);
    return StreamBuilder<UserObject?>(
      stream: authorizationservice.authStatus,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator());

        } else {
          if (snapshot.hasData) {
            UserObject? activeUser=snapshot.data;
            authorizationservice.activeUserId=activeUser!.id;
            return const MainPage();
          } else {
            return const LoginPage();
          }
        }
      },
    );
  }
}




