import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import '../data/todo.dart';
import 'package:flutter_application_1/pages/analytics/stats/user_stats_cubit.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends HydratedBloc<TodoEvent, TodoState> {
  final UserStatsCubit _userStatsCubit; // Declare a final field for UserStatsCubit

  TodoBloc({required UserStatsCubit userStatsCubit}) // Add it to the constructor
      : _userStatsCubit = userStatsCubit, // Initialize it
        super(const TodoState()) {
    on<TodoStarted>(_onStarted);
    on<AddTodo>(_onAddTodo);
    on<RemoveTodo>(_onRemoveTodo);
    on<AlterTodo>(_onAlterTodo);
    on<AddSubTask>(_onAddSubTask);
    on<CompleteSubTask>(_onCompleteSubTask);
    on<UpdateSubTask>(_onUpdateSubTask);
    on<RemoveSubTask>(_onRemoveSubTask);
    on<UpdateTodo>(_onUpdateTodo);
  }

  void _onStarted(
      TodoStarted event,
      Emitter<TodoState> emit,
      ) {
    if(state.status == TodoStatus.success) return;
    emit(
        state.copyWith(
            todos: state.todos,
            status: TodoStatus.success
        )
    );
  }

  void _onAddTodo(
      AddTodo event,
      Emitter<TodoState> emit,
      ) {
    emit(
        state.copyWith(
            status: TodoStatus.loading
        )
    );
    try {
      List<Todo> temp = [];
      temp.addAll(state.todos);
      temp.insert(0, event.todo);
      emit(
          state.copyWith(
              todos: temp,
              status: TodoStatus.success
          )
      );
    } catch (e) {
      emit(
          state.copyWith(
              status: TodoStatus.error
          )
      );
    }
  }

  void _onRemoveTodo(
      RemoveTodo event,
      Emitter<TodoState> emit,
      ) {
    emit(
        state.copyWith(
            status: TodoStatus.loading
        )
    );
    try {
      state.todos.remove(event.todo);
      emit(
          state.copyWith(
              todos: state.todos,
              status: TodoStatus.success
          )
      );
    } catch (e) {
      emit(
          state.copyWith(
              status: TodoStatus.error
          )
      );
    }
  }

  void _onAlterTodo(AlterTodo event, Emitter<TodoState> emit) {
    emit(state.copyWith(status: TodoStatus.loading));
    try {
      final updatedTodos = List<Todo>.from(state.todos);
      final int index = event.index;

      if (index < 0 || index >= updatedTodos.length) {
        emit(state.copyWith(status: TodoStatus.error));
        return;
      }

      final Todo oldTodo = updatedTodos[index];
      final bool willBeDone = !oldTodo.isDone; // The new `isDone` status

      // Update analytics based on the transition
      if (!oldTodo.isDone && willBeDone) { // Task is becoming done
        _userStatsCubit.incrementTotalTasksCompleted();
      } else if (oldTodo.isDone && !willBeDone) { // Task is becoming undone
        _userStatsCubit.decrementTotalTasksCompleted();
      }

      // NEW: Update actualCompletionDate timestamp
      final DateTime? newActualCompletionDate = willBeDone ? DateTime.now() : null;

      // Update the Todo's actual `isDone` status and actualCompletionDate
      updatedTodos[index] = oldTodo.copyWith(
        isDone: willBeDone,
        actualCompletionDate: newActualCompletionDate, // Assign the timestamp
      );

      emit(state.copyWith(todos: updatedTodos, status: TodoStatus.success));

      // Call for on-time streak calculation after todos are updated
      _userStatsCubit.calculateOnTimePercentage(updatedTodos); // Pass the updated list

    } catch (e) {
      emit(state.copyWith(status: TodoStatus.error));
    }
  }

  
  void _onAddSubTask(AddSubTask event, Emitter<TodoState> emit) {
    emit(state.copyWith(status: TodoStatus.loading));
    try {
      final updatedTodos = List<Todo>.from(state.todos);
      if (event.todoIndex < 0 || event.todoIndex >= updatedTodos.length) {
        emit(state.copyWith(status: TodoStatus.error));
        return;
      }

      final Todo oldParentTodo = updatedTodos[event.todoIndex];
      final List<SubTask> currentSubtasks = List<SubTask>.from(oldParentTodo.subtasks);

      // Add the new subtask
      currentSubtasks.add(event.subTask);

      // Re-evaluate the parent task's `isDone` status
      // A parent is done only if all its (possibly new) subtasks are done.
      // If a new subtask is added, it's typically incomplete, so parent will become incomplete.
      final bool newParentTodoIsDone = currentSubtasks.every((subTask) => subTask.isDone);

      // Update analytics based on the parent todo's transition
      if (oldParentTodo.isDone && !newParentTodoIsDone) { // Parent was done, now it's not
        _userStatsCubit.decrementTotalTasksCompleted();
      }
      // No increment logic here, as adding a subtask never completes a parent task.

      // Create the updated parent todo
      final updatedParentTodo = oldParentTodo.copyWith(
        subtasks: currentSubtasks,
        isDone: newParentTodoIsDone, // Update the `isDone` status
      );
      updatedTodos[event.todoIndex] = updatedParentTodo;

      emit(state.copyWith(todos: updatedTodos, status: TodoStatus.success));
    } catch (e) {
      emit(state.copyWith(status: TodoStatus.error));
    }
  }

  void _onCompleteSubTask(
      CompleteSubTask event,
      Emitter<TodoState> emit,
      ) {
    emit(
        state.copyWith(
            status: TodoStatus.loading
        )
    );
    try {
      final updatedTodos = List<Todo>.from(state.todos);
      if (event.todoIndex < 0 || event.todoIndex >= updatedTodos.length) {
        emit(state.copyWith(status: TodoStatus.error));
        return;
      }

      final Todo oldParentTodo = updatedTodos[event.todoIndex];  
      final List<SubTask> updatedSubTasks = List<SubTask>.from(oldParentTodo.subtasks);

      if (event.subTaskIndex < 0 || event.subTaskIndex >= updatedSubTasks.length) {
        emit(state.copyWith(status: TodoStatus.error));
        return;
      }

      // Toggle subtask's isDone and set its actualCompletionDate
      updatedSubTasks[event.subTaskIndex] = updatedSubTasks[event.subTaskIndex]
          .copyWith(
            isDone: !updatedSubTasks[event.subTaskIndex].isDone,
            actualCompletionDate: !updatedSubTasks[event.subTaskIndex].isDone ? DateTime.now() : null,
          );

      final bool allSubTasksCompleted = updatedSubTasks.every((subTask) => subTask.isDone);
      final bool newParentTodoIsDone = allSubTasksCompleted; // Derive parent's isDone

      // Analytics Logic:
      // If the parent task just became completed due to subtask completion
      if (!oldParentTodo.isDone && newParentTodoIsDone) {
        _userStatsCubit.incrementTotalTasksCompleted();
      }
      // If the parent task just became incomplete (un-completed) due to a subtask being un-completed
      else if (oldParentTodo.isDone && !newParentTodoIsDone) {
        _userStatsCubit.decrementTotalTasksCompleted();
      }

      final DateTime? newParentActualCompletionDate = newParentTodoIsDone ? DateTime.now() : null;

      // Update the Todo's actual `isDone` status and actualCompletionDate
      final Todo newParentTodo = oldParentTodo.copyWith(
        subtasks: updatedSubTasks,
        isDone: newParentTodoIsDone,
        actualCompletionDate: newParentActualCompletionDate, // Assign the timestamp
      );
      updatedTodos[event.todoIndex] = newParentTodo;

      emit(state.copyWith(todos: updatedTodos, status: TodoStatus.success));
      // Call for on-time streak calculation after todos are updated
      _userStatsCubit.calculateOnTimePercentage(updatedTodos); // Pass the updated list
    } catch (e) {
      emit(state.copyWith(status: TodoStatus.error));
    }
  }

  // Nuovo metodo per aggiornare i dettagli di un subtask (priorità, scadenza, ecc.)
  //TODO: controllare se in futuro questo metodo può causare la parent task a diventare done o not.

  void _onUpdateSubTask(UpdateSubTask event, Emitter<TodoState> emit,) {
    emit(state.copyWith(status: TodoStatus.loading));

    try {
      final updatedTodos = List<Todo>.from(state.todos);
      if (event.todoIndex < 0 || event.todoIndex >= updatedTodos.length) {
        emit(state.copyWith(status: TodoStatus.error));
        return;
      }
      final updatedSubTasks = List<SubTask>.from(updatedTodos[event.todoIndex].subtasks);
      if (event.subTaskIndex < 0 || event.subTaskIndex >= updatedSubTasks.length) {
        emit(state.copyWith(status: TodoStatus.error));
        return;
      }
      
      // Sostituisce il subtask con la versione aggiornata
      updatedSubTasks[event.subTaskIndex] = event.updatedSubTask;

      final updatedTodo = updatedTodos[event.todoIndex].copyWith(
        subtasks: updatedSubTasks,
      );
      updatedTodos[event.todoIndex] = updatedTodo;

      emit(state.copyWith(todos: updatedTodos, status: TodoStatus.success));
    } catch (e) {
      emit(state.copyWith(status: TodoStatus.error));
    }
  }

  void _onRemoveSubTask(RemoveSubTask event, Emitter<TodoState> emit) {
    emit(state.copyWith(status: TodoStatus.loading));
    try {
      final updatedTodos = List<Todo>.from(state.todos);
      if (event.todoIndex < 0 || event.todoIndex >= updatedTodos.length) {
        emit(state.copyWith(status: TodoStatus.error));
        return;
      }
      final Todo oldParentTodo = updatedTodos[event.todoIndex];
      final List<SubTask> updatedSubTasks = List<SubTask>.from(oldParentTodo.subtasks);

      if (event.subTaskIndex < 0 || event.subTaskIndex >= updatedSubTasks.length) {
        emit(state.copyWith(status: TodoStatus.error));
        return;
      }

      updatedSubTasks.removeAt(event.subTaskIndex);

      final bool allRemainingSubTasksCompleted = updatedSubTasks.isNotEmpty && updatedSubTasks.every((s) => s.isDone);
      final bool newParentTodoIsDone = allRemainingSubTasksCompleted;

      // Analytics Logic: if removing a subtask causes the parent todo to become complete
      if (!oldParentTodo.isDone && newParentTodoIsDone) {
        _userStatsCubit.incrementTotalTasksCompleted();
      }

      // Update actualCompletionDate for the parent todo based on its new state
      final DateTime? newParentActualCompletionDate = newParentTodoIsDone ? DateTime.now() : null;

      final newParentTodo = oldParentTodo.copyWith(
        subtasks: updatedSubTasks,
        isDone: newParentTodoIsDone,
        actualCompletionDate: newParentActualCompletionDate,
      );

      updatedTodos[event.todoIndex] = newParentTodo;

      emit(state.copyWith(todos: updatedTodos, status: TodoStatus.success));
      _userStatsCubit.calculateOnTimePercentage(updatedTodos); // Call after state update
      
    } catch (e) {
      emit(state.copyWith(status: TodoStatus.error));
    }
  }

  @override
  TodoState? fromJson(Map<String, dynamic> json) {
    return TodoState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(TodoState state) {
    return state.toJson();
  }
  
  // Nuovo metodo per aggiornare un task
  void _onUpdateTodo(
      UpdateTodo event,
      Emitter<TodoState> emit,
      ) {
    emit(
        state.copyWith(
            status: TodoStatus.loading
        )
    );
    try {
      final updatedTodos = List<Todo>.from(state.todos);
      updatedTodos[event.index] = event.updatedTodo;
      
      emit(
          state.copyWith(
              todos: updatedTodos,
              status: TodoStatus.success
          )
      );
    } catch (e) {
      emit(
          state.copyWith(
              status: TodoStatus.error
          )
      );
    }
  }
}