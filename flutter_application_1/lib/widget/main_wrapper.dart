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
      bottomNavigationBar: MainWrapperBottomNavBar(
        currentIndex: _currentIndex,
        onPageChanged: onPageChanged,
      ),
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


  // _bottomAppBarItem and _mainWrapperBottomNavBar removed; see MainWrapperBottomNavBar below.
}

class MainWrapperBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onPageChanged;

  const MainWrapperBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: lightBlue,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _bottomAppBarItem(
              context,
              icon: CupertinoIcons.today,
              page: 0,
              label: "Today",
              currentIndex: currentIndex,
              onPageChanged: onPageChanged,
            ),
          ),
          Expanded(
            child: _bottomAppBarItem(
              context,
              icon: CupertinoIcons.calendar,
              page: 1,
              label: "Calendar",
              currentIndex: currentIndex,
              onPageChanged: onPageChanged,
            ),
          ),
          Expanded(
            child: _bottomAppBarItem(
              context,
              icon: CupertinoIcons.chart_bar_fill,
              page: 2,
              label: "Analytics",
              currentIndex: currentIndex,
              onPageChanged: onPageChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomAppBarItem(
    BuildContext context, {
    required IconData icon,
    required int page,
    required String label,
    required int currentIndex,
    required Function(int) onPageChanged,
  }) {
    return GestureDetector(
      onTap: () {
        onPageChanged(page);
        print("Page changed to $page => $label");
      },
      child: Container(
        color: transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Icon(
              icon,
              color: currentIndex == page && currentIndex != -1 ? amber : white,
              size: 26,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: currentIndex == page && currentIndex != -1 ? amber : white,
                fontSize: 13,
                fontWeight: currentIndex == page && currentIndex != -1
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}