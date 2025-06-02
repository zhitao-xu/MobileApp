import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/todo.dart';
import 'package:flutter_application_1/pages/task_details.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class TodoCard<T> extends StatefulWidget {
  final T item; // Can be Todo or SubTask
  final int originalIndex;
  final VoidCallback? onToggleCompletion;
  final VoidCallback? onDelete;
  final void Function(T updatedItem)? onUpdateFullItem;
  final bool showDate;
  final bool showTime;
  final bool isSubTask;
  final VoidCallback? onTap; // Custom tap handler for subtasks
  final bool hasSubtasks;
  final VoidCallback? onToggleSubtaskVisibility;
  final void Function(SubTask, int)? onSubTaskToggleCompletion;
  final void Function(SubTask, int)? onSubTaskDelete;

  const TodoCard({
    super.key,
    required this.item,
    required this.originalIndex,
    this.onToggleCompletion,
    this.onDelete,
    this.onUpdateFullItem,
    this.showDate = true,
    this.showTime = true,
    this.isSubTask = false,
    this.onTap,
    this.hasSubtasks = false,
    this.onToggleSubtaskVisibility,
    this.onSubTaskToggleCompletion,
    this.onSubTaskDelete,
  });

  // Factory constructors for easier usage
  static TodoCard<Todo> forTodo({
    Key? key,
    required Todo todo,
    required int originalIndex,
    VoidCallback? onToggleCompletion,
    VoidCallback? onDelete,
    void Function(Todo updatedTodo)? onUpdateFullTodo,
    bool showDate = true,
    bool showTime = true,
    VoidCallback? onTap,
    bool hasSubtasks = false,
    VoidCallback? onToggleSubtaskVisibility,
    void Function(SubTask, int)? onSubTaskToggleCompletion,
    void Function(SubTask, int)? onSubTaskDelete,
  }) {
    return TodoCard<Todo>(
      key: key,
      item: todo,
      originalIndex: originalIndex,
      onToggleCompletion: onToggleCompletion,
      onDelete: onDelete,
      onUpdateFullItem: onUpdateFullTodo,
      showDate: showDate,
      showTime: showTime,
      isSubTask: false,
      onTap: onTap,
      hasSubtasks: hasSubtasks,
      onToggleSubtaskVisibility: onToggleSubtaskVisibility,
      onSubTaskToggleCompletion: onSubTaskToggleCompletion,
      onSubTaskDelete: onSubTaskDelete,
    );
  }

  static TodoCard<SubTask> forSubTask({
    Key? key,
    required SubTask subTask,
    required int originalIndex,
    VoidCallback? onToggleCompletion,
    VoidCallback? onDelete,
    void Function(SubTask updatedSubTask)? onUpdateFullSubTask,
    bool showDate = true,
    bool showTime = true,
    VoidCallback? onTap,
  }) {
    return TodoCard<SubTask>(
      key: key,
      item: subTask,
      originalIndex: originalIndex,
      onToggleCompletion: onToggleCompletion,
      onDelete: onDelete,
      onUpdateFullItem: onUpdateFullSubTask,
      showDate: showDate,
      showTime: showTime,
      isSubTask: true,
      onTap: onTap,
      hasSubtasks: false,
      onToggleSubtaskVisibility: null,
    );
  }

  @override
  State<TodoCard<T>> createState() => _TodoCardState<T>();
}

class _TodoCardState<T> extends State<TodoCard<T>> {
  bool _showSubtasks = false;
  bool _isDismissed = false;

  late bool _localIsDone;

  // --- initState() ---
  @override
  void initState() {
    super.initState();

    _localIsDone = _isDone;
  }


  @override
  void didUpdateWidget(covariant TodoCard<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // This method runs when the card is moved to a new list.
    // We check if the completion status from the BLoC (_isDone)
    // is different from our remembered status (_localIsDone).
    if (_isDone != _localIsDone) {
      // If they are different, it means the task was completed or undone.
      // We make the card visible again by resetting _isDismissed
      // and update our remembered status.
      setState(() {
        _isDismissed = false;
        _localIsDone = _isDone;
      });
    }
  }
  // Helper methods to access properties regardless of type
  String get _id {
    if (widget.item is Todo) {
      return (widget.item as Todo).id;
    } else if (widget.item is SubTask) {
      return (widget.item as SubTask).id;
    }
    return '';
  }

