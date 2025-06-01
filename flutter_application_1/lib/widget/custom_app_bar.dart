import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Setting Icon
              CircleAvatar(
                backgroundColor: white,
                child: GestureDetector(
                  onTap: () {
                    if (kDebugMode) {
                      print('Setting Icon Tapped');
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                  child: const Icon(
                    CupertinoIcons.settings,
                    size: 30,
                  ),
                ),
              ),
              
              Expanded(
                child: Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: titleContent(title, isHome),
                ),
              ),
              // Search Icon
              GestureDetector(
                child: Icon(
                  CupertinoIcons.slider_horizontal_3,
                  size: 40,
                  color: white,
                ),
                onTap: () {
                  // TODO: Implement filter pop-up menu functionality here
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
        children: isHome
            ? [
                TextSpan(
                  text: title,
                  style: homeTitleStyle,
                ),
                TextSpan(
                  text: DateFormat.yMMMMd().format(DateTime.now()),
                  style: homeSubTitleStyle,
                ),
              ]
            : [
                TextSpan(
                  text: title,
                  style: homeTitleStyle,
                ),
                // Add invisible second line to maintain consistent height
                TextSpan(
                  text: '\n',
                  style: homeSubTitleStyle.copyWith(
                    color: Colors.transparent,
                    height: 0.1,
                  ),
                ),
              ],
      ),
    );
  }
}