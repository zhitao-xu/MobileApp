import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../todo_bloc/todo_bloc.dart';
import '../data/todo.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'subtask_details.dart';

class EditTaskPage extends StatefulWidget {
  final int taskIndex;

  const EditTaskPage({super.key, required this.taskIndex});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _priorityController;
  late TextEditingController _deadlineController;
  late TextEditingController _remindController;
  late TextEditingController _dateController;
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
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        title: const Text('Editing Task...'),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_titleController, 'Title', 'Enter task title'),
                  const SizedBox(height: 16),
                  _buildTextField(_subtitleController, 'Description', 'Enter task description'),
                  const SizedBox(height: 16),
                  _buildTextField(_priorityController, 'Priority', 'Set priority (High, Medium, Low)'),
                  const SizedBox(height: 16),
                  _buildDateField(_dateController, 'Date', context),
                  const SizedBox(height: 16),
                  _buildDateField(_deadlineController, 'Deadline', context),
                  const SizedBox(height: 16),
                  _buildTextField(_remindController, 'Remind', 'Set reminder time'),
                  const SizedBox(height: 24),
                  
                  // Subtasks section
                  const Text(
                    'Subtasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // List of subtasks with edit option
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _currentTodo.subtasks.length,
                    itemBuilder: (context, index) {
                      final subtask = _currentTodo.subtasks[index];
                      return ListTile(
                        title: Text(subtask.title),
                        subtitle: Text(subtask.subtitle.isEmpty ? 'No description' : subtask.subtitle),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubtaskDetailsPage(
                                  taskIndex: widget.taskIndex,
                                  subtaskIndex: index,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _saveTask,
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(color: white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
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
  
  void _saveTask() {
    final updatedTodo = _currentTodo.copyWith(
      title: _titleController.text,
      subtitle: _subtitleController.text,
      priority: _priorityController.text,
      date: _dateController.text,
      // deadline: _deadlineController.text,
      remind: _remindController.text,
    );
    
    context.read<TodoBloc>().add(UpdateTodo(widget.taskIndex, updatedTodo));
    
    
    // Navigate back
    Navigator.pop(context);
  }
}