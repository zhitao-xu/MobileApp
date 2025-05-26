import 'package:flutter/material.dart';

const Color amber = Colors.amber;
const Color darkBlue = Color.fromRGBO(13, 71, 161, 1);
const Color lightBlue = Colors.blue;
const Color transparent = Colors.transparent;
const Color white = Colors.white;
const Color grey = Colors.grey;
const Color greyDark = Color.fromARGB(255, 101, 100, 100);
const Color black = Colors.black;
const Color red = Colors.red;
const Color green = Colors.green;
const Color blue = Colors.blue;
const Color purple = Color.fromARGB(200, 175, 78, 192);

const Color backgoundGrey = Color.fromARGB(255, 231, 230, 230);
const Color bgBlue = Color.fromRGBO(56, 90, 242, 0.102);

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

TextStyle get homeTitleStyle{
  return TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: white,
  );
}

TextStyle get homeSubTitleStyle{
  return TextStyle(
    fontSize: 15,
    color: white,
  );
}

TextStyle get taskTitleStyle{
  return TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: black,
  );
}

TextStyle get taskInfoStyle{
  return TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: greyDark,
  );
}