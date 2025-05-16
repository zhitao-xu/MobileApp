import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/navigator_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../todo_bloc/todo_bloc.dart';
import '../data/todo.dart';


class TaskDetailsPage extends StatefulWidget {
  final int taskIndex;

  const TaskDetailsPage({super.key, required this.taskIndex});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  DateTime selectedDeadline = DateTime.now().add(const Duration(hours:2));
  
  // bool hasDeadline = false;
  String selectedPriority = "None";
  String selectedReminder = "None";

  late TextEditingController _priorityController;
  late TextEditingController _deadlineDateController;
  late TextEditingController _deadlineTimeController;
  late TextEditingController _dateController;
  late TextEditingController _remindController;
  late Todo _currentTodo;

  // Track if date and time are picked for UI display
  bool _isDatePicked = false;
  bool _isTimePicked = false;

  @override
  void initState() {
    super.initState();
    _currentTodo = context.read<TodoBloc>().state.todos[widget.taskIndex];
    
    _titleController = TextEditingController(text: _currentTodo.title);
    _subtitleController = TextEditingController(text: _currentTodo.subtitle);
    _priorityController = TextEditingController(text: _currentTodo.priority);
    
    // Parse date and time if they're combined in the date field
    String dateText = _currentTodo.date;
    String timeText = "";
    
    // Check if the date field contains time information (looking for space followed by digits and colon)
    if (dateText.contains(RegExp(r'\s\d+:'))) {
      // Split date and time
      final parts = dateText.split(RegExp(r'\s(?=\d+:)'));
      if (parts.length > 1) {
        dateText = parts[0].trim();
        timeText = parts[1].trim();
      }
    }
    
    _dateController = TextEditingController(text: dateText);
    _deadlineDateController = TextEditingController(text: _currentTodo.deadline[0]);
    _deadlineTimeController = TextEditingController(text: _currentTodo.deadline[1]);
    _remindController = TextEditingController(text: _currentTodo.remind);
    
    // Initialize picked states based on parsed data
    _isDatePicked = dateText.isNotEmpty;
    _isTimePicked = timeText.isNotEmpty;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _priorityController.dispose();
    _deadlineDateController.dispose();
    _remindController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Method to handle date picking
  Future<void> _pickDate(BuildContext context) async {
    final selectedDate = await showDatePicker(  
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 100),
    );

    if (selectedDate != null) {
      // Format date as day-month-year
      final formattedDate = "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
      setState(() {
        _deadlineDateController.text = formattedDate;
        _isDatePicked = true;
      });
    }
  }

  // Method to handle time picking
  Future<void> _pickTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _parseTimeOfDay(_deadlineTimeController.text) ?? TimeOfDay.now(),
    );

    if (selectedTime != null) {
      // Ensure minutes are formatted with leading zero if needed
      final minutes = selectedTime.minute < 10 ? "0${selectedTime.minute}" : "${selectedTime.minute}";
      // Format time as hour:minutes
      final formattedTime = "${selectedTime.hour}:$minutes";
      setState(() {
        _deadlineTimeController.text = formattedTime;
        _isTimePicked = true;
      });
    }
  }
  
  // Helper method to parse a time string into TimeOfDay
  TimeOfDay? _parseTimeOfDay(String timeString) {
    if (timeString.isEmpty) return null;
    
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      // Parsing failed, return null
    }
    return null;
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
                      _buildDateTimeBox(context),
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

  // New method to build the date and time box
  Widget _buildDateTimeBox(BuildContext context) {
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
          children: [
            // Date row
            InkWell(
              onTap: () => _pickDate(context),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: _iconSetUp(
                      icon: const Icon(CupertinoIcons.calendar),
                      backgroundColor: red,
                    ),
                  ),
                  Text(
                    "Date", 
                    style: TextStyle(
                      color: black,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: _isDatePicked 
                      ? Text(
                          _deadlineDateController.text,
                          style: const TextStyle(
                            color: black,
                            fontSize: 16,
                          ),
                        )
                      : const SizedBox(),
                  )
                ],
              ),
            ),
            
            const Divider(
              height: 1,
              thickness: 0.25,
              color: Colors.grey,
              indent: 10,
              endIndent: 10,
            ),
            
            // Time row
            InkWell(
              onTap: () => _pickTime(context),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: _iconSetUp(
                      icon: const Icon(CupertinoIcons.time_solid),
                      backgroundColor: blue,
                    ),
                  ),
                  Text(
                    "Time", 
                    style: TextStyle(
                      color: black,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: _isTimePicked 
                      ? Text(
                          _deadlineTimeController.text,
                          style: const TextStyle(
                            color: black,
                            fontSize: 16,
                          ),
                        )
                      : const SizedBox(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

void _saveTask() {
  // Create a map of updated values
  final updatedTodo = _currentTodo.copyWith(
    title: _titleController.text,
    subtitle: _subtitleController.text,
    priority: _priorityController.text,
    date: _dateController.text,
    deadline: [_deadlineDateController.text, _deadlineTimeController.text],
    remind: _remindController.text,
  );
  
  context.read<TodoBloc>().add(UpdateTodo(widget.taskIndex, updatedTodo));
  
  // Navigate back
  Navigator.pop(context);
}
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
          } else {
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