import 'package:flutter/material.dart';

const Color amber = Colors.amber;
const Color darkBlue = Color.fromRGBO(13, 71, 161, 1);
const Color lightBlue = Colors.blue;
const Color transparent = Colors.transparent;
const Color white = Colors.white;
const Color grey = Colors.grey;

class Themes{
  static final light = ThemeData(
    primaryColor: lightBlue,
    brightness: Brightness.light,
  );

  static final dark = ThemeData(
    primaryColor:  darkBlue,
    brightness: Brightness.dark,
  );
}

TextStyle get titleStyle{
  return TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: white,
  );
}

TextStyle get subTitleStyle{
  return TextStyle(
    fontSize: 15,
    color: white,
  );
}