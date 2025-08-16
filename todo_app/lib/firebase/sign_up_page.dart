import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/constants/constants.dart';
import 'package:todo_app/firebase/auth_service.dart';
import 'package:todo_app/firebase/sign_in_page.dart';
import 'package:todo_app/utils/labeled_cupertino_text_field.dart';
import 'package:todo_app/utils/theme.dart';
import 'package:todo_app/widget/navigator_app_bar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String errorMassage = '';

  // TODO: make boarder of each empty text field red
 // final _formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void register() async{
    try{
      // Check if fields are empty
      if(_usernameController.text.isEmpty && _emailController.text.isEmpty && _passwordController.text.isEmpty){
        setState(() {
          errorMassage = "Make sure to complete all fields.";
        });
        return;
      }

      // Attempt to sign up
      await authService.value.registerWithEmailAndPassword(
        email: _emailController.text.trim(), 
        password: _passwordController.text
      );

      // Success registration popup
      if(!mounted) return;
      await showCupertinoDialog(
        context: context, 
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Login Successful'),
          content: Text('Hello ${_usernameController.text}.\n Welcome to the $appName '),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: const Text("OK")
            ),
          ],
        )
      );
      popPage();
      popPage();
      
    } on FirebaseAuthException catch (e){
      if (kDebugMode) {
        print("Error in Register(Email&Password) ${e.message}");
      }
      
      setState((){
        errorMassage = e.message ?? '';
      });
    }
  }

  void popPage(){
    Navigator.of(context).pop();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100), 
        child: NavigatorAppBar(title: 'Register',),
      ),
      body: Container(
        color: white,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, top: 130.0, right: 30, bottom: 30),
          child: Column(
            // TODO: maybe need spacing parameter
            children: [
              // basic email password registration
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  LabeledCupertinoTextField(
                    label: "username", 
                    controller: _usernameController,
                  ),
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
              const SizedBox(height: 40),
              // Registration Button
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: register, 
                  child: Text(
                    "Sign up",
                    style: TextStyle(
                      color: white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ),
              ),
              const SizedBox(height:10),
              // error message
              Text(
                errorMassage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: red,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height:40),
              // divider
              Row(
                children: [
                  const Expanded(child: Divider(endIndent: 10)),
                  Text(
                    "Sign up with", 
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
                    const TextSpan(text: "Already have an account? "),
                    TextSpan(
                      text: "Sig in",
                      style: const TextStyle(
                        color: lightBlue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignInPage(),
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