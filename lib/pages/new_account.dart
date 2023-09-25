import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/service/authorization_service.dart';
import 'package:social_media/service/firestore_service.dart';

import '../components/login_input.dart';
import '../theme/theme.dart';

enum FormStatus { signIn, newAccount }

class NewAccountPage extends StatefulWidget {
  const NewAccountPage({Key? key}) : super(key: key);

  @override
  State<NewAccountPage> createState() => _NewAccountPageState();
}

class _NewAccountPageState extends State<NewAccountPage> {
  TextEditingController newUserName = TextEditingController();
  TextEditingController newUserEmail = TextEditingController();
  TextEditingController newUserPassword = TextEditingController();
  TextEditingController newUserPasswordRepeat = TextEditingController();
  bool loading = false;

  final _newAccountFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: MediaQuery.of(context).size.height * 0.06,
        centerTitle: true,
        title: ThemeOfSocialMedia().titleAppBarText(context),
      ),
      body: Center(
        child: ListView(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _newAccountFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Hesap Oluştur',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      LoginInput(
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Kullanıcı Adı Boş Bırakılamaz';
                          } else {
                            return null;
                          }
                        },
                        textController: newUserName,
                        obscureText: false,
                        hintText: 'Kullanıcı Adınızı Belirleyiniz',
                      ),
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
                        textController: newUserEmail,
                        obscureText: false,
                        hintText: 'E-Postanızı Giriniz',
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      LoginInput(
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Şifre Boş Bırakılamaz';
                          } else if (val.trim().length < 8) {
                            return "Şifre 8 karakterden az olamaz!";
                          } else {
                            return null;
                          }
                        },
                        textController: newUserPassword,
                        obscureText: true,
                        hintText: 'Şifrenizi Belirleyiniz',
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      LoginInput(
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Şifre Boş Bırakılamaz';
                          } else if (val != newUserPassword.text) {
                            return 'Şifreler eşleşmiyor';
                          } else {
                            return null;
                          }
                        },
                        textController: newUserPasswordRepeat,
                        obscureText: true,
                        hintText: 'Şifrenizi Tekrar Giriniz',
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
                        onPressed: _createUser,
                        child: const Text('Hesap Oluştur'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _createUser() async {
    final authorizationService =
        Provider.of<AuthorizationService>(context, listen: false);
    if (_newAccountFormKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          loading = true;
        });
      }
      try {
        UserObject? user = await authorizationService.createUser(
            newUserEmail.text, newUserPassword.text);
        if (user != null) {
          print("User created successfully");
          FireStoreService()
              .saveUser(photoUrl: "https://firebasestorage.googleapis.com/v0/b/firstproject-d42cf.appspot.com/o/bosprofilresmi%2Favatar.png?alt=media&token=47616d3b-99cf-4989-92e5-f316704aad9c",
                  email: newUserEmail.text,
                  userName: newUserName.text,
                  id: user.id)
              .then((value) => print("User saved to Firestore"));
        }
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (error) {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
        if (error is FirebaseException) {
          _errorFind(errorCode: error.code.toString());
        } else {
          _errorFind(errorCode: error.toString());
        }
      }
    }
  }

  _errorFind({required String errorCode}) {
    String errorMessage = "Bir hata oluştu";

    if (errorCode == "invalid-email") {
      errorMessage = "Girdiğiniz mail adresi geçersizdir";
    } else if (errorCode == "email-already-in-use") {
      errorMessage = "Girdiğiniz mail kayıtlıdır";
    } else if (errorCode == "weak-password") {
      errorMessage = "Daha güçlü bir şifre seçmelisiniz";
    }

    var snackBar = SnackBar(content: Text(errorMessage));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