  String get _title {
    if (widget.item is Todo) {
      return (widget.item as Todo).title;
    } else if (widget.item is SubTask) {
      return (widget.item as SubTask).title;
    }
    return '';
  }

  String get _subtitle {
    if (widget.item is Todo) {
      return (widget.item as Todo).subtitle;
    } else if (widget.item is SubTask) {
      return (widget.item as SubTask).subtitle;
    }
    return '';
  }

  bool get _isDone {
    if (widget.item is Todo) {
      return (widget.item as Todo).isDone;
    } else if (widget.item is SubTask) {
      return (widget.item as SubTask).isDone;
    }
    return false;
  }

  String get _priority {
    if (widget.item is Todo) {
      return (widget.item as Todo).priority;
    } else if (widget.item is SubTask) {
      return (widget.item as SubTask).priority;
    }
    return '';
  }

  DateTime? get _deadline {
    if (widget.item is Todo) {
      return (widget.item as Todo).deadline;
    } else if (widget.item is SubTask) {
      return (widget.item as SubTask).deadline;
    }
    return null;
  }

  DateTime get _createdAt {
    if (widget.item is Todo) {
      return (widget.item as Todo).createdAt;
    } else if (widget.item is SubTask) {
      return (widget.item as SubTask).createdAt;
    }
    return DateTime.now();
  }

  List<SubTask> get _subtasks {
    if (widget.item is Todo) {
      return (widget.item as Todo).subtasks;
    }
    return [];
  }

  int daysFromToday(DateTime date) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime target = DateTime(date.year, date.month, date.day);

