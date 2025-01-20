import 'package:flutter/material.dart';
import 'package:flutter_application_1/widget/custom_app_bar.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(300),
        child: CustomAppBar(
          title: const Text('Analytics'),
        ),
      ),
    );
  }
}