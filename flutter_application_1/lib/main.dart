import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/utils/local_notification_manager.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/main_wrapper.dart';
import 'package:flutter_application_1/bloc/bottom_nav.dart';
import 'package:flutter_application_1/todo_bloc/todo_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications
  await LocalNotificationManager.init();
  tz.initializeTimeZones();

  // Get the application's document directory
  final directory = await getApplicationDocumentsDirectory();

  // Wrap the directory with HydratedStorageDirectory
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(directory.path),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BottomNav()),
        BlocProvider(create: (context) => TodoBloc()..add(TodoStarted())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Today',
        theme: Themes.light,
        themeMode: ThemeMode.light,
        home: const MainWrapper(),
      ),
    );
  }
}
