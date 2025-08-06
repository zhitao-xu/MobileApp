import 'package:flutter/material.dart';
import 'package:todo_app/data/todo.dart';
import 'package:todo_app/pages/calendar/calendar_page.dart';

class CalendarPageWrapper extends StatelessWidget {
  const CalendarPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List<Todo>;

    return CalendarPage(todos: args);
  }
}

/* Example to use '/calendar'

Navigator.pushNamed(
  context,
  '/calendar',
  arguments: allTodos,
);


*/

