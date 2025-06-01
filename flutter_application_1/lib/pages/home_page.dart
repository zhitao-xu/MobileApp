import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widget/todo/todo_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/custom_app_bar.dart';
import 'package:flutter_application_1/data/todo.dart';
import 'package:flutter_application_1/todo_bloc/todo_bloc.dart';
import 'package:flutter_application_1/pages/task_details.dart';
import 'package:flutter_application_1/utils/todo_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  bool _isSearching = false;

  final GlobalKey _searchBarKey = GlobalKey();

  Timer? _debounceTimer;

  removeTodo(Todo todo) {
    context.read<TodoBloc>().add(RemoveTodo(todo));
  }

  alertTodo(int index) {
    context.read<TodoBloc>().add(AlterTodo(index));
  }

  void stopSearching(){
    setState(() {
      _isSearching = false;
      searchController.clear();
    });
    FocusScope.of(context).unfocus();
    if(kDebugMode){
      print("Search state stopped");
    }
  }

  // Search function that filters todos by title and subtitle (including subtasks)
  List<Todo> searchTodos(List<Todo> todos, String query) {
    if (query.isEmpty) {
      return [];
    }
    
    final lowercaseQuery = query.toLowerCase();
    
    return todos.where((todo) {
      // Check if main todo title or subtitle matches
      final todoMatches = todo.title.toLowerCase().contains(lowercaseQuery) ||
                         todo.subtitle.toLowerCase().contains(lowercaseQuery);
      
      // Check if any subtask title or subtitle matches
      final subtaskMatches = todo.subtasks.any((subtask) =>
          subtask.title.toLowerCase().contains(lowercaseQuery) ||
          subtask.subtitle.toLowerCase().contains(lowercaseQuery));
      
      return todoMatches || subtaskMatches;
    }).toList();
  }

  void _onSearchChanged(String value){
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), (){
      setState((){
        // Trigger search after 300ms of inactivity
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: CustomAppBar(
          title: "To-do List\n",
          isHome: true,
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TaskDetailsPage(),
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
        ),
      ),

      body: GestureDetector(
        onTapDown: (details) {
          final RenderBox? box = _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
          if (box != null) {
            final Offset searchBarPosition = box.localToGlobal(Offset.zero);
            final Size searchBarSize = box.size;
            final Rect searchBarRect = searchBarPosition & searchBarSize;

            if (!searchBarRect.contains(details.globalPosition)) {
              stopSearching();
            }
          }
        },
        child: Container(
          color: backgoundGrey,
          child: Column(
            children: [
              Container(
                key: _searchBarKey,
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      // search icon
                      Icon(CupertinoIcons.search,),
          
                      SizedBox(width: 10,),
                      // text controller 
                      Expanded(
                        child: TextField(
                          maxLines: 1,
                          controller: searchController,
                          textAlign: TextAlign.start,
                          onChanged: _onSearchChanged,
                          onTap: (){
                            setState(() {
                              _isSearching = true;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Search",
                            hintStyle: textHintStyle,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                          ),
                        ),
                      ),
          
                      // xmark icon appear when tapping something
                      if(searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              searchController.clear();
                            });
                          },
                          child: Icon(CupertinoIcons.clear_thick_circled,),
                        )
                    ],
                  ),
                ),
              ),
              
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: BlocBuilder<TodoBloc, TodoState>(
                    builder: (context, state) {
                      if (state.status == TodoStatus.success) {
                        List<Todo> todosToShow;
                        
                        if (_isSearching && searchController.text.isNotEmpty) {
                          // Show search results
                          todosToShow = searchTodos(state.todos, searchController.text);
                          
                          if (todosToShow.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.search,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No results found for "${searchController.text}"',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return ListView(
                            // Added padding to the bottom to move the last task out of the way of the add task floating action button
                            padding: const EdgeInsets.only(bottom: 85.0),
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Search Results (${todosToShow.length})',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...todosToShow.map((todo) =>
                                TodoCard.forTodo(
                                  key: ValueKey(todo.id),
                                  todo: todo,
                                  originalIndex: state.todos.indexOf(todo),
                                  onDelete: () => removeTodo(todo),
                                  onToggleCompletion: () => alertTodo(state.todos.indexOf(todo)),
                                  hasSubtasks: todo.subtasks.isNotEmpty,
                                  onSubTaskToggleCompletion: (subtask, subTaskIndex){
                                    context.read<TodoBloc>().add(
                                      CompleteSubTask(state.todos.indexOf(todo), subTaskIndex),
                                    );
                                  },
                                  onSubTaskDelete: (subtask, subTaskIndex){
                                    context.read<TodoBloc>().add(
                                      RemoveSubTask(state.todos.indexOf(todo), subTaskIndex),
                                    );
                                  }
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Show normal categorized view
                          // Filter and sort pending tasks using the utility function
                          final sortedPendingTodos = sortTodosByPriorityAndDeadline(
                            state.todos.where((todo) => !todo.isDone).toList(),
                          );
                  
                          // Filter and sort completed tasks using the utility function
                          final sortedCompletedTodos = sortTodosByPriorityAndDeadline(
                            state.todos.where((todo) => todo.isDone).toList(),
                          );
                  
                          return ListView(
                            // Added padding to the bottom to move the last task out of the way of the add task floating action button
                            padding: const EdgeInsets.only(bottom: 85.0), // Adjust this value as needed
                            children: [
                              if (sortedPendingTodos.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Pending Tasks',
                                        style:
                                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        onTap:(){
                                          context.read<TodoBloc>().add(ClearAllTodos());
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                          child: Icon(CupertinoIcons.delete_simple),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Directly use TodoCard here
                                ...sortedPendingTodos.map((todo) =>
                                  TodoCard.forTodo(
                                    key: ValueKey(todo.id), // Unique key for efficiency
                                    todo: todo,
                                    originalIndex: state.todos.indexOf(todo), // Pass the original index from the main list
                                    onDelete: () => removeTodo(todo),
                                    onToggleCompletion: () => alertTodo(state.todos.indexOf(todo)),
                                    hasSubtasks: todo.subtasks.isNotEmpty,
                                    onSubTaskToggleCompletion: (subtask, subTaskIndex){
                                      context.read<TodoBloc>().add(
                                        CompleteSubTask(state.todos.indexOf(todo), subTaskIndex),
                                      );
                                    },
                                    onSubTaskDelete: (subtask, subTaskIndex){
                                      context.read<TodoBloc>().add(
                                        RemoveSubTask(state.todos.indexOf(todo), subTaskIndex),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              if (sortedCompletedTodos.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Completed Tasks',
                                    style:
                                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Directly use TodoCard here
                                ...sortedCompletedTodos.map((todo) =>
                                  TodoCard.forTodo(
                                    key: ValueKey(todo.id), // Unique key for efficiency
                                    todo: todo,
                                    originalIndex: state.todos.indexOf(todo), // Pass the original index from the main list
                                    onDelete: () => removeTodo(todo),
                                    onToggleCompletion: () => alertTodo(state.todos.indexOf(todo)),
                                    hasSubtasks: todo.subtasks.isNotEmpty,
                                    onSubTaskToggleCompletion: (subtask, subTaskIndex){
                                      context.read<TodoBloc>().add(
                                        CompleteSubTask(state.todos.indexOf(todo), subTaskIndex),
                                      );
                                    },
                                    onSubTaskDelete: (subtask, subTaskIndex){
                                      context.read<TodoBloc>().add(
                                        RemoveSubTask(state.todos.indexOf(todo), subTaskIndex),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          );
                        }
                      } else if (state.status == TodoStatus.initial) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}