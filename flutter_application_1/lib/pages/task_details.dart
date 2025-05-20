import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/navigator_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../todo_bloc/todo_bloc.dart';
import '../data/todo.dart';
import '../constants/tasks_constants.dart';


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
  String selectedRepeat = "None";

  late TextEditingController _priorityController;
  late TextEditingController _deadlineDateController;
  late TextEditingController _deadlineTimeController;
  late TextEditingController _remindController;
  late TextEditingController _repeatController;
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
    
    selectedPriority = _priorityController.text;
    String dateText = _currentTodo.deadline[0];
    String timeText = _currentTodo.deadline[1];
    
    // Check if the date field contains time information (looking for space followed by digits and colon)
    if (dateText.contains(RegExp(r'\s\d+:'))) {
      // Split date and time
      final parts = dateText.split(RegExp(r'\s(?=\d+:)'));
      if (parts.length > 1) {
        dateText = parts[0].trim();
        timeText = parts[1].trim();
      }
    }
    
    _deadlineDateController = TextEditingController(text: _currentTodo.deadline[0]);
    _deadlineTimeController = TextEditingController(text: _currentTodo.deadline[1]);
    _remindController = TextEditingController(text: _currentTodo.remind);
    _repeatController = TextEditingController(text: _currentTodo.repeat);
    
    // Initialize picked states based on parsed data
    _isDatePicked = dateText.isNotEmpty;
    _isTimePicked = timeText.isNotEmpty;
    selectedReminder = _remindController.text;
    selectedRepeat = _repeatController.text;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _priorityController.dispose();
    _deadlineDateController.dispose();
    _deadlineTimeController.dispose();
    _remindController.dispose();
    _repeatController.dispose();
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
      final minutes = selectedTime.minute.toString().padLeft(2, '0');
      final hours = selectedTime.hour.toString().padLeft(2, '0');
      // Format time as hour:minutes
      final formattedTime = "$hours:$minutes";
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
                      _buildMultipleContainer(
                        context: context,
                        icons: [
                          _iconSetUp(
                            icon: Icon(CupertinoIcons.calendar,),
                            backgroundColor: red,
                          ),
                          _iconSetUp(
                            icon: Icon(CupertinoIcons.clock,),
                            backgroundColor: blue,
                          ),
                        ],
                        title: ["Date", "Time"],
                        info: [
                          _isDatePicked
                            ? _textContainer(text: _deadlineDateController.text)
                            : const SizedBox(),
                          _isTimePicked
                            ? _textContainer(text: _deadlineTimeController.text)
                            : const SizedBox(),
                        ],
                        onTap: [
                          () => _pickDate(context),
                          () => _pickTime(context),
                        ],
                      ),

                      
                      // PRIORITY SECTION
                      _buildSingleContainer(
                        icon: _iconSetUp(
                          icon: Icon(
                            CupertinoIcons.exclamationmark,
                            size: 28
                          ),
                          backgroundColor: red,
                        ),
                        title: "Priority",
                        info: _infoSetUp(
                          text: _priorityController.text,
                          icon: Icon(
                            CupertinoIcons.chevron_up_chevron_down,
                            size: 20,
                          ),
                        ),
                        onTap: (){ 
                          _showPopupOptions(
                            context: context, 
                            options: tasksPriority,
                          ); 
                        },
                      ),

                      // REMIND & REPEAT SECTION
                      _buildMultipleContainer(
                        context: context, 
                        icons: [
                          _iconSetUp(
                            icon: Icon(CupertinoIcons.bell),
                            backgroundColor: purple,
                          ),
                          // _iconSetUp(
                          //   icon: Icon(CupertinoIcons.repeat),
                          //   backgroundColor: grey,
                          // ),
                        ], 
                        title: ["Remind"], 
                        info: [
                          _infoSetUp(
                            text: _remindController.text,
                            icon: Icon(
                              CupertinoIcons.chevron_up_chevron_down,
                              size: 20,
                            ),
                          ),
                          // _infoSetUp(
                          //   text: _currentTodo.repeat, 
                          //   icon: Icon(
                          //     CupertinoIcons.chevron_up_chevron_down,
                          //     size: 20,
                          //   ),
                          // ),
                        ],
                        onTap: [
                          (){ _showPopupOptions(
                            context: context, 
                            options: tasksReminder
                            ); 
                          },
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

  // Method to save the task
  void _saveTask() {
    final updatedTodo = _currentTodo.copyWith(
      title: _titleController.text,
      subtitle: _subtitleController.text,
      priority: _priorityController.text,
      deadline: [_deadlineDateController.text, _deadlineTimeController.text],
      remind: _remindController.text,
      repeat: _repeatController.text,
    );
    
    context.read<TodoBloc>().add(UpdateTodo(widget.taskIndex, updatedTodo));
    
    // Navigate back
    Navigator.pop(context);
  }

  // Method to show pop up options
  void _showPopupOptions({
    required BuildContext context,
    required List<String> options,

  }){
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);

    // Calculate the position for the popup menu
    // Position it right-aligned with the priority field and below it
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonPosition + Offset(button.size.width - 150, 100), 
        buttonPosition + Offset(button.size.width, 100)
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 8.0,
      color: white,
      items:options.map((option) => _buildPopupMenuItem(option)).toList(),
    ).then((selectedValue){
      if(selectedValue != null){
        setState(() {
          if(options == tasksPriority){
            selectedPriority = selectedValue;
            _priorityController.text = selectedValue;
          } else if (options == tasksRepeat) {
            selectedRepeat = selectedValue;
            _repeatController.text = selectedValue;
          } else if (options == tasksReminder) {
            selectedReminder = selectedValue;
            _remindController.text = selectedValue;
          }
        });
      }
    });
  }

  PopupMenuItem<String> _buildPopupMenuItem(String priority) {
    bool isSelected = selectedPriority == priority;

    return PopupMenuItem<String>(
      value: priority,
      height: 44.0,
      padding: EdgeInsets.zero,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            isSelected
              ? Icon(CupertinoIcons.checkmark_alt, size: 18)
              : const SizedBox(width: 18),
              SizedBox(width: 10),
              Text(priority),
          ],
        ),
      )
    );
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
            return myDivider();
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

