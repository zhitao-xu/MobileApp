import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bloc/bottom_nav.dart';
import 'package:flutter_application_1/pages/pages.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // Top Level Pages
  final List<Widget> _topLevPages = const [
    HomePage(),
    CalendarPage(),
    AnalyticsPage(),
  ];

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      bottomNavigationBar: _mainWrapperBottomNavBar(context),
      body: _mainWrapperBody(),
    );
  }

  void onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
    BlocProvider.of<BottomNav>(context).changeSelectedIndex(page);
  }

  // Body
  IndexedStack _mainWrapperBody(){
  return IndexedStack(
    index: _currentIndex,
    children: _topLevPages.map((page) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: page,
      );
    }).toList(),
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
          onPageChanged(page);
          print("Page changed to $page => $label");
        },
        child: Container(
          color: transparent,
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
                  ? amber 
                  : white,
                size: 26,
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                label,
                style: TextStyle(
                  color: currentIndex == page 
                    ? amber 
                    : white,
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
      color: lightBlue,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child:_bottomAppBarItem(
              context, 
              icon: CupertinoIcons.today, 
              page: 0, 
              label: "Today"
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
              icon: CupertinoIcons.chart_bar_fill, 
              page: 2, 
              label: "Analytics"
            ),
          ),
        ],
      )
    );
  }
}