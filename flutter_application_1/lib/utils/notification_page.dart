import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/local_notification_manager.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: (){
                LocalNotificationManager.showInstantNotification(
                  "Instant Notification", "This shows an instant notification");
              },
              child: const Text("Show Notification"),
            ),
            SizedBox(height: 12,),
            ElevatedButton(
              onPressed: (){
                DateTime scheduleDate = DateTime.now().add(Duration(seconds: 5));
                LocalNotificationManager.scheduleNotification("Scheduled Notification", "This notification is scheduled", scheduleDate);
              },
              child: const Text("Schedule Notification Delay of 5s"),
            ),
          ],
        ),
      )
    );
  }
}