import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/analytics/stats/total_tasks_completed_widget.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/custom_app_bar.dart';
import 'package:flutter_application_1/pages/analytics/stats/on_time_percentage_chart.dart';
import 'package:flutter_application_1/pages/analytics/stats/activity_heatmap_widget.dart';


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
          title: "Analytics\n",
          isHome: false,
        ),
      ),

      body: Container(
        color: white,
        // Wrap the Column with SingleChildScrollView to allow scrolling if content overflows
        child: SingleChildScrollView( // <--- ADDED THIS WIDGET
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const TotalTasksCompletedWidget(),

                const SizedBox(height: 10),
                const OnTimePercentageChart(),

                const SizedBox(height: 20),
                const ActivityHeatmapWidget(),
                const SizedBox(height: 20), // Added some padding at the bottom for better scroll feel
                // You can add other analytics widgets below this one
              ],
            ),
          ),
        ),
      ),
    );
  }
}