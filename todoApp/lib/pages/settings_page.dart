import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/navigator_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(300),
        child: NavigatorAppBar(
          title: "Settings",
        ),
      ),
        
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Theme"),
              Switch.adaptive(
                applyCupertinoTheme: false,
                value: light, 
                onChanged: (bool value){
                  setState(() {
                    light = value;
                  });
                }
              ),
            ],  
          ),
        ],
      ),
    );
  }
}