import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bloc/bottom_nav.dart';
import 'package:flutter_application_1/pages/pages.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/data/todo.dart';
import 'package:flutter_application_1/todo_bloc/todo_bloc.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  final GlobalKey<HomePageState> homePageKey = GlobalKey<HomePageState>();

  /*
  // The list of pages. Note that CalendarPage will now be initialized inside
  // the BlocBuilder to receive the todos.
  // The AnalyticsPage will also need the todos if it displays task analytics.
  final List<Widget> _topLevPages = const [
    HomePage(),
    //CalendarPage(), - This will be dynamically created below
    AnalyticsPage(),
  ];*/

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      bottomNavigationBar: MainWrapperBottomNavBar(
        currentIndex: _currentIndex,
        onPageChanged: onPageChanged,
        onTabPressed: (){
          if(homePageKey.currentState != null){
            homePageKey.currentState!.stopSearching();
          }
        },
      ),
      body: _mainWrapperBody(), // Now _mainWrapperBody handles the BlocBuilder and IndexedStack
    );
  }

  void onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });

    if(page != 0 && homePageKey.currentContext != null){
      homePageKey.currentState!.stopSearching();
    }

    BlocProvider.of<BottomNav>(context).changeSelectedIndex(page);
  }

  // Body
  Widget _mainWrapperBody() { // Changed return type to Widget
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, todoState) {
      if (todoState.status == TodoStatus.success) {
      final List<Todo> allTodos = todoState.todos;

            // topLevPages was moved here
            // Dynamically create the list of pages with the current todos
            final List<Widget> pagesWithData = [
              HomePage(key: homePageKey), // HomePage typically doesn't need to be recreated, as it gets its own BlocBuilder for filtering
              CalendarPage(todos: allTodos), // Pass the todos here!
              AnalyticsPage(),
            ];

            return IndexedStack(
              index: _currentIndex,
              children: pagesWithData.map((page) {
                // The AnimatedSwitcher should ideally be inside each page itself if you want
                // animation only on that specific page's content changes, not the whole page swap.
                // For full page transitions, this is fine.
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: page,
                );
              }).toList(),
            );
          } else if (todoState.status == TodoStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          } else {
            // Handle other states like error or loading
            return const Center(child: Text('Failed to load tasks.'));
          }
        },
      );
    }
}

class MainWrapperBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onPageChanged;
  final VoidCallback? onTabPressed;

  const MainWrapperBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
    this.onTabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: lightBlue,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child:_bottomAppBarItem(
              context, 
              icon: CupertinoIcons.list_bullet, 
              page: 0, 
              label: "To-do List",
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
    final VoidCallback? onTabPressed,
  }) {
    return GestureDetector(
      onTap: () {
        onTabPressed?.call();
        onPageChanged(page);
        if (kDebugMode) {
          print("Page changed to $page => $label");
        }
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