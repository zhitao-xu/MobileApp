import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/navigator_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../todo_bloc/todo_bloc.dart';
import '../data/todo.dart';
import 'subtask_details.dart';
import 'edit_task_page.dart';


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
              title: task.title,
              widget: IconButton(
                icon: const Icon(Icons.edit_note),
                color: black,
                iconSize: 30,
                onPressed: () { // Navigate to edit task page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTaskPage(taskIndex: taskIndex)
                      ),
                  );
                },
              ),
            ),
          ),
          body: Container(
            color: white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Details Section
                  const SizedBox(height: 8),
                  Text(
                    task.subtitle,
                    style: const TextStyle(
                      color: black,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Priority section
                  if (task.priority.isNotEmpty) _buildInfoRow('Priority', task.priority),
                  
                  // Deadline section
                  if (task.deadline.isNotEmpty) _buildInfoRow('Deadline', task.deadline),
                  
                  // Remind section
                  if (task.remind.isNotEmpty) _buildInfoRow('Remind', task.remind),
                  
                  const SizedBox(height: 24),
            
                  // Subtasks Section
                  const Text(
                    'Subtasks',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                                  const SnackBar(
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
                          subtitle: subTask.subtitle.isNotEmpty 
                            ? Text(subTask.subtitle) 
                            : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () {
                              // Navigate to edit subtask page
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => SubtaskDetailsPage(
                                    taskIndex: taskIndex,
                                    subtaskIndex: index,
                                  )
                                )
                              );
                            },
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSubTaskDialog(BuildContext context) {
    final subTaskController = TextEditingController();
    final subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add Subtask'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subTaskController,
                decoration: const InputDecoration(hintText: 'Enter subtask title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(hintText: 'Enter subtask description (optional)'),
              ),
            ],
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
                      SubTask(
                        title: subTaskController.text,
                        subtitle: subtitleController.text,
                      ),
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