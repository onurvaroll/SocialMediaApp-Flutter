import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/pages/new_account.dart';
import 'package:social_media/service/authorization_service.dart';
import 'package:social_media/theme/theme.dart';
import '../components/login_input.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: MediaQuery.of(context).size.height * 0.06,
        centerTitle: true,
        title: Center(
          child: ThemeOfSocialMedia().titleAppBarText(context)
        ),
      ),
      body: Center(
        child: SizedBox(
          child: ListView(children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: loginFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('Giriş Yap',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      LoginInput(
                          validator: (val) {
                            if (!EmailValidator.validate(val!)) {
                              return 'Geçerli Bir E-Posta Adresi Girin';
                            } else {
                              return null;
                            }
                          },
                          textController: userEmailController,
                          obscureText: false,
                          hintText: 'E-Postanızı Girin'),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      LoginInput(
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Şifre Boş Bırakılamaz';
                          } else {
                            return null;
                          }
                        },
                        obscureText: true,
                        hintText: 'Şifrenizi Girin',
                        textController: userPasswordController,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      FilledButton.tonal(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.indigo),
                            alignment: Alignment.center,
                          ),
                          onPressed: ()async {
                            if(loginFormKey.currentState!.validate()){
                             await Provider.of<AuthorizationService>(context,listen:false).signIn(
                                  userEmailController.text, userPasswordController.text).then((user) {
                               Navigator.pushReplacement (
                                 context,
                                 MaterialPageRoute (builder: (BuildContext context) => const MainPage ()),
                               );
                             });


                            }

                          },
                          child: const Text('Giriş Yap')),
                      TextButton(
                          onPressed: () {}, child: const Text('Şifremi Unuttum',style: TextStyle(color: Colors.indigo),)),
                      FilledButton.tonal(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          // Set your desired background color here
                          alignment: Alignment.center,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const NewAccountPage()));
                        },
                        child: const Text('Yeni Hesap Oluştur'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
