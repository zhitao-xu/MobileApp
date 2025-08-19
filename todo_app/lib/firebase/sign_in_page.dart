import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/constants/constants.dart';
import 'package:todo_app/firebase/forgot_password.dart';
import 'package:todo_app/firebase/sign_up_page.dart';
import 'package:todo_app/pages/settings/settings_page.dart';
import 'package:todo_app/utils/labeled_cupertino_text_field.dart';
import 'package:todo_app/utils/theme.dart';
import 'package:todo_app/widget/navigator_app_bar.dart';

class SignInPage extends StatefulWidget{
    const SignInPage({super.key});
  
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String errorMessage = '';
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login() async {
    try {
      // Check if fields are empty
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          errorMessage = "Make sure to complete all fields.";
        });
        return;
      }
      
      // Attempt to sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Navigate to settings page
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        ),
      );
      
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("Firebase Auth Error: ${e.code} - ${e.message}");
      }
      
      String message;
      switch (e.code) {
        case "invalid-email":
          message = "The email address is not valid.";
          break;
        case "invalid-credential":
          message = "Invalid email or password. Please check your credentials.";
          break;
        case "user-disabled":
          message = "This account has been disabled.";
          break;
        case "too-many-requests":
          message = "Too many failed attempts. Please try again later.";
          break;
        case "network-request-failed":
          message = "Network error. Please check your connection.";
          break;
        default:
          message = "Login failed. Please try again.";
      }
      
      setState(() {
        errorMessage = message;
      });
    } catch (e) {

      if (kDebugMode) {
        print("Unexpected error: $e");
      }
      setState(() {
        errorMessage = "An unexpected error occurred. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100), 
        child: NavigatorAppBar(title: 'Login',),
      ),
      body: Container(
        color: white,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, top: 130.0, right: 30, bottom: 30),
          child: Column(
            // TODO maybe need spacing parameter
            children: [
              // basic email password registration
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  LabeledCupertinoTextField(
                    label: "email", 
                    controller: _emailController,
                  ),
                  LabeledCupertinoTextField(
                    label: "password", 
                    controller: _passwordController, 
                    obscureText: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: black, fontSize: 16),
                      text: 'Forgot Password?',
                      recognizer: TapGestureRecognizer()
                        ..onTap = (){
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ForgotPassword(title: forgotPasswordTitle,)
                            ),
                          );
                        },
                    ),
                  ),
                  const SizedBox(width: 10,),
                ],
              ),
              const SizedBox(height: 20),
              // Login Button
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: login, 
                  child: Text(
                    "Sign in",
                    style: TextStyle(
                      color: white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ),
              ),
              const SizedBox(height: 10,),
              // error message
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: red,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              // divider
              Row(
                children: [
                  const Expanded(child: Divider(endIndent: 10)),
                  Text(
                    "Login in with", 
                    style: TextStyle(
                      color: grey,
                      fontSize: 14,
                    ),
                  ),
                  const Expanded(child: Divider(indent: 10)),
                ],
              ),
              // TODO: google, facebook, apple registration 
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Working ..."),
                  ],
                ),
              ),
              // sign in option
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: black, fontSize: 16),
                  children: [
                    const TextSpan(text: "Don't have an account? "),
                    TextSpan(
                      text: "Create",
                      style: const TextStyle(
                        color: lightBlue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignUpPage(),
                            ),
                          );
                        },
                    ),
                  ]
                ),     
              ),
            ],
          ),
        ),
      ),
    );
  }
}