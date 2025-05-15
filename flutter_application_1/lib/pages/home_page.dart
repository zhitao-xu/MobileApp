import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/add_task_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/custom_app_bar.dart';
import 'package:flutter_application_1/data/todo.dart';
import 'package:flutter_application_1/todo_bloc/todo_bloc.dart';
import 'package:flutter_application_1/pages/task_details.dart'; // Import TaskDetailsPage
import 'package:flutter_slidable/flutter_slidable.dart';

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
            addTaskDialog(context);
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
        color: white,
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            if (state.status == TodoStatus.success) {
              final todos = state.todos
                  .where((todo) => !todo.isDone)
                  .toList()
                ..sort((a, b) {
                  const priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
                  return priorityOrder[a.priority]!
                      .compareTo(priorityOrder[b.priority]!);
                });

              final completedTodos =
              state.todos.where((todo) => todo.isDone).toList();

              return ListView(
                children: [
                  if (todos.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Pending Tasks',
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...todos.map((todo) =>
                        buildTodoCard(todo, state.todos.indexOf(todo))),
                  ],
                  if (completedTodos.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Completed Tasks',
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...completedTodos.map((todo) =>
                        buildTodoCard(todo, state.todos.indexOf(todo))),
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

  

  Widget buildTodoCard(Todo todo, int originalIndex) {
    final isCompleted = todo.isDone;

    final backgroundColor = isCompleted
        ? Colors.grey[300]
        : todo.priority == 'high'
        ? Colors.red[200]
        : todo.priority == 'medium'
        ? Colors.orange[200]
        : Colors.white;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
        color: backgroundColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Slidable(
          key: ValueKey(todo.title),
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => removeTodo(todo),
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0), // Add padding for visual spacing
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailsPage(taskIndex: originalIndex),
                  ),
                );
              },
              title: Text(
                todo.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.subtitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Deadline: ${todo.deadline}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Remind: ${todo.remind}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created: ${todo.date}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              trailing: Checkbox(
                value: todo.isDone,
                activeColor: Theme.of(context).colorScheme.secondary,
                onChanged: (value) => alertTodo(originalIndex),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
