import 'package:flutter/material.dart';

const Color amber = Colors.amber;
const Color orange = Colors.orange;
const Color darkBlue = Color.fromRGBO(13, 71, 161, 1);
const Color transparentDarkBlue = Color.fromRGBO(13, 71, 161, 0.25);
const Color lightBlue = Colors.blue; // 255, 33, 150, 243 (ARGB)
const Color transparentLightBlue = Color.fromARGB(64,33,150,243);
const Color transparent = Colors.transparent;
const Color white = Colors.white;
const Color grey = Colors.grey;
const Color black = Colors.black;
const Color backgoundGrey = Color.fromARGB(255, 204, 203, 203);
const Color red = Colors.red;
const Color green = Colors.green;
const Color blue = Colors.blue;

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


/// Returns a color based on the Todo's priority string.
Color getPriorityColor(String priorityString) {
  switch (priorityString.toLowerCase()) {
    case 'high':
      return Color.fromARGB(255, 239, 154, 154); // Assume 'red' is defined in theme.dart
    case 'medium':
      return Color.fromARGB(255, 255, 204, 128); // Assume 'orange' is defined in theme.dart
    case 'low':
      return Colors.white; // Assume 'white' is defined in theme.dart
    default:
      return black; // Default color for unknown priority
  }
}