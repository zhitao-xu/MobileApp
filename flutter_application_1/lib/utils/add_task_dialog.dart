import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/todo.dart';
import 'package:flutter_application_1/todo_bloc/todo_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

Future<dynamic> addTaskDialog(BuildContext context) {
  addTodo(Todo todo) {
    context.read<TodoBloc>().add(AddTodo(todo));
  }

    return showDialog(
    context: context,
    builder: (context) {
      TextEditingController titleController = TextEditingController();
      TextEditingController descriptionController = TextEditingController();
      String selectedPriority = 'none';
      String selectedReminder = '5 minutes before';
      DateTime selectedDeadline = DateTime.now().add(const Duration(hours: 2)); // Default to today

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add a Task'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    decoration: InputDecoration(
                      hintText: 'Task Title...',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    decoration: InputDecoration(
                      hintText: 'Task Description (optional)...',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    maxLines: null, // Allow multi-line input
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );

                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (time != null) {
                                setState(() {
                                  selectedDeadline = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                          child: Text(DateFormat('yyyy-MM-dd HH:mm')
                              .format(selectedDeadline)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    onChanged: (value) {
                      setState(() {
                        selectedPriority = value!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'high',
                        child: Text('High Priority'),
                      ),
                      DropdownMenuItem(
                        value: 'medium',
                        child: Text('Medium Priority'),
                      ),
                      DropdownMenuItem(
                        value: 'low',
                        child: Text('Low Priority'),
                      ),
                      DropdownMenuItem(
                        value: 'none',
                        child: Text('None Priority'),
                      ),
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedReminder,
                    onChanged: (value) {
                      setState(() {
                        selectedReminder = value!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'no reminder',
                        child: Text('no reminder'),
                      ),
                      DropdownMenuItem(
                        value: '5 minutes before',
                        child: Text('5 minutes before'),
                      ),
                      DropdownMenuItem(
                        value: '30 minutes before',
                        child: Text('30 minutes before'),
                      ),
                      DropdownMenuItem(
                        value: '1 hour before',
                        child: Text('1 hour before'),
                      ),
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in the title')),
                      );
                      return;
                    }
                    addTodo(
                      Todo(
                        title: titleController.text.trim(),
                        subtitle: descriptionController.text.trim(),
                        priority: selectedPriority,
                        deadline: [
                          DateFormat('yyyy-MM-dd').format(selectedDeadline),
                          DateFormat('HH:mm').format(selectedDeadline)
                        ],
                        remind: selectedReminder,
                        date: DateTime.now().toString(),
                      ),
                    );
                    titleController.text = '';
                    descriptionController.text = '';
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}