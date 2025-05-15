import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/navigator_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../todo_bloc/todo_bloc.dart';
import '../data/todo.dart';
import 'subtask_details.dart';
import 'edit_task_page.dart';


class TaskDetailsPage extends StatefulWidget {
  final int taskIndex;

  const TaskDetailsPage({super.key, required this.taskIndex});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _priorityController;
  late TextEditingController _deadlineController;
  late TextEditingController _dateController;
  late TextEditingController _remindController;
  late Todo _currentTodo;



  @override
  void initState() {
    super.initState();
    _currentTodo = context.read<TodoBloc>().state.todos[widget.taskIndex];
    
      _titleController = TextEditingController(text: _currentTodo.title);
      _subtitleController = TextEditingController(text: _currentTodo.subtitle);
      _priorityController = TextEditingController(text: _currentTodo.priority);
      _deadlineController = TextEditingController(text: _currentTodo.deadline);
      _remindController = TextEditingController(text: _currentTodo.remind);
      _dateController = TextEditingController(text: _currentTodo.date);

  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _priorityController.dispose();
    _deadlineController.dispose();
    _remindController.dispose();
    _dateController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: lightBlue, 
    ));
    
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: PreferredSize(
            preferredSize: const Size.fromHeight(300),
            child: NavigatorAppBar(
              title: "",
              widget: Row(
                children: [
                  TextButton(
                    onPressed: _saveTask,
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        color: black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state){
          if (state.status == TodoStatus.loading) {
              return const Center(child: CircularProgressIndicator());
          }

          return Container(
            color: backgoundGrey,
            child: SizedBox.expand(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      // TITLE SECTION
                      _buildTextField(
                        controllers: [_titleController, _subtitleController], 
                        hints: ["Title", "Description"]
                      ),
                                
                      // DATE SECTION
                      Column(
                        children: [
                          // Date, Time Box
                          _buildOptionsBox(
                            icons: [
                              _iconSetUp(
                                icon: const Icon(
                                  CupertinoIcons.calendar,
                                ), 
                                backgroundColor: red),
                              _iconSetUp(
                                icon: const Icon(
                                  CupertinoIcons.time_solid,
                                ),
                                backgroundColor: blue,
                              ),
                            ],
                            bodyTexts: [
                              _bodyTextSetUp("Date"),
                              _bodyTextSetUp("Time"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      )
    );
  }

  void _saveTask() {
  final updatedTodo = _currentTodo.copyWith(
      title: _titleController.text,
      subtitle: _subtitleController.text,
      priority: _priorityController.text,
      date: _dateController.text,
      deadline: _deadlineController.text,
      remind: _remindController.text,
    );
    
    context.read<TodoBloc>().add(UpdateTodo(widget.taskIndex, updatedTodo));
    
    
    // Navigate back
    Navigator.pop(context);
}
}

Widget _bodyTextSetUp(String text){
  return Text(
    text,
    style: TextStyle(
      color: black,
      fontSize: 16,
    ),
  );
}

Widget _iconSetUp({
  required Icon icon,
  required Color backgroundColor,
}){
  return Container(
    padding: const EdgeInsets.all(6.0),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(6.0),
    ),
    child: Icon(
      icon.icon,
      color: white,
    ),
  );
}


Widget _buildTextField({
    required List<TextEditingController> controllers,
    required List<String> hints,
  }) {
  assert(controllers.length == hints.length);
  
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
    child: Container(
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: white,
        border: Border.all(color: white),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(controllers.length*2-1, (i) {
          if (i.isOdd) {
            return const Divider(
              height: 1,
              thickness: 0.25,
              color: Colors.grey,
              indent: 10,
              endIndent: 10,
            );
          }else{
            final index = i ~/ 2;
          
            return TextField(
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              controller: controllers[index],
              decoration: InputDecoration(
                hintText: hints[index],
                hintStyle: TextStyle(
                  color: grey,
                  fontStyle: FontStyle.italic,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
            );
          }
        }),
      ),
    ),
  );
}

Widget _buildOptionsBox({
  required List<Widget?> icons,
  required List<Widget?> bodyTexts,
}) {
  // Ensure lists have the same length
  assert(icons.length == bodyTexts.length, 'Icons and bodyTexts lists must have the same length');
  
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
    child: Container(
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _buildOptionBoxChildren(icons, bodyTexts),
      ),
    ),
  );
}

List<Widget> _buildOptionBoxChildren(List<Widget?> icons, List<Widget?> bodyTexts) {
  final List<Widget> children = [];
  
  for (int i = 0; i < icons.length; i++) {
    children.add(
      Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            child: icons[i] ?? const SizedBox(),
          ),
          Container(
            child: bodyTexts[i] ?? const SizedBox(),
          ),
        ],
      ),
    );
    
    // Add a divider if this is not the last item
    if (i < icons.length - 1 && icons.length > 1) {
      children.add(
        const Divider(
          height: 1,
          thickness: 0.25,
          color: Colors.grey,
          indent: 10,
          endIndent: 10,
        ),
      );
    }
  }
  
  return children;
}




/* 

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
 */
  /* void _showAddSubTaskDialog(BuildContext context) {
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
  } */
