import 'package:flutter/material.dart';

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