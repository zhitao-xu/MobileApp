
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/theme.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key, 
    required this.title,  
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: lightBlue,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
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
                    print('Setting Icon Tapped');
                  },
                  child: Icon(
                    CupertinoIcons.settings,
                    size: 30,
                  ),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: white,
                ),
              ),
              // Search Icon
              GestureDetector(
                child: Icon(
                  CupertinoIcons.search,
                  size: 30,
                  color: white,
                ),
                onTap: () {
                  // go to search page
                  print('Search Icon Tapped');
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}