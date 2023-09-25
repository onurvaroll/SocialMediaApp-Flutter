import 'package:flutter/material.dart';

class ThemeOfSocialMedia{

  normalAppBarText(String headText,context){
    return Text(headText,
        style: Theme.of(context).textTheme.headlineLarge);
  }
  titleAppBarText(context){
    return Text('Sceim',
        style: Theme.of(context).textTheme.headlineLarge);
  }

}