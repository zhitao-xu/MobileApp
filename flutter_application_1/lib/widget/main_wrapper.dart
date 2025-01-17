import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bloc/bottom_nav.dart';
import 'package:flutter_application_1/pages/pages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // controller for the page view
  late PageController _pageController;
  
  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Top Level Pages
  final List<Widget> _topLevPages = const [
    HomePage(),
    CalendarPage(),
    ProfilePage(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: _mainWrapperAppBar(),
      bottomNavigationBar: _mainWrapperBottomNavBar(context),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: _mainWrapperFloatingActionButton()
      ),

      body: _mainWrapperBody(),
    );
  }

  void onPageChanged(int page) {
    BlocProvider.of<BottomNav>(context).changeSelectedIndex(page);
  }

  // Body
  PageView _mainWrapperBody(){
    return PageView(
      onPageChanged: (int page) => onPageChanged(page),
      controller: _pageController,
      children: _topLevPages,
    );
  }

  // App Bar
  AppBar _mainWrapperAppBar() {
    return AppBar(
      title: const Text('DoTo App'),
      centerTitle: true,
      backgroundColor: Colors.green,
      elevation: 0,
    );
  }

  // Single item in Bottom Navigation Bar 
  Widget _bottomAppBarItem(
    BuildContext context, {
      required icon,
      // required filledIcon,
      required page,
      required label,   
    }){
      int currentIndex = context.watch<BottomNav>().state;

      return GestureDetector(
        onTap: (){
          // change index of selected page
          BlocProvider.of<BottomNav>(context).changeSelectedIndex(page);
          log("Page changed to $page => $label");

          _pageController.animateToPage(
            page,
            duration: const Duration(milliseconds: 10),
            curve: Curves.fastLinearToSlowEaseIn,
          );

        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 8,
              ),
              // Icons
              Icon(
                /*0 == page 
                  ? filledIcon 
                  : defaultIcon,
                  */
                  icon,
                color : currentIndex == page 
                  ? Colors.amber 
                  : Colors.grey,
                size: 26,
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                label,
                style: TextStyle(
                  color: currentIndex == page 
                    ? Colors.amber 
                    : Colors.grey,
                  fontSize: 13,
                  fontWeight: currentIndex == page
                    ? FontWeight.w600
                    : FontWeight.w400,
                ),
              ),
            ],
          )
        )

      );
    }

  BottomAppBar _mainWrapperBottomNavBar(BuildContext context){
    return BottomAppBar(
      color: Colors.black,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child:_bottomAppBarItem(
              context, 
              icon: CupertinoIcons.home, 
              page: 0, 
              label: "Home"
            ),
          ),
          Expanded(
            child: _bottomAppBarItem(
                context, 
                icon: CupertinoIcons.calendar, 
                page: 1, 
                label: "Calendar"
              ),
          ),
          Expanded(
            child: _bottomAppBarItem(
              context, 
              icon: CupertinoIcons.profile_circled, 
              page: 2, 
              label: "Profile"
            ),
          ),
        ],
      )
    );
  }

  FloatingActionButton _mainWrapperFloatingActionButton(){
    return FloatingActionButton(
      onPressed: (){
        // TODO: Add new task
        log("Add new task Buttton pressed");
      },

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      elevation: 10,
      backgroundColor: Colors.amber,
      child: const Icon(
        CupertinoIcons.add,
        color: Colors.white,
        size: 40, 
      ),
    );
  }
}