import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/my_colors.dart';

class TaskWidget extends StatelessWidget {
  const TaskWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        // TODO: Navigate to Task View Editing Page 
      },
      child: AnimatedContainer(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withAlpha(80),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ), 
        duration: const Duration(milliseconds: 600),
        child: ListTile(
          // Check Icon
          leading:  GestureDetector(
            onTap: (){
              // TODO: Check or uncheck the task
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 0.8,),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
          ),
          
          // Task Title
          title: Padding(
            padding: const EdgeInsets.only(top:3, bottom: 5),
            child: Text(
              "Done",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                // decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        
          // Task Body
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Description
              Text(
                "This is a task description",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
              ),
      
              // Date of the Task
              Text(
                "Date",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
