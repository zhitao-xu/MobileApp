part of 'todo_bloc.dart';

@immutable
abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class TodoStarted extends TodoEvent {}

class AddTodo extends TodoEvent {
  final Todo todo;

  const AddTodo(this.todo);

  @override
  List<Object?> get props => [todo];
}

class AddSubTask extends TodoEvent {
  final int todoIndex;
  final SubTask subTask;

  const AddSubTask(this.todoIndex, this.subTask);

  @override
  List<Object?> get props => [todoIndex, subTask];
}

class CompleteSubTask extends TodoEvent {
  final int todoIndex;
  final int subTaskIndex;

  const CompleteSubTask(this.todoIndex, this.subTaskIndex);

  @override
  List<Object?> get props => [todoIndex, subTaskIndex];
}

class UpdateSubTask extends TodoEvent {
  final int todoIndex;
  final int subTaskIndex;
  final SubTask updatedSubTask;

  const UpdateSubTask(this.todoIndex, this.subTaskIndex, this.updatedSubTask);

  @override
  List<Object?> get props => [todoIndex, subTaskIndex, updatedSubTask];
}

class RemoveTodo extends TodoEvent {
  final Todo todo;

  const RemoveTodo(this.todo);

  @override
  List<Object?> get props => [todo];
}

class RemoveSubTask extends TodoEvent {
  final int todoIndex;
  final int subTaskIndex;

  const RemoveSubTask(this.todoIndex, this.subTaskIndex);

  @override
  List<Object?> get props => [todoIndex, subTaskIndex];
}

class AlterTodo extends TodoEvent {
  final int index;

  const AlterTodo(this.index);

  @override
  List<Object?> get props => [index];
}

class UpdateTodo extends TodoEvent {
  final int index;
  final Todo updatedTodo;

  const UpdateTodo(this.index, this.updatedTodo);

  @override
  List<Object?> get props => [index, updatedTodo];
}
