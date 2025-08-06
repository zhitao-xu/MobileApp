import 'package:flutter/cupertino.dart';
import 'package:todo_app/utils/theme.dart';

class NavigatorAppBar extends StatelessWidget {
  const NavigatorAppBar({
    super.key,
    required this.title,
    this.widget,
    this.onBackTap,
  });

  final String title;
  final Widget? widget;
  final Future<void> Function()? onBackTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: lightBlue,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 25,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if (onBackTap != null) {
                    await onBackTap!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: 60,
                  height: 60,
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(CupertinoIcons.back, color: white,),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                title,
                textAlign: TextAlign.center,
                style: homeTitleStyle,
              ),
              const Spacer(),
              widget ?? const SizedBox(width: 60, height: 50,),
            ],
          ),
        ),
      ),
    );
  }
}