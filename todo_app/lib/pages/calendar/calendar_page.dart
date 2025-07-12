import 'package:flutter/material.dart';
import 'package:todo_app/utils/theme.dart';
import 'package:todo_app/widget/custom_app_bar.dart';
import 'package:todo_app/data/todo.dart';
import 'calendar_widget.dart';

class CalendarPage extends StatefulWidget {
  final List<Todo> todos;
  const CalendarPage({super.key, required this.todos});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: const PreferredSize( // Removed PreferredSize for CustomAppBar - assuming it's handling its own size
        preferredSize: Size.fromHeight(100), // Assuming CustomAppBar uses this height
        child: CustomAppBar(
          title: "Calendar\n",
          isHome: false,
        ),
      ),
      body: Container(
        color: white,
        // The CalendarWidget will fill the rest of the available space
        child: CalendarWidget(
          tasks: widget.todos, // <--- Pass your list of Todo items here
        ),
      ),
    );
  }
}