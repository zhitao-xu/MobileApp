import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_application_1/utils/my_colors.dart';
import 'package:flutter_application_1/utils/my_constants.dart';
import 'package:flutter_application_1/utils/my_strings.dart';
import 'package:flutter_application_1/views/home/components/add_task_button.dart';
import 'package:flutter_application_1/extensions/space_extensions.dart';
import 'package:flutter_application_1/views/home/widget/task_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final List<int> testing = [];

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,

      // Add Button: -> add task functionality
      floatingActionButton: AddTaskButton(),

      // Body
      body: _buildHomeBody(textTheme),
    );
  }

  // Home Body
  Widget _buildHomeBody(TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          // Custom App Bar
          Container(
            margin: EdgeInsets.only(top: 65),
            width: double.infinity,
            height: 100,
            //color: Colors.red,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Progress Indicator
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    value: 1/3,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation(
                      AppColors.primaryColor
                    ),
                  ),
                ),
                
                // Space: 25 width
                25.w,

                // Top Level Task Information
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MyString.mainTitle,
                      style: textTheme.displayLarge,
                    ),
                    3.h,
                    Text(
                      "1 of 3 tasks ", 
                      style: textTheme.titleMedium,
                    )
                  ],
                )
              ],
            )
          ),
        
          // Divider
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Divider(
              //color: Colors.grey, // default color
              thickness: 2,
              //indent: 100,
            ),
          ),
        
          // Task List
          SizedBox(
            width: double.infinity,
            height: 745, // obviously cannot be infinite xD
            child: testing.isNotEmpty
            // if there are tasks
              ? ListView.builder(
                itemCount: testing.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index){
                  // removeble "task widget"
                  return Dismissible(
                    direction: DismissDirection.horizontal,
                    onDismissed: (_){
                      // TODO: remove current task from db
                    },

                    // deletion message on background
                    background: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          color: Colors.grey,
                        ),
                        8.w,
                        const Text(
                          MyString.deletedTask,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),

                    key: Key(
                      index.toString()
                    ),
                    child: const TaskWidget()
                  );
                },
              )
              // if there are no tasks
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeIn(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child:  Lottie.asset(
                        lottieURL, 
                        animate: testing.isNotEmpty ? false : true
                      ),
                    ),
                  ),
                  FadeInUp( 
                    from: 30,
                    child: const Text(
                      MyString.doneAllTask,
                    ),
                  ),
                ],
              )
          ),
        ],
      ),
    );
  }
}


  