    return target.difference(today).inDays;
  }

  void _toggleSubtaskVisibility() {
    setState(() {
      _showSubtasks = !_showSubtasks;
    });
    if (widget.onToggleSubtaskVisibility != null) {
      widget.onToggleSubtaskVisibility!();
    }
  }

  void openDetailsPage(BuildContext context) async {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    
    if (widget.isSubTask) {
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskDetailsPage(
            taskIndex: widget.originalIndex,
            isSubTask: true,
            subTaskIndex: 0,
          ),
        ),
      );
      return;
    }

    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsPage(
        taskIndex: widget.originalIndex, 
        isSubTask: false,
      )),
    );
  }

  Widget _buildSubtasksList() {
    if (!_showSubtasks || _subtasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const Divider(height: 1, thickness: 0.5),
        ...List.generate(_subtasks.length, (index) {
          final subtask = _subtasks[index];
          return TodoCard<SubTask>(
            onTap: () {
              if(!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskDetailsPage(
                  taskIndex: widget.originalIndex,
                  isSubTask: true,
                  subTaskIndex: index,
                  showParentAfterBack: true,
                ))
              );
            },
            item: subtask,
            originalIndex: widget.originalIndex,
            onToggleCompletion: widget.onSubTaskToggleCompletion != null
                ? () => widget.onSubTaskToggleCompletion!(subtask, index)
                : null,
            onDelete: widget.onSubTaskDelete != null
                ? () => widget.onSubTaskDelete!(subtask, index)
                : null,
            showDate: widget.showDate,
            showTime: widget.showTime,
            isSubTask: true,
            hasSubtasks: false,
            onToggleSubtaskVisibility: null,
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    final isCompleted = _isDone;
    final backgroundColor = isCompleted
        ? Colors.grey[300]
        : getPriorityColor(_priority);

    DateTime? currentDeadline = _deadline;
    String deadlineText = '';
    int nDaysFromToday = 0;

    if (currentDeadline != null) {
      nDaysFromToday =  daysFromToday(currentDeadline);
      String? dayLabel;
      if (nDaysFromToday == -1) {
        dayLabel = 'Yesterday';
      } else if (nDaysFromToday == 0) {
        dayLabel = 'Today';
      } else if (nDaysFromToday == 1) {
        dayLabel = 'Tomorrow';
      }

      if (widget.showDate && widget.showTime) {
        if (dayLabel == null) {
          deadlineText = DateFormat('dd-MM-yyyy, HH:mm').format(currentDeadline);
        } else {
          deadlineText = '$dayLabel , ${DateFormat('HH:mm').format(currentDeadline)}';
        }
      } else if (widget.showDate) {
        deadlineText = dayLabel ?? DateFormat('dd-MM-yyyy').format(currentDeadline);
      } else if (widget.showTime) {
        deadlineText = DateFormat('HH:mm').format(currentDeadline);
      } else {
        deadlineText = 'Deadline set';
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.symmetric(
              vertical: widget.isSubTask ? 3.0 : 6.0,
              horizontal: widget.isSubTask ? 12.0 : 0.0,
            ),
            color: backgroundColor,
            elevation: widget.isSubTask ? 0.5 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: widget.isSubTask
                  ? BorderSide(color: Colors.grey[300]!, width: 0.5)
                  : BorderSide.none,
            ),
            child: Slidable(
              key: ValueKey(_id),
              startActionPane: ActionPane(
                motion: const ScrollMotion(),
                dismissible: widget.onDelete != null
                  ? DismissiblePane(onDismissed: () {
                      setState(() {
                        _isDismissed = true;
                      });
                      // 1. WRAP THIS LINE IN A FUTURE
                      Future.delayed(Duration.zero, () {
                        widget.onDelete?.call();
                      });
                    })
                  : null,
                children: [
                  CustomSlidableAction(
                    onPressed: widget.onDelete != null ? (_) => widget.onDelete!() : null,
                    backgroundColor: const Color(0xFFFE4A49),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, color: white),
                        SizedBox(height: 4),
                        Text('Delete', style: TextStyle(color: white)),
                      ],
                    ),
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                dismissible: widget.onToggleCompletion != null
                ? DismissiblePane(onDismissed: () {
                    setState(() {
                      _isDismissed = true;
                    });
                    // 2. WRAP THIS LINE IN A FUTURE
                    Future.delayed(Duration.zero, () {
                      widget.onToggleCompletion?.call();
                    });
                  })
                : null,
                children: [
                  if (!isCompleted)
                    CustomSlidableAction(
                      onPressed: (context) => widget.onToggleCompletion?.call(),
                      backgroundColor: green,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.checkmark_alt_circle_fill, color: white),
                          SizedBox(height: 4),
                          Text('Complete', style: TextStyle(color: white)),
                        ],
                      ),
                    ),
                  if (isCompleted)
                    CustomSlidableAction(
                      onPressed: (context) => widget.onToggleCompletion?.call(),
                      backgroundColor: orange,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.refresh_circled_solid, color: white),
                          SizedBox(height: 4),
                          Text('Undo', style: TextStyle(color: white)),
                        ],
                      ),
                    ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: widget.isSubTask ? 0.0 : 4.0),
                child: ListTile(
                  contentPadding: EdgeInsets.only(
                    top: widget.isSubTask ? 0.0 : 4.0,
                    bottom: widget.isSubTask ? 0.0 : 4.0,
                  ),

                  onTap: () => openDetailsPage(context),
                  
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      width: 50.0,
                      child: GestureDetector(
                        onTap: widget.onToggleCompletion,
                        behavior: HitTestBehavior.translucent,
                        child: Center(
                          child: isCompleted
                              ? const Icon(CupertinoIcons.largecircle_fill_circle, size: 20.0)
                              : const Icon(CupertinoIcons.circle, size: 20.0),
                        ),
                      ),
                    ),
                  ),
                  
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: TextStyle(
                          color: black,
                          fontWeight: widget.isSubTask ? FontWeight.normal : FontWeight.bold,
                          fontSize: widget.isSubTask ? 14 : 16,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                      if (_subtitle.isNotEmpty)
                        Text(
                          _subtitle,
                          style: TextStyle(
                            color: black,
                            fontSize: widget.isSubTask ? 12 : 14,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 2,
                        ),
                      if (deadlineText.isNotEmpty)
                        Text(
                          deadlineText,
                          style: TextStyle(
                            fontSize: widget.isSubTask ? 10 : 12,
                            color: nDaysFromToday<0 
                              ? red 
                              : nDaysFromToday == 0
                                ? orange
                                : grey,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                    ],
                  ),
                  subtitle: null,
                  trailing: widget.isSubTask
                    ? null
                    : widget.hasSubtasks && _subtasks.isNotEmpty
                      ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          onPressed: _toggleSubtaskVisibility, 
                          color: black,
                          icon: Icon(
                            _showSubtasks 
                              ? CupertinoIcons.chevron_up 
                              : CupertinoIcons.chevron_down
                          ),
                          iconSize: 20,
                          ),
                      )
                      : const SizedBox(width: 20.0)
                ),
              ),
            ),
          ),
          // Show subtasks if toggled on and not a subtask itself
          if (!widget.isSubTask) _buildSubtasksList(),
        ],
      ),
    );
  }
}