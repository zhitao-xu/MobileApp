import 'package:flutter/material.dart';
import 'package:todo_app/utils/theme.dart';
import 'package:todo_app/widget/custom_app_bar.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: CustomAppBar(
          title: "Analitics\n",
          isHome: false,
        ),
      ),

      body: Container(
        color: white,
      ),
    );
  }
}