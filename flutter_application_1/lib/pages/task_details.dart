import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/data/tag.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/navigator_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../todo_bloc/todo_bloc.dart';
import '../data/todo.dart';
import '../constants/tasks_constants.dart';


class TaskDetailsPage extends StatefulWidget {
  final int? taskIndex;

  const TaskDetailsPage({super.key, this.taskIndex});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {

  late TextEditingController _titleController;
  late TextEditingController _subtitleController;

  DateTime selectedDeadline = DateTime.now().add(const Duration(hours:2));
  late TextEditingController _deadlineDateController;
  late TextEditingController _deadlineTimeController;
  bool _isDatePicked = false;
  bool _isTimePicked = false;
  
  String selectedPriority = tasksPriority[0];
  late TextEditingController _priorityController;

  String selectedReminder = tasksReminder[0];
  late TextEditingController _remindController;
  String selectedRepeat = tasksRepeat[0];
  late TextEditingController _repeatController;


  late TextEditingController tagsController;
  late Todo _currentTodo;

  // Global Keys
  final GlobalKey _priorityKey = GlobalKey();
  final GlobalKey _reminderKey = GlobalKey();
  final GlobalKey _repeatKey = GlobalKey();
  List<String> selectedTags = [];
  

  @override
  void initState() {
    super.initState();
    if(widget.taskIndex != null){
      _currentTodo = context.read<TodoBloc>().state.todos[widget.taskIndex!];
    } else {
      _currentTodo = Todo(
        title: '', 
        subtitle: '', 
        isDone: false, 
        priority: 'None', 
        deadline: ['', ''], 
        remind: tasksReminder[0], 
        repeat: tasksRepeat[0],
        tags: [],
      );
    }
    
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
    tagsController = TextEditingController(text: _currentTodo.tags.join(', '));
    
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
    tagsController.dispose();
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
      final formattedDate = 
        "${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}";
      setState(() {
        _deadlineDateController.text = formattedDate;
        _isDatePicked = true;
      });
    }else{
      setState(
        () {
          _isDatePicked = false;
          _deadlineDateController.clear();
        },
      );
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
    }else{
      setState(() {
        _isTimePicked = false;
        _deadlineTimeController.clear();
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

  Future<void> _handleBackNavigation() async{
    // New tasks 
    if(widget.taskIndex == null){
      final hasContent = _titleController.text.isNotEmpty ||
        _subtitleController.text.isNotEmpty ||
        _priorityController.text != tasksPriority[0] ||
        _isDatePicked ||
        _isTimePicked ||
        _remindController.text != tasksReminder[0] ||
        _repeatController.text != tasksRepeat[0];

      if (!hasContent) {
        Navigator.of(context).pop();
        return;
      }
    } else {
      // Existing tasks
      final hasChanges = _titleController.text != _currentTodo.title ||
        _subtitleController.text != _currentTodo.subtitle ||
        _priorityController.text != _currentTodo.priority ||
        _deadlineDateController.text != _currentTodo.deadline[0] ||
        _deadlineTimeController.text != _currentTodo.deadline[1] ||
        _remindController.text != _currentTodo.remind ||
        _repeatController.text != _currentTodo.repeat;

      if (!hasChanges) {
        Navigator.of(context).pop();
        return;
      }
    }

    final navigator = Navigator.of(context);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Unsaved Changes"),
          content: const Text("You have unsaved changes. Do you want to save them before leaving?"),
          actions: [
            TextButton(
              child: const Text("Discard"),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true from dialog
              },
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false from dialog
                _saveTask(); // This will also pop
              },
            ),
          ],
        );
      },
    );

