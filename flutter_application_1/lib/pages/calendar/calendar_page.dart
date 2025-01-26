import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/custom_app_bar.dart';


class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: CustomAppBar(
          title: "Calendar\n",
          isHome: false,
        ),
      ),

      body: Container(
        color: white,
     ),
    );
  }
}