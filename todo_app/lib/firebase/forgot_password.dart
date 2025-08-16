import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/constants/constants.dart';
import 'package:todo_app/firebase/sign_up_page.dart';
import 'package:todo_app/utils/labeled_cupertino_text_field.dart';
import 'package:todo_app/utils/theme.dart';
import 'package:todo_app/widget/navigator_app_bar.dart';

class ForgotPassword extends StatefulWidget{
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword>{
  final TextEditingController _emailController = TextEditingController();
  String errorMessage = '';

  @override
  void dispose(){
    _emailController.dispose();
    super.dispose();
  }

  void popPage(){
    Navigator.of(context).pop();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  } 

  void sendMail() async{
    try{
      if(_emailController.text.isEmpty){
        setState(() {
          errorMessage = "Make sure to enter the mail.";
        });
        return;
      } else if(!isValidEmail(_emailController.text.trim())){
        setState(() {
          errorMessage = "Please enter a valid email address.";
        });
        return;
      } else{
        setState(() {
          errorMessage = '';
        });
        
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
        
        if(!mounted) return;
        
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text(resetPasswordTitle),
            content: Text(resetPasswordContent),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: (){
                  Navigator.of(context).pop(); // Close dialog
                  popPage(); // Then pop the page
                },
                child: const Text("OK")
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e){
      if (kDebugMode) {
        print("Error in ResetPassword(Email) ${e.message}");
      }
      
      setState(() {
        if(e.code == 'user-not-found'){
          errorMessage = "No user found with this email address.";
        } else if(e.code == 'invalid-email'){
          errorMessage = "Please enter a valid email address.";
        } else {
          errorMessage = e.message ?? 'An error occurred. Please try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context){
     return Scaffold(
      backgroundColor: lightBlue,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100), 
        child: NavigatorAppBar(title: 'Password Recovery',),
      ),
      body: Container(
        color: white,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, top: 130.0, right: 30, bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Enter Email field
              LabeledCupertinoTextField(
                label: "email", 
                controller: _emailController,
              ),
              const SizedBox(height: 40,),
              // Send Email Recovery code field
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: sendMail, 
                  child: Text(
                    "Sent Mail",
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