    // If result is true, user chose to discard changes
    if (result == true) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: lightBlue, 
  ));
  
  return PopScope<dynamic>(
    canPop: false,
    onPopInvokedWithResult: (didPop, dynamic result ) async {
      if (didPop) return;
      await _handleBackNavigation();
    },
    child: Scaffold(
      backgroundColor: lightBlue,
      // Rest of your scaffold remains the same...
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(300),
          child: NavigatorAppBar(
            onBackTap: _handleBackNavigation,
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
                          title: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: _isDatePicked 
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Date", style: taskTitleStyle),
                                      if(_isDatePicked) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          _deadlineDateController.text,
                                          style: taskInfoStyle.copyWith(
                                            color: blue,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ) 
                                : Text("Date", style: taskTitleStyle)
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: _isTimePicked
                                ?  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Time", style: taskTitleStyle),
                                      if(_isDatePicked) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          _deadlineTimeController.text,
                                          style: taskInfoStyle.copyWith(
                                            color: blue,
                                          ),
                                        ),
                                      ],
                                    ],
                                  )
                                : Text("Time", style: taskTitleStyle),
                            ),
                          ],
                          info: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Switch(
                                value: _isDatePicked,
                                // activeColor: green,
                                // inactiveThumbColor: grey,
                                onChanged: (value) async {
                                  if (value) {
                                    await _pickDate(context);
                                  }else{
                                    setState(() {
                                      _isDatePicked = false;
                                      _isTimePicked = false;
                                      _deadlineDateController.clear();
                                      _deadlineTimeController.clear();
                                    });
                                  }
                                  
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Switch(
                                value: _isTimePicked,
                                onChanged: _isDatePicked
                                  ? (value) async{
                                      if(value) {
                                        await _pickTime(context);
                                      }else{
                                        setState(() {
                                          _isTimePicked = false;
                                          _deadlineTimeController.clear();
                                        });
                                      }
                                    }
                                  : null,
                              ),
                            ),
                          ],
                          onTap: [
                            () => _isDatePicked ? _pickDate(context) : null,
                            () => _isTimePicked ? _pickTime(context) : null,
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
                            key: _priorityKey,
                            text: _priorityController.text,
                            icon: Icon(
                              CupertinoIcons.chevron_up_chevron_down,
                              size: 20,
                            ),
                          ),
                          onTap: (){ 
                            final RenderBox buttonBox = _priorityKey.currentContext!.findRenderObject() as RenderBox;
                            _showPopupOptions(
                              context: context, 
                              options: tasksPriority,
                              buttonBox: buttonBox,
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
                            _iconSetUp(
                              icon: Icon(CupertinoIcons.repeat),
                              backgroundColor: grey,
                            ),
                          ], 
                          title: [
                            Text("Remind", style: taskTitleStyle,),
                            Text("Repeat",style: taskTitleStyle,),
                          ], 
                          info: [
                            _infoSetUp(
                              key: _reminderKey,
                              text: _remindController.text,
                              icon: Icon(
                                CupertinoIcons.chevron_up_chevron_down,
                                size: 20,
                              ),
                            ),
                            _infoSetUp(
                              key: _repeatKey,
                              text: _repeatController.text, 
                              icon: Icon(
                                CupertinoIcons.chevron_up_chevron_down,
                                size: 20,
                              ),
                            ),
                          ],
                          onTap: [
                            (){ 
                              final RenderBox buttonBox = _reminderKey.currentContext!.findRenderObject() as RenderBox;
                              _showPopupOptions(
                                context: context, 
                                options: tasksReminder,
                                buttonBox: buttonBox,
                              ); 
                            },
                            (){ 
                              final RenderBox buttonBox = _repeatKey.currentContext!.findRenderObject() as RenderBox;
                              _showPopupOptions(
                                context: context, 
                                options: tasksRepeat,
                                buttonBox: buttonBox,
                              ); 
                            },
                          ],
                        ),
                      
                        // TAGS SECTION
                        _buildSingleContainer(
                          icon: _iconSetUp(icon: Icon(CupertinoIcons.number,), backgroundColor: greyDark), 
                          title: "Tags", 
                          info: _infoSetUp(
                            icon: Icon(CupertinoIcons.chevron_right,),
                          ),
                          onTap: () =>  _tagPicker(context, tagsController, _currentTodo.tags),
                        ),

                        // TODO: SUBTASKS SECTION

                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        )
      ),
    );
  }

  // Method to save the task
  void _saveTask() async{
    if (_titleController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Missing Title"),
            content: const Text("Please enter a title for the task before saving."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    final updatedTodo = _currentTodo.copyWith(
      title: _titleController.text,
      subtitle: _subtitleController.text,
      priority: _priorityController.text,
      deadline: [_deadlineDateController.text, _deadlineTimeController.text],
      remind: _remindController.text,
      repeat: _repeatController.text,
    );
    
    if(widget.taskIndex != null){
      context.read<TodoBloc>().add(UpdateTodo(widget.taskIndex!, updatedTodo));
    }else{
      context.read<TodoBloc>().add(AddTodo(updatedTodo));
    }
    
    // Navigate back
    Navigator.pop(context);
  }

  // Method to show pop up options
  void _showPopupOptions({
    required BuildContext context,
    required List<String> options,
    required RenderBox buttonBox,

  }){
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final buttonPosition = buttonBox.localToGlobal(Offset.zero, ancestor: overlay);

    final Size screenSize = overlay.size;
    const double verticalOffset = 5.0;

    final double estimatePopupHeight = (44.0 * options.length) + 16.0;

    final double bottomSpace = screenSize.height - (buttonPosition.dy + buttonBox.size.height);
    final bool showBelow = bottomSpace >= estimatePopupHeight;

    final RelativeRect position;

    if(showBelow){
      // show below the button
      position = RelativeRect.fromRect(
        Rect.fromPoints(
          buttonPosition + Offset(0, buttonBox.size.height + verticalOffset), 
          buttonPosition + Offset(buttonBox.size.width, buttonBox.size.height + verticalOffset)
        ),
        Offset.zero & overlay.size,
      );
    } else {
      // show above the button
      position = RelativeRect.fromRect(
        Rect.fromPoints(
          buttonPosition - Offset(0, verticalOffset), 
          buttonPosition + Offset(buttonBox.size.width, 0)
        ),
        Offset.zero & overlay.size,
      );
    }


    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 8.0,
      color: white,
      items:options.map((option) => _buildPopupMenuItem(
        value: option,
        selectedValue: _getSelectedValueForOption(options),
      )).toList(),
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

  String _getSelectedValueForOption(List<String> options) {
      if (options == tasksPriority) {
      return selectedPriority;
    } else if (options == tasksRepeat) {
      return selectedRepeat;
    } else if (options == tasksReminder) {
      return selectedReminder;
    }
    return '';
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required String selectedValue,
  }) {
    bool isSelected = value == selectedValue;

    return PopupMenuItem<String>(
      value: value,
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
              Text(value),
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
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 10.0, 10.0),
                child: icon,
              ),
              Text(
                title,
                style: taskTitleStyle,
              ),
              const Spacer(),
              info,
            ],
          ),
        )
    ),
  );
}

