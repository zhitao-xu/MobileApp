import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/constants/constants.dart';
import 'package:todo_app/firebase/sign_in_page.dart';
import 'package:todo_app/utils/theme.dart';
import 'package:todo_app/widget/navigator_app_bar.dart';
import 'package:todo_app/widget/row_container.dart';
import 'package:todo_app/firebase/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? user;

  @override
  void initState(){
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? newUser){
      setState(() {
        user = newUser;
      });
    });
  }

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
        
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            // User profile
            buildContainer(
              context: context,
              items: [
                // Login/Account - Always show this
                RowItem(
                  title: user == null
                    ? Text("Login")
                    : Text(user!.displayName ?? user!.email ?? "User"),
                  onTap: user == null
                    ? (){
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const SignInPage()),
                        );
                      }
                    : () { 
                        // TODO: profile page
                      },
                ),

                // Logout - Only show when user is logged in
                if (user != null)
                  RowItem(
                    title: const Text('Logout'),
                    onTap: () async {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                          title: Text(logoutTitle),
                          content: Text(logoutContent),
                          actions: [
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: (){
                                Navigator.of(context).pop();
                              },
                              child: const Text('No'),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              onPressed: () async {
                                final navigator = Navigator.of(context);
                                final scaffoldMessenger = ScaffoldMessenger.of(context);
                                
                                try {
                                  // Properly call signOut method
                                  await authService.value.signOut();
                                  navigator.pop();
                                } catch (e) {
                                  // Handle any potential errors
                                  navigator.pop();
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(content: Text('Error signing out: $e')),
                                  );
                                }
                              },
                              child: const Text('Yes')
                            )
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          
        
            Column(
              spacing: 20,
              children: [
                Text("Theme ??"),
                Text("Export Data"),
                Text("Import Data"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}