appBar: PreferredSize(
    preferredSize: const Size.fromHeight(300),
    child: NavigatorAppBar(
        onBackTap: _handleBackNavigation,
        title: widget.isSubTask ? "Subtask" : "Task",
        widget: Row(
            children: [
                TextButton(
                    onPressed: () =>{
                    _saveTask,
                    await _handleBackNavigation(),
                    },
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
      final hasChanges = _titleController.text != _currentItem.title ||
        _subtitleController.text != _currentItem.subtitle ||
        _priorityController.text != _currentItem.priority ||
        _deadlineDateController.text != formatDateTimeToDateString(_currentItem.deadline) ||
        _deadlineTimeController.text != formatDateTimeToTimeString(_currentItem.deadline) ||
        _remindController.text != _currentItem.remind ||
        _repeatController.text != _currentItem.repeat;

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

  void _saveTask() async{
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
        // Pass the parsed DateTime?
        deadline: parsedDeadline,
        // Pass the parsed DateTime?
        remindAt: parsedDeadline!=null
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
        context.read<TodoBloc>().add(AddSubTask(widget.taskIndex!, updatedSubTask));
      }
    } else {
      // Todo task saving logic
      final updatedTodo = (_currentItem as Todo).copyWith(
        title: _titleController.text,
        subtitle: _subtitleController.text,
        priority: _priorityController.text,
        // Pass the parsed DateTime?
        deadline: parsedDeadline,
        // Pass the parsed DateTime?
        remindAt: parsedDeadline!=null
          ? convertReminderStringToDateTime(_remindController.text, parsedDeadline)
          : null,
        // remindAt: parsedRemindAt, // Changed 'remind' to 'remindAt'
        remind: _remindController.text,
        repeat: _repeatController.text,
        tags: [], // Assuming tags are not controlled by a TextEditingController here
      );

      if (widget.taskIndex != null) {
        context.read<TodoBloc>().add(UpdateTodo(widget.taskIndex!, updatedTodo));
      } else {
        context.read<TodoBloc>().add(AddTodo(updatedTodo));
      }
    }
    
    // Navigate back
    // Navigator.pop(context);
  }