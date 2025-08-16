import 'package:flutter/cupertino.dart';
import 'package:todo_app/utils/theme.dart';

class LabeledCupertinoTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final Color? bgColor;
  final bool? obscureText;
  
  const LabeledCupertinoTextField({
    super.key,
    required this.label,
    required this.controller,
    this.bgColor,
    this.obscureText,
  });

  @override
  State<LabeledCupertinoTextField> createState() => _LabeledCupertinoTextFieldState();
}

class _LabeledCupertinoTextFieldState extends State<LabeledCupertinoTextField> {
  late bool showText;

  @override
  void initState() {
    super.initState();
    // Initialize showText based on obscureText parameter
    showText = widget.obscureText ?? false;
  }

  void _togglePasswordVisibility() {
    setState(() {
      showText = !showText;
    });
  }

  Widget textField(bool obscureText){
    return CupertinoTextField(
      controller: widget.controller,
      obscureText: obscureText,
      autocorrect: false,
      style: const TextStyle(
        fontSize: 16, // Explicit font size for input text
      ),
      decoration: BoxDecoration(
        color: transparent,
        border: Border.all(color: transparent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showIcon = widget.obscureText ?? false;
    
    return Stack(
      children: [
        // Rounded container
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 5),
          decoration: BoxDecoration(
            border: Border.all(color: grey),
            borderRadius: BorderRadius.circular(15),
          ),
          child: showIcon
              ? Row(
                  children: [
                    Expanded(
                      child: textField(showText),
                    ),
                    GestureDetector(
                      onTap: _togglePasswordVisibility,
                      child: Icon(
                        showText ? CupertinoIcons.eye_solid : CupertinoIcons.eye_slash_fill,
                        color: grey,
                        size: 20, // Explicit icon size
                      ),
                    ),
                  ],
                )
              : textField(false),
        ),
        // Floating label
        Positioned(
          left: 16,
          top: 0,
          child: Container(
            color: widget.bgColor ?? white,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              widget.label,
              style: const TextStyle(
                color: blue,
                fontWeight: FontWeight.bold,
                fontSize: 15, // Keep consistent with original
              ),
            ),
          ),
        ),
      ],
    );
  }
}