import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/utils/theme.dart';

class NavigatorAppBar extends StatelessWidget {
  const NavigatorAppBar({
    super.key,
    required this.title,
    this.widget,
  });

  final String title;
  final Widget? widget;

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
                onTap: () {
                  Navigator.pop(context);
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
                      child: Icon(CupertinoIcons.back),
                    ),
                  ),
                ),
              ),
              const Spacer(), // Pushes the title to the center
              Expanded(
                flex: 2, // Adjust the flex value as needed for spacing
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    title,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ),
                ),
              ),
              const Spacer(), // Ensures equal spacing on both sides of the title
              widget ?? const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}