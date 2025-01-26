import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/navigator_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../todo_bloc/todo_bloc.dart';
import '../data/todo.dart';


class TaskDetailsPage extends StatelessWidget {
  final int taskIndex;

  const TaskDetailsPage({super.key, required this.taskIndex});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        final task = state.todos[taskIndex];

        return Scaffold(
          backgroundColor: lightBlue,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(300),
            child: NavigatorAppBar(
              title: task.title
            ),
          ),
          body: Container(
            color: white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Details Section
                  Text(
                    'Details',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.subtitle,
                    style: const TextStyle(
                      color: black,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
            
                  // Subtasks Section
                  Text(
                    'Subtasks',
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: task.subtasks.length,
                      itemBuilder: (context, index) {
                        final subTask = task.subtasks[index];
                        return ListTile(
                          leading: Checkbox(
                            value: subTask.isDone,
                            onChanged: (value) {
                              if (index == 0 || task.subtasks[index - 1].isDone) {
                                context.read<TodoBloc>().add(
                                  CompleteSubTask(taskIndex, index),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Complete the previous subtasks first.'),
                                  ),
                                );
                              }
                            },
                          ),
                          title: Text(
                            subTask.title,
                            style: TextStyle(
                              decoration: subTask.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            
                  // Add Subtask Button
                  ElevatedButton(
                    onPressed: () {
                      _showAddSubTaskDialog(context);
                    },
                    child: const Text('Add Subtask'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddSubTaskDialog(BuildContext context) {
    final subTaskController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add Subtask'),
          content: TextField(
            controller: subTaskController,
            decoration: const InputDecoration(hintText: 'Enter subtask title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (subTaskController.text.isNotEmpty) {
                  context.read<TodoBloc>().add(
                    AddSubTask(
                      taskIndex,
                      SubTask(title: subTaskController.text),
                    ),
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
