import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key, 
    required this.title,  
  });

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.lightGreen,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 25 / 2.5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Setting Icon
              CircleAvatar(
                backgroundColor: Colors.orange,
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
              title,
              // Search Icon
              GestureDetector(
                child: Icon(
                  CupertinoIcons.search,
                  size: 30,
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