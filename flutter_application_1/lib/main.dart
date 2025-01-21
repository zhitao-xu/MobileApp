import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/local_notification_manager.dart';
import 'package:flutter_application_1/utils/notification_page.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/main_wrapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/bloc/bottom_nav.dart';
import 'package:timezone/data/latest.dart' as tz;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationManager.init();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Today',

      theme: Themes.light,
      themeMode: ThemeMode.light,


      home: BlocProvider(
        create: (context) => BottomNav(),
        child: const MainWrapper(),
        // child: const SettingsPage()
        
        // test notification
        // child: NotificationPage(),
      ),
    );
  }
}