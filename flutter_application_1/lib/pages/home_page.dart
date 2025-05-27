import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widget/todo/todo_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/custom_app_bar.dart';
import 'package:flutter_application_1/data/todo.dart';
import 'package:flutter_application_1/todo_bloc/todo_bloc.dart';
import 'package:flutter_application_1/pages/task_details.dart';
import 'package:flutter_application_1/utils/todo_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  removeTodo(Todo todo) {
    context.read<TodoBloc>().add(RemoveTodo(todo));
  }

  alertTodo(int index) {
    context.read<TodoBloc>().add(AlterTodo(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: CustomAppBar(
          title: "To-do List\n",
          isHome: true,
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TaskDetailsPage(),
              ),
            );
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 10,
          backgroundColor: amber,
          child: const Icon(
            CupertinoIcons.add,
            color: white,
            size: 40, 
          ),
        ),
      ),
      body: Container(
        color: backgoundGrey,
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            if (state.status == TodoStatus.success) {
              // Filter and sort pending tasks using the utility function
              final sortedPendingTodos = sortTodosByPriorityAndDeadline(
                state.todos.where((todo) => !todo.isDone).toList(),
              );

              // Filter and sort completed tasks using the utility function
              final sortedCompletedTodos = sortTodosByPriorityAndDeadline(
                state.todos.where((todo) => todo.isDone).toList(),
              );

              return ListView(
                // Added padding to the bottom to move the last task out of the way of the add task floating action button
                padding: const EdgeInsets.only(bottom: 85.0), // Adjust this value as needed
                children: [
                  if (sortedPendingTodos.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Pending Tasks',
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Directly use TodoCard here
                    ...sortedPendingTodos.map((todo) =>
                        TodoCard.forTodo(
                          key: ValueKey(todo.id), // Unique key for efficiency
                          todo: todo,
                          originalIndex: state.todos.indexOf(todo), // Pass the original index from the main list
                          onDelete: () => removeTodo(todo),
                          onToggleCompletion: () => alertTodo(state.todos.indexOf(todo)),
                        ),
                    ),
                  ],
                  if (sortedCompletedTodos.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Completed Tasks',
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Directly use TodoCard here
                    ...sortedCompletedTodos.map((todo) =>
                        TodoCard.forTodo(
                          key: ValueKey(todo.id), // Unique key for efficiency
                          todo: todo,
                          originalIndex: state.todos.indexOf(todo), // Pass the original index from the main list
                          onDelete: () => removeTodo(todo),
                          onToggleCompletion: () => alertTodo(state.todos.indexOf(todo)),
                        ),
                    ),
                  ],
                ],
              );
            } else if (state.status == TodoStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}