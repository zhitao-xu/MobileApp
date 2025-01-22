import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import '../data/todo.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends HydratedBloc<TodoEvent, TodoState> {
  TodoBloc() : super(const TodoState()) {
    on<TodoStarted>(_onStarted);
    on<AddTodo>(_onAddTodo);
    on<RemoveTodo>(_onRemoveTodo);
    on<AlterTodo>(_onAlterTodo);
    on<AddSubTask>(_onAddSubTask); // Registering AddSubTask
    on<CompleteSubTask>(_onCompleteSubTask); // Registering CompleteSubTask
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

  void _onAlterTodo(
      AlterTodo event,
      Emitter<TodoState> emit,
      ) {
    emit(
        state.copyWith(
            status: TodoStatus.loading
        )
    );
    try {
      state.todos[event.index].isDone = !state.todos[event.index].isDone;
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

  void _onAddSubTask(
      AddSubTask event,
      Emitter<TodoState> emit,
      ) {
    final updatedTodos = List<Todo>.from(state.todos);
    final updatedTodo = updatedTodos[event.todoIndex].copyWith(
      subtasks: List<SubTask>.from(updatedTodos[event.todoIndex].subtasks)
        ..add(event.subTask),
    );
    updatedTodos[event.todoIndex] = updatedTodo;

    emit(state.copyWith(todos: updatedTodos));
  }

  void _onCompleteSubTask(
      CompleteSubTask event,
      Emitter<TodoState> emit,
      ) {
    final updatedTodos = List<Todo>.from(state.todos);
    final updatedSubTasks = List<SubTask>.from(updatedTodos[event.todoIndex].subtasks);

    if (event.subTaskIndex > 0 && !updatedSubTasks[event.subTaskIndex - 1].isDone) {
      return; // Subtask dependency not satisfied
    }

    updatedSubTasks[event.subTaskIndex] =
        updatedSubTasks[event.subTaskIndex].copyWith(isDone: true);

    final allSubTasksCompleted = updatedSubTasks.every((subTask) => subTask.isDone);

    final updatedTodo = updatedTodos[event.todoIndex].copyWith(
      subtasks: updatedSubTasks,
      isDone: allSubTasksCompleted,
    );
    updatedTodos[event.todoIndex] = updatedTodo;

    emit(state.copyWith(todos: updatedTodos));
  }

  @override
  TodoState? fromJson(Map<String, dynamic> json) {
    return TodoState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(TodoState state) {
    return state.toJson();
  }
}