Widget _infoSetUp({
  Key? key,
  String? text,
  required Icon icon,
}) {
  return Container(
    key: key,
    padding: const EdgeInsets.all(6.0),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          if (text != null && text.isNotEmpty)
            Row(
              children: [
                Text(
                  text,
                  style: taskInfoStyle,
                ),
                const SizedBox(width: 5),
              ],
            ),
          Transform.scale(scaleY: 1.0, scaleX: 0.8, child: icon),
        ],
      ),
    ),
  );
}


// Multiple Containers
Widget _buildMultipleContainer({
  required BuildContext context,
  required List<Widget> icons,
  required List<Widget> title,
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
  List<Widget> title,
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
              padding: const EdgeInsets.fromLTRB(16.0, 10.0, 10.0, 10.0),
              child: icons[i],
            ),
            title[i],
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

void _tagPicker(BuildContext context, TextEditingController tagsController, List<String> selectedTags) {
  TextEditingController newTagController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Title with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Tags',
                    style: homeTitleStyle.copyWith(color: black),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(CupertinoIcons.xmark),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              // Divider
              Container(
                height: 1,
                color: grey,
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),

              // Tags list section
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: TagStorage.loadTags(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final tags = snapshot.data ?? [];
                    
                    if (tags.isEmpty) {
                      return Center(
                        child: Text(
                          'No tags available',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: greyDark,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((tag) {
                          final isSelected = selectedTags.contains(tag);
                          
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                if (isSelected) {
                                  selectedTags.remove(tag);
                                } else {
                                  selectedTags.add(tag);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? bgBlue : white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? blue : grey,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tag,
                                    style: TextStyle(
                                      color: isSelected ? blue : black,
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: blue,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Divider
              Container(
                height: 1,
                color: grey,
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
              
              // Add new tag section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add New Tag',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newTagController,
                          decoration: InputDecoration(
                            hintText: 'Enter tag name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (value) async {
                            if (value.trim().isNotEmpty) {
                              await _addNewTag(value.trim());
                              newTagController.clear();
                              setDialogState(() {}); // Refresh the dialog
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final tagName = newTagController.text.trim();
                          if (tagName.isNotEmpty) {
                            await _addNewTag(tagName);
                            newTagController.clear();
                            setDialogState(() {}); // Refresh the dialog
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Update the tags field with selected tags
                        tagsController.text = selectedTags.join(', ');
                        Navigator.pop(context);
                        _updateCurrentTaskTags(selectedTags);
                      },
                      child: const Text('Save'),
                    ),
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

Future<void> _addNewTag(String tagName) async {
  await TagStorage.addTags([tagName]);
}

// Add this function to update the current task's tags
void _updateCurrentTaskTags(List<String> selectedTags) async{
  // You'll need to implement this based on your task management structure
  // For example, if you have a current task object:
  await TagStorage.addTags(selectedTags);

  print('Updated task tags: $selectedTags');
}