Divider myDivider() {
  return const Divider(
    height: 1,
    thickness: 0.25,
    color: grey,
    indent: 10,
    endIndent: 10,
  );
}

// Single Container
Widget _buildSingleContainer({
  required Widget icon,
  required String title,
  required Widget  info,
  VoidCallback? onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
    child: Container(
      padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: white,
            border: Border.all(color: white),
            borderRadius: BorderRadius.circular(8.0),
          ),
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: icon,
              ),
              _textContainer(
                text: title,
                horizontalPadding: 0.0,
                verticalPadding: 0.0,
              ),
              const Spacer(),
              info,
            ],
          ),
        )
    ),
  );
}

Widget _textContainer({
  required String text,
  Color ? color,
  double ? fontSize,
  double ? horizontalPadding,
  double ? verticalPadding,
}){
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 20.0, vertical: verticalPadding ?? 20.0),
    child: Text(
      text,
      style: TextStyle(
        color: color ?? black,
        fontSize: fontSize ?? 16,
      ),
    ),
  );
}

Widget _infoSetUp({
  required String text,
  required Icon icon,
}){
  return Container(
    padding: const EdgeInsets.all(6.0),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          _textContainer(text: text, horizontalPadding: 0.0, verticalPadding: 0.0),
          const SizedBox(width: 5),
          Transform.scale(scaleY: 1.0, scaleX: 0.8, child:icon),
        ],
      ),
    ),
  );
}

// Multiple Containers
 Widget _buildMultipleContainer({
    required BuildContext context,
    required List<Widget> icons,
    required List<String> title,
    required List<Widget> info,
    required List<VoidCallback> onTap,
  }) {
    assert(icons.length == title.length && title.length == info.length && info.length == onTap.length, 'All lists must be of the same length');

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: _buildMultipleRow(icons, title, info, onTap),
        ),
      ),
    );
  }

  List<Widget> _buildMultipleRow(
    List<Widget> icons,
    List<String> title,
    List<Widget> info,
    List<VoidCallback> onTap,
  ) {
    List<Widget> rows = [];
    
    for (int i = 0; i < icons.length; i++) {
      rows.add(
        InkWell(
          onTap: onTap[i],
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: icons[i],
              ),
              _textContainer(
                text: title[i],
                horizontalPadding: 0.0,
                verticalPadding: 0.0,
              ),
              const Spacer(),
              info[i],
            ],
          ),
        ),
      );
      if (i < icons.length - 1) {
        rows.add(myDivider());
      }
    }
    return rows;
  }