import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/custom_app_bar.dart';
import 'package:flutter_application_1/data/todo.dart';
import 'package:flutter_application_1/todo_bloc/todo_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  addTodo(Todo todo) {
    context.read<TodoBloc>().add(
      AddTodo(todo),
    );
  }

  removeTodo(Todo todo) {
    context.read<TodoBloc>().add(
      RemoveTodo(todo),
    );
  }

  alertTodo(int index) {
    context.read<TodoBloc>().add(
      AlterTodo(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController controller1 = TextEditingController();
              TextEditingController controller2 = TextEditingController();
              String selectedPriority = 'low';

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Add a Task'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: controller1,
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
                          controller: controller2,
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          decoration: InputDecoration(
                            hintText: 'Task Description...',
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
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextButton(
                          onPressed: () {
                            if (controller1.text.trim().isEmpty || controller2.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please fill in all fields')),
                              );
                              return;
                            }
                            addTodo(
                              Todo(
                                title: controller1.text.trim(),
                                subtitle: controller2.text.trim(),
                                priority: selectedPriority,
                                date: DateTime.now().toString(),
                              ),
                            );
                            controller1.text = '';
                            controller2.text = '';
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

        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(300),
        child: CustomAppBar(
          title: 'Today',
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...todos.map((todo) => buildTodoCard(todo, state.todos.indexOf(todo))),
                  ],
                  if (completedTodos.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Completed Tasks',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...completedTodos.map((todo) => buildTodoCard(todo, state.todos.indexOf(todo))),
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
    // Adjust colors based on priority and completion status
    final isCompleted = todo.isDone;

    final backgroundColor = isCompleted
        ? Colors.grey[300]
        : todo.priority == 'high'
        ? Colors.red[200]
        : todo.priority == 'medium'
        ? Colors.orange[200]
        : Colors.white;


    final textColor = Colors.black; // Ensuring consistent text visibility

    return Card(
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
        child: ListTile(
          title: Text(
            todo.title,
            style: TextStyle(
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
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Created: ${todo.date}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700], // Dimmer text for the date
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
    );
  }



}
