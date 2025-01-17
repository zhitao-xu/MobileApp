import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/my_colors.dart';

GestureDetector AddTaskButton() {
  return GestureDetector(
    onTap: () {
      // Open Add Task View
      print("AddTaskView Call");
    },

    child: Material(
      borderRadius: BorderRadius.circular(40),
      elevation: 10,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(40)
        ),
        child:  Center(
          child: Icon(
            Icons.add,
            color: Colors.white, size: 40
            )
          ),
      )
    ),
  );
}
