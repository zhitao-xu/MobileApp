import 'package:flutter/material.dart';
import 'package:flutter_application_1/widget/custom_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(300),
        child: CustomAppBar(
          title: const Text('Today'),
        ),
      ),
    );
  }
}