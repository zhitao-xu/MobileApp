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
    emit(
        state.copyWith(
            status: TodoStatus.loading
        )
    );
    try {
      final updatedTodos = List<Todo>.from(state.todos);
      final updatedTodo = updatedTodos[event.todoIndex].copyWith(
        subtasks: List<SubTask>.from(updatedTodos[event.todoIndex].subtasks)
          ..add(event.subTask),
      );
      updatedTodos[event.todoIndex] = updatedTodo;

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
      final updatedSubTasks = List<SubTask>.from(updatedTodos[event.todoIndex].subtasks);

      // Verifica che i subtask precedenti siano completati
      if (event.subTaskIndex > 0 && !updatedSubTasks[event.subTaskIndex - 1].isDone) {
        emit(state.copyWith(status: TodoStatus.success));
        return; // Subtask dependency not satisfied
      }

      // Aggiorna lo stato del subtask
      updatedSubTasks[event.subTaskIndex] =
          updatedSubTasks[event.subTaskIndex].copyWith(isDone: !updatedSubTasks[event.subTaskIndex].isDone);

      // Verifica se tutti i subtask sono completati
      final allSubTasksCompleted = updatedSubTasks.every((subTask) => subTask.isDone);

      final updatedTodo = updatedTodos[event.todoIndex].copyWith(
        subtasks: updatedSubTasks,
        isDone: allSubTasksCompleted, // Imposta isDone del todo in base allo stato di tutti i subtask
      );
      updatedTodos[event.todoIndex] = updatedTodo;

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

  // Nuovo metodo per aggiornare i dettagli di un subtask (priorità, scadenza, ecc.)
  void _onUpdateSubTask(
      UpdateSubTask event,
      Emitter<TodoState> emit,
      ) {
    emit(
        state.copyWith(
            status: TodoStatus.loading
        )
    );
    try {
      final updatedTodos = List<Todo>.from(state.todos);
      final updatedSubTasks = List<SubTask>.from(updatedTodos[event.todoIndex].subtasks);

      // Sostituisce il subtask con la versione aggiornata
      updatedSubTasks[event.subTaskIndex] = event.updatedSubTask;

      final updatedTodo = updatedTodos[event.todoIndex].copyWith(
        subtasks: updatedSubTasks,
      );
      updatedTodos[event.todoIndex] = updatedTodo;

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

  void _onRemoveSubTask(
      RemoveSubTask event,
      Emitter<TodoState> emit,
      ) {
    emit(
        state.copyWith(
            status: TodoStatus.loading
        )
    );
    try {
      final updatedTodos = List<Todo>.from(state.todos);
      final updatedSubTasks = List<SubTask>.from(updatedTodos[event.todoIndex].subtasks);

      // Rimuove il subtask all'indice specificato
      updatedSubTasks.removeAt(event.subTaskIndex);

      final updatedTodo = updatedTodos[event.todoIndex].copyWith(
        subtasks: updatedSubTasks,
        isDone: updatedSubTasks.isNotEmpty && updatedSubTasks.every((s) => s.isDone),
      );
      updatedTodos[event.todoIndex] = updatedTodo;

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