// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class LoginInput extends StatefulWidget {
  LoginInput(
      {Key? key,
        required this.validator,
      required this.hintText,
      required this.obscureText,
      required this.textController})
      : super(key: key);
  String? Function(String?)? validator;
  final String hintText;
  bool obscureText = false;
  TextEditingController textController = TextEditingController();

  void shareText() {}

  @override
  // ignore: library_private_types_in_public_api
  _LoginInputState createState() => _LoginInputState();
}

class _LoginInputState extends State<LoginInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.obscureText,
      controller: widget.textController, // Use the TextEditingController
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20)),
        hintText: widget.hintText,
      ),
      validator: widget.validator,
    );
  }
}
