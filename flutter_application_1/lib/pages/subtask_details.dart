import 'package:flutter/material.dart';
import 'package:flutter_application_1/widget/main_wrapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../todo_bloc/todo_bloc.dart';
import '../data/todo.dart';
import 'package:flutter_application_1/utils/theme.dart';

class SubtaskDetailsPage extends StatefulWidget {
  final int taskIndex;
  final int subtaskIndex;

  const SubtaskDetailsPage({
    super.key, 
    required this.taskIndex, 
    required this.subtaskIndex
  });

  @override
  State<SubtaskDetailsPage> createState() => _SubtaskDetailsPageState();
}

class _SubtaskDetailsPageState extends State<SubtaskDetailsPage> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _priorityController;
  late TextEditingController _deadlineController;
  late TextEditingController _remindController;
  late TextEditingController _dateController;
  late SubTask _currentSubtask;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    final todos = context.read<TodoBloc>().state.todos;
    _currentSubtask = todos[widget.taskIndex].subtasks[widget.subtaskIndex];
    
      _titleController = TextEditingController(text: _currentSubtask.title);
      _subtitleController = TextEditingController(text: _currentSubtask.subtitle);
      _priorityController = TextEditingController(text: _currentSubtask.priority);
      _deadlineController = TextEditingController(text: _currentSubtask.deadline);
      _remindController = TextEditingController(text: _currentSubtask.remind);
      _dateController = TextEditingController(text: _currentSubtask.date);
      _isDone = _currentSubtask.isDone;

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
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        title: const Text('Editing Subtask...'),
        backgroundColor: lightBlue,
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state.status == TodoStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Container(
            color: white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        
                        _buildTextField(_titleController, 'Title', 'Enter subtask title'),
                        const SizedBox(height: 16),
                        _buildTextField(_subtitleController, 'Description', 'Enter subtask description'),
                        const SizedBox(height: 16),
                        _buildTextField(_priorityController, 'Priority', 'Set priority (High, Medium, Low)'),
                        const SizedBox(height: 16),
                        _buildDateField(_dateController, 'Date', context),
                        const SizedBox(height: 16),
                        _buildDateField(_deadlineController, 'Deadline', context),
                        const SizedBox(height: 16),
                        _buildTextField(_remindController, 'Remind', 'Set reminder time'),
                        const SizedBox(height: 32),
                        
                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lightBlue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _saveSubtask,
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(color: white, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // Remove any potential gap or placeholder here
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: MainWrapperBottomNavBar(
        currentIndex: -1,
        onPageChanged: (index) {
          // Handle bottom navigation bar item tap
          print("Page changed to $index");
        },
      ),
    );
  }
  
  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    String hint
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDateField(
    TextEditingController controller, 
    String label,
    BuildContext context
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: true, // Make it read-only
          decoration: InputDecoration(
            hintText: 'Select $label',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            
            if (pickedDate != null) {
              setState(() {
                controller.text = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
              });
            }
          },
        ),
      ],
    );
  }
  
  void _saveSubtask() {
    final updatedSubtask = SubTask(
      title: _titleController.text,
      subtitle: _subtitleController.text,
      isDone: _isDone,
      priority: _priorityController.text,
      date: _dateController.text,
      deadline: _deadlineController.text,
      remind: _remindController.text,
    );
    
    context.read<TodoBloc>().add(
      UpdateSubTask(
        widget.taskIndex, 
        widget.subtaskIndex,
        updatedSubtask
      )
    );
    
  
    // Navigate back
    Navigator.pop(context);
  }
}