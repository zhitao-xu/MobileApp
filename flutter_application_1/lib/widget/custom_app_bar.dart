import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:intl/intl.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key, 
    required this.title,  
    required this.isHome,
  });

  final String title;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: lightBlue,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 25,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Setting Icon
              CircleAvatar(
                backgroundColor: white,
                child: GestureDetector(
                  onTap: () {
                    // go to settings page
                    if (kDebugMode) {
                      print('Setting Icon Tapped');
                    }
                  },
                  child: Icon(
                    CupertinoIcons.settings,
                    size: 30,
                  ),
                ),
              ),
              titleContent(title, isHome),
              // Search Icon
              GestureDetector(
                child: Icon(
                  CupertinoIcons.slider_horizontal_3,
                  size: 40,
                  color: white,
                ),
                onTap: () {
                  // go to search page
                  // print('Search Icon Tapped');
                  
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  RichText titleContent(String title, bool isHome) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: isHome ? [
          TextSpan(
            text: title,
            style: homeTitleStyle,
          ),
          TextSpan(
            text:  DateFormat.yMMMMd().format(DateTime.now()),
            style: homeSubTitleStyle,
          ),
        ] : [
          TextSpan(
            text: title,
            style: homeTitleStyle,
          ),
        ],
      ),
    );
  }
}