import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_app/data/tag.dart';
import 'package:todo_app/utils/theme.dart';
import 'package:todo_app/utils/todo_utils.dart';
import 'package:todo_app/widget/main_wrapper.dart';
import 'package:todo_app/widget/navigator_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../todo_bloc/todo_bloc.dart';
import '../data/todo.dart';
import '../constants/tasks_constants.dart';
import '../widget/todo/todo_card.dart';
import '../widget/row_container.dart';


class TaskDetailsPage extends StatefulWidget {
  final int? taskIndex;
  final int? subTaskIndex;
  final bool isSubTask;
  final bool showParentAfterBack;
  final int? initialPage;

  const TaskDetailsPage({
    super.key, 
    this.taskIndex, 
    this.subTaskIndex, 
    this.isSubTask = false,
    this.showParentAfterBack = false,
    this.initialPage,
  });

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  // Todo Task or Subtask
  late dynamic _currentItem;
  final int _baseInitialPage = 1000;

  // PageController for the page view
  late PageController _pageController;
  int _currentPage = 0;
  final List<String> _contentType = ['Info', 'Subtasks'];

  // Controllers for the text fields
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

  // Global Keys
  final GlobalKey _priorityKey = GlobalKey();
  final GlobalKey _reminderKey = GlobalKey();
  final GlobalKey _repeatKey = GlobalKey();
  List<String> selectedTags = [];

  bool _wasAutoSaved = false;
  int? _currentTaskIndex;
  String? _autoSavedTaskId;
  bool _isAutoSaving = false;
  

