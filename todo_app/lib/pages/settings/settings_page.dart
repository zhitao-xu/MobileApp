import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/constants/constants.dart';
import 'package:todo_app/firebase/forgot_password.dart';
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
  late final StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;

    // Listen to auth state changes and store the subscription
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? newUser) {
      if (!mounted) return; // safeguard
      setState(() {
        user = newUser;
      });
    });
  }
  
  @override
  void dispose() {
    _authSubscription.cancel(); // cancel to prevent memory leaks
    super.dispose();
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
        color: backgoundGrey,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // User profile
            buildContainer(
              context: context,
              items: [
                // Login/Account
                RowItem(
                  icon: Icon(CupertinoIcons.person_circle,),
                  title: user == null
                    ? Text("Login")
                    : Text(user!.displayName ?? user!.email ?? "User"),
                    fullWidthTappable: true,
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

                // change password
                if (user != null)
                  RowItem(
                    icon: Icon(CupertinoIcons.lock_circle,),
                    title: const Text('Change Password'),
                    fullWidthTappable: true,
                    onTap: () async{
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ForgotPassword(title: changePasswordTitle,)),
                      );
                    }
                  ),
                
                  // change password
                if(user != null)
                  RowItem(
                    icon: Icon(CupertinoIcons.stop_circle,),
                    title: const Text('Logout'),
                    fullWidthTappable: true,
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
                                  await authService.value.signOut();
                                  navigator.pop();
                                } catch (e) {
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
            SizedBox(height: 20,),
        
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