  @override
  void initState() {
    super.initState();

    int calculatedInitialPage = _baseInitialPage;
    if(widget.initialPage != null){
      calculatedInitialPage = _baseInitialPage + widget.initialPage!;
    }
    _pageController = PageController(initialPage: calculatedInitialPage);
    _pageController.addListener(_onPageControllerChange);
    _currentTaskIndex = widget.taskIndex;
    _wasAutoSaved = false;
    _isAutoSaving = false;
    _autoSavedTaskId = null;

    if(widget.initialPage != null){
      _currentPage = widget.initialPage!;
    }
    

    if (widget.isSubTask) {
      if (widget.taskIndex != null && widget.subTaskIndex != null) {
        // Editing existing subtask
        _currentItem = context.read<TodoBloc>().state.todos[widget.taskIndex!].subtasks[widget.subTaskIndex!];
      } else {
        // Creating new subtask
        _currentItem = SubTask(
          title: '',
          subtitle: '',
          isDone: false,
          priority: 'None',
          deadline: null,
          remindAt: null,
          remind: tasksReminder[0],
          repeat: tasksRepeat[0],
        );
      }
    } else {
      // Handle existing Todo task
      if (widget.taskIndex != null) {
        _currentItem = context.read<TodoBloc>().state.todos[widget.taskIndex!];
      } else {
        _currentItem = Todo(
          title: '',
          subtitle: '',
          isDone: false,
          priority: 'None',
          deadline: null,
          remindAt: null,
          remind: tasksReminder[0],
          repeat: tasksRepeat[0],
          tags: [],
        );
      }
    }
    
    
    
    _titleController = TextEditingController(text: _currentItem.title);
    _subtitleController = TextEditingController(text: _currentItem.subtitle);
    _priorityController = TextEditingController(text: _currentItem.priority);
    
    selectedPriority = _priorityController.text;


    // Safely get date and time strings from DateTime? deadline
    String dateText = formatDateTimeToDateString(_currentItem.deadline);
    String timeText = formatDateTimeToTimeString(_currentItem.deadline);

    _deadlineDateController = TextEditingController(text: dateText);
    _deadlineTimeController = TextEditingController(text: timeText);

    // Safely get reminder string from String remind
    _remindController = TextEditingController(text:_currentItem.remind);
    _repeatController = TextEditingController(text: _currentItem.repeat);


    if(!widget.isSubTask){
      tagsController = TextEditingController(text: _currentItem.tags.join(', '));
    }
    // Initialize picked states based on parsed data
    _isDatePicked = dateText.isNotEmpty;
    _isTimePicked = timeText.isNotEmpty;
    // selectedReminder = _remindController.text;
    selectedRepeat = _repeatController.text;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageController.removeListener(_onPageControllerChange);

    _titleController.dispose();
    _subtitleController.dispose();
    _priorityController.dispose();
    _deadlineDateController.dispose();
    _deadlineTimeController.dispose();
    _remindController.dispose();
    _repeatController.dispose();

    if(!widget.isSubTask){
      tagsController.dispose();
    }
    
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index % _contentType.length;
    });

    if(_currentPage == 1 && widget.taskIndex == null && !widget.isSubTask && !_wasAutoSaved){
      _autoSaveDraft();
    }
  }

  void _onPageControllerChange(){
    if(_pageController.hasClients){
      final currentPageIndex = ((_pageController.page ?? _baseInitialPage) - _baseInitialPage).round();
      if(currentPageIndex != _currentPage){
        _onPageChanged(currentPageIndex);
      }
    }
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
     
    if(widget.taskIndex == null){
      // New tasks
      final hasContent = _titleController.text.isNotEmpty ||
        _subtitleController.text.isNotEmpty ||
        _priorityController.text != tasksPriority[0] ||
        _isDatePicked ||
        _isTimePicked ||
        _remindController.text != tasksReminder[0] ||
        _repeatController.text != tasksRepeat[0];

      if (!hasContent) {
        if(!widget.isSubTask){
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainWrapper(pageIndex: 0,)),
            (Route<dynamic> route) => false,
          );
        }else{
          Navigator.of(context).pop();
        }
        return;
      }
    } else {
      // existing tasks
      final hasChanges = _titleController.text != _currentItem.title ||
        _subtitleController.text != _currentItem.subtitle ||
        _priorityController.text != _currentItem.priority ||
        _deadlineDateController.text != formatDateTimeToDateString(_currentItem.deadline) ||
        _deadlineTimeController.text != formatDateTimeToTimeString(_currentItem.deadline) ||
        _remindController.text != _currentItem.remind ||
        _repeatController.text != _currentItem.repeat;

      if (!hasChanges) {
        // For subtasks with cascading navigation enabled TODO
        if(widget.isSubTask && widget.showParentAfterBack){
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => TaskDetailsPage(
                taskIndex: widget.taskIndex,
                isSubTask: false,
                showParentAfterBack: false,
                initialPage: 1,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // This will naturally feel like a back navigation
                const begin = Offset(-1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                
                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );
                
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
              reverseTransitionDuration: const Duration(milliseconds: 300),
            ),
          );
        } else {
          if(!widget.isSubTask){
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainWrapper(pageIndex: 0,)),
              (Route<dynamic> route) => false,
            );
          }else{
          Navigator.pop(context);
          }
        }
        return;
      }
    }

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
      // handle cascading navigation even when discarding changes TODO
      if(widget.isSubTask && widget.showParentAfterBack){ 
        if(!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => TaskDetailsPage(
              taskIndex: widget.taskIndex,
              isSubTask: false,
              showParentAfterBack: false,
              initialPage: 1,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // This will naturally feel like a back navigation
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              
              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );
              
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else {
        if(!mounted) return;
        if(!widget.isSubTask){
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainWrapper(pageIndex: 0,)),
            (Route<dynamic> route) => false,
          );
        }else{
          Navigator.pop(context);
        }
      }
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(300),
          child: NavigatorAppBar(
            onBackTap: _handleBackNavigation,
            title: widget.isSubTask ? "Subtask" : "Task",
            widget: Row(
              children: [
                TextButton(
                  onPressed: _saveTask,
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      color: white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        floatingActionButton: _currentPage == 1
          ? SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  TaskDetailsPage(
                        taskIndex: _currentTaskIndex,
                        isSubTask: true,
                      ),
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
              )
          )
          : null,

        body: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state){
            if (state.status == TodoStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [

                // TITLE SECTION
                Container(
                  color: backgoundGrey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: _buildTextField(
                      controllers: [_titleController, _subtitleController], 
                      hints: ["Title", "Description"]
                    ),
                  ),
                ),
                
                if(widget.isSubTask)
                  Expanded(
                    child:_buildInfoContent()
                  )
                else ...[
                  // State Header Bar
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: _contentType.asMap().entries.map((entry) {
                        int index = entry.key;
                        String title = entry.value;
                        bool isActive = index == _currentPage;

                        return Expanded(
                          child: GestureDetector(
                            onTap: (){
                              _pageController.animateToPage(
                                _pageController.page!.toInt() - _currentPage + index , 
                                duration: const Duration(milliseconds: 300), 
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: isActive ? bgBlue : white,
                              ),
                              child: Center(
                                child: Text(
                                  title,
                                  style: taskHeaderStyle.copyWith(
                                    color: isActive ? white : black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Main Content Section
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        int actualIndex = index % _contentType.length;
                        return _buildContent(actualIndex);
                      },
                    ),
                  ),
                ],
              ],
            );
          }
        )
      ),
    );
  }

    void _autoSaveDraft() async {
    // Prevent multiple simultaneous auto-saves
    if (_isAutoSaving) return;

    if(widget.taskIndex != null || _wasAutoSaved) return;
    
    // Only auto-save if there's at least a title
    if (_titleController.text.trim().isNotEmpty) {
      setState(() {
        _isAutoSaving = true;
      });

      // Show a brief loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Saving draft...'),
            ],
          ),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final draftTodo = Todo(
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text,
        isDone: false,
        priority: _priorityController.text,
        deadline: parseDateTimeFromStrings(
          _deadlineDateController.text,
          _deadlineTimeController.text,
        ),
        remindAt: null,
        remind: _remindController.text,
        repeat: _repeatController.text,
        tags: [],
      );

      _autoSavedTaskId = draftTodo.id;

      // Add the task
      context.read<TodoBloc>().add(AddTodo(draftTodo));
      
      // Wait for the bloc to process the addition
      await Future.delayed(const Duration(milliseconds: 200));
      
      if(!mounted) return;
      // Get the new task index
      final updatedState = context.read<TodoBloc>().state;
      if (updatedState.status == TodoStatus.success) {
        final newTaskIndex = updatedState.todos.indexWhere((todo) => todo.id == _autoSavedTaskId);
        
        if(newTaskIndex != -1){
          // Update our local state
          setState(() {
            _currentTaskIndex = newTaskIndex;
            _wasAutoSaved = true;
            _isAutoSaving = false;
          });
        }
        
        // Update the current item reference
        _currentItem = updatedState.todos[newTaskIndex];
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft saved! You can now add subtasks.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _isAutoSaving = false;
        });
      }
    } else {
      // Show a gentle prompt to add a title first
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a task title first'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Switch back to details page
      _pageController.animateToPage(
        _baseInitialPage, // Go back to Info page
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // // Focus on title field after animation
      // Future.delayed(const Duration(milliseconds: 400), () {
      //   FocusScope.of(context).requestFocus(_titleFocusNode);
      // });
    }
  }
  // Method to save the task
  void _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Missing Title"),
            content: !widget.isSubTask 
              ? const Text("Please enter a title for the task before saving.")
              : const Text("Please enter a title for the subtask before saving."),
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
        
    // Parse the deadline and reminder date/time BEFORE calling copyWith
    final DateTime? parsedDeadline = parseDateTimeFromStrings(
      _deadlineDateController.text,
      _deadlineTimeController.text,
    );

    if (widget.isSubTask) {
      // Subtask saving logic
      final updatedSubTask = (_currentItem as SubTask).copyWith(
        title: _titleController.text,
        subtitle: _subtitleController.text,
        priority: _priorityController.text,
        deadline: parsedDeadline,
        remindAt: parsedDeadline != null
          ? convertReminderStringToDateTime(_remindController.text, parsedDeadline)
          : null,
        remind: _remindController.text,
        repeat: _repeatController.text,
      );

      if (widget.subTaskIndex != null) {
        // Update existing subtask
        context.read<TodoBloc>().add(UpdateSubTask(
          widget.taskIndex!,
          widget.subTaskIndex!,
          updatedSubTask,
        ));
      } else {
        // Add new subtask
        final parentTaskIndex = widget.taskIndex ?? _currentTaskIndex;
        if(parentTaskIndex != null){
          context.read<TodoBloc>().add(AddSubTask(parentTaskIndex, updatedSubTask));
        }else{
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: const Text("Cannot save subtask: parent task not found."),
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
      }
    } else {
      // Todo task saving logic
      final currentState = context.read<TodoBloc>().state;
      Todo currentTaskData;

      final taskIndex = _currentTaskIndex ?? widget.taskIndex;

      if (taskIndex != null && currentState.status == TodoStatus.success) {
        currentTaskData = currentState.todos[taskIndex]; // existing or auto-saved task
      } else {
        currentTaskData = _currentItem as Todo; // completely new task
      }

      final updatedTodo = currentTaskData.copyWith(
        title: _titleController.text,
        subtitle: _subtitleController.text,
        priority: _priorityController.text,
        deadline: parsedDeadline,
        remindAt: parsedDeadline != null
          ? convertReminderStringToDateTime(_remindController.text, parsedDeadline)
          : null,
        remind: _remindController.text,
        repeat: _repeatController.text,
      );

      if (taskIndex != null) {
        // Update existing task (including auto-saved drafts)
        context.read<TodoBloc>().add(UpdateTodo(taskIndex, updatedTodo));
      } else {
        // Add completely new task
        context.read<TodoBloc>().add(AddTodo(updatedTodo));
      }
    }
    
    // Navigate back
    if (widget.isSubTask && widget.showParentAfterBack) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => TaskDetailsPage(
            taskIndex: widget.taskIndex ?? _currentTaskIndex, // Use correct task index
            isSubTask: false,
            showParentAfterBack: false,
            initialPage: 1,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else if(!widget.isSubTask){
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainWrapper(pageIndex: 0,)),
        (Route<dynamic> route) => false,
      );
    }else{
      Navigator.of(context).pop();
    }
  }

  // Method to show pop up options
  void _showPopupOptions({
    required BuildContext context,
    required List<String> options,
    required RenderBox buttonBox,
  }) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero, ancestor: overlay);
    final Size screenSize = overlay.size;
    
    const double verticalOffset = 5.0;
    const double itemHeight = 44.0;
    const double popupPadding = 16.0;
    
    final double estimatedPopupHeight = (itemHeight * options.length) + popupPadding;
    
    // Calculate available space
    final double spaceBelow = screenSize.height - (buttonPosition.dy + buttonBox.size.height + verticalOffset);
    final double spaceAbove = buttonPosition.dy - verticalOffset;
    
    // Determine positioning strategy
    final bool showBelow = spaceBelow >= estimatedPopupHeight;
    final bool showAbove = !showBelow && spaceAbove >= estimatedPopupHeight;
    
    RelativeRect position;
    
    if (showBelow) {
      // Show below the button
      position = RelativeRect.fromRect(
        Rect.fromPoints(
          buttonPosition + Offset(0, buttonBox.size.height + verticalOffset),
          buttonPosition + Offset(buttonBox.size.width, buttonBox.size.height + verticalOffset),
        ),
        Offset.zero & overlay.size,
      );
    } else if (showAbove) {
      // Show above the button - account for full popup height
      position = RelativeRect.fromRect(
        Rect.fromPoints(
          buttonPosition - Offset(0, estimatedPopupHeight + verticalOffset),
          buttonPosition + Offset(buttonBox.size.width, -verticalOffset),
        ),
        Offset.zero & overlay.size,
      );
    } else {
      // Neither above nor below has enough space
      // Choose the side with more space and let Flutter handle scrolling
      if (spaceBelow > spaceAbove) {
        // Prefer below but constrain height
        position = RelativeRect.fromRect(
          Rect.fromPoints(
            buttonPosition + Offset(0, buttonBox.size.height + verticalOffset),
            buttonPosition + Offset(buttonBox.size.width, buttonBox.size.height + verticalOffset),
          ),
          Offset.zero & overlay.size,
        );
      } else {
        // Prefer above but constrain height
        final double maxHeight = spaceAbove - verticalOffset;
        position = RelativeRect.fromRect(
          Rect.fromPoints(
            buttonPosition - Offset(0, maxHeight),
            buttonPosition + Offset(buttonBox.size.width, -verticalOffset),
          ),
          Offset.zero & overlay.size,
        );
      }
    }
  
    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),

      elevation: 8.0,
      color: white,
      constraints: BoxConstraints(minWidth: 0),
      items: _buildPopupMenuItemsWithDividers(
        options: options, 
        selectedValue: _getSelectedValueForOption(options)
      ),
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

  List<PopupMenuEntry<String>> _buildPopupMenuItemsWithDividers({
    required List<String> options,
    required String selectedValue,
  }){
    List<PopupMenuEntry<String>> items = [];

    for(int i=0; i<options.length; i++){
      items.add(_buildPopupMenuItem(
        value: options[i],
        selectedValue: selectedValue,
      ));

      if (i == 0 && options.length > 1) {
        items.add(_buildCustomDivider());
      } else if (i < options.length - 1 && i != 0) {
        items.add(PopupMenuDivider(height: 0.4));
      }
    }

    return items;
  }
  
  PopupMenuEntry<String> _buildCustomDivider() {
    return PopupMenuItem<String>(
      enabled: false,
      height: 10.0,
      padding: EdgeInsets.zero,
      child: Container(
        height: 10.0,
        decoration: BoxDecoration(
          color: dividerColor,
        ),
      ),
    );
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: isSelected
                ? Icon(CupertinoIcons.checkmark_alt, size: 18)
                : null,
            ),
            Expanded(
              child: Center(child: Text(value),),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildContent(int index){
    switch(index){
      case 0:
        return _buildInfoContent();
      case 1:
        return _buildSubtasksContent();
      default:
        return _buildInfoContent();
    }
  }

  Widget _buildInfoContent(){
    return Container(
      color: backgoundGrey,
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.only(top: 14.0),
          child: ListView(
            children:[
              
              // DATE SECTION
              buildContainer(
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
                    child: Switch.adaptive(
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
                    child: Switch.adaptive(
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
              buildContainer(
                context: context,
                icons: [
                  _iconSetUp(
                    icon: Icon(
                      CupertinoIcons.exclamationmark,
                      size: 28
                    ),
                    backgroundColor: red,
                  ),
                ],
                title: [Text("Priority", style: taskTitleStyle)],
                info: [
                  _infoSetUp(
                    key: _priorityKey,
                    text: _priorityController.text,
                    icon: Icon(
                      CupertinoIcons.chevron_up_chevron_down,
                      size: 20,
                    ),
                  ),
                ],
                onTap: [
                  (){ 
                    final RenderBox buttonBox = _priorityKey.currentContext!.findRenderObject() as RenderBox;
                    _showPopupOptions(
                      context: context, 
                      options: tasksPriority,
                      buttonBox: buttonBox,
                    ); 
                  },
                ],
              ),
            
              // REMIND & REPEAT SECTION
              buildContainer(
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
            
              if(!widget.isSubTask) ...[
                // TAGS SECTION
                buildContainer(
                  context: context,
                  icons: [_iconSetUp(icon: Icon(CupertinoIcons.number,), backgroundColor: greyDark), ],
                  title: [Text("Tags", style: taskTitleStyle,)], 
                  info: [
                    _infoSetUp(
                      icon: Icon(CupertinoIcons.chevron_right,),
                    ),
                  ],
                  onTap: [() =>  _tagPicker(context, tagsController, _currentItem.tags),],
                ),
              ],

              // TEST SECTION - TODO: not in final
              buildContainer(
                context: context,
                icons:[
                  _iconSetUp(
                    icon: Icon(CupertinoIcons.printer),
                    backgroundColor: amber,
                  ),
                ],
                title: [Text("PRINT TASK INFO", style: taskTitleStyle,)],
                info: [
                  _infoSetUp(
                    icon: Icon(CupertinoIcons.printer,),
                  ),
                ],
                onTap: [
                  () {
                    // Implement print functionality here
                    if (kDebugMode) {
                      print(_currentItem.toString());
                    }
                  },
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtasksContent() {
    if (widget.taskIndex == null && !_wasAutoSaved) {
      return Container(
        color: backgoundGrey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Add a title to get started',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your task will be automatically saved as a draft',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Determine which task index to use for subtasks
    final taskIndexToUse = widget.taskIndex ?? _currentTaskIndex;

    return Container(
      color: backgoundGrey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Column(
          children: [
            // Show auto-save indicator
            if (_wasAutoSaved)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: blue.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: blue.withAlpha(75)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 6),
                    Text(
                      'Draft saved automatically',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
            Expanded(
              child: ListView.builder(
                itemCount: widget.isSubTask 
                  ? 0 
                  : (taskIndexToUse != null 
                      ? context.read<TodoBloc>().state.todos[taskIndexToUse].subtasks.length 
                      : 0),
                padding: const EdgeInsets.only(bottom: 120.0),
                itemBuilder: (context, index) {
                  final subtask = context.read<TodoBloc>().state.todos[taskIndexToUse!].subtasks[index];
                  return TodoCard.forSubTask(
                    subTask: subtask,
                    originalIndex: index,
                    onDelete: () {
                      context.read<TodoBloc>().add(RemoveSubTask(taskIndexToUse, index));
                    },
                    onToggleCompletion: () => context.read<TodoBloc>().add(
                      CompleteSubTask(taskIndexToUse, index),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailsPage(
                            taskIndex: taskIndexToUse,
                            subTaskIndex: index,
                            isSubTask: true,
                            showParentAfterBack: true,
                          ),
                        ),
                      );
                    }
                  );
                }
              ),
            ),
          ],
        )
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
                hintStyle: textHintStyle,
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
  await TagStorage.addTags(selectedTags);

  // print('Updated task tags: $selectedTags');
}
