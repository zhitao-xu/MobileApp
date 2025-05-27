import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/theme.dart';

Widget buildContainer({
  required BuildContext context,
  required List<Widget> icons,
  required List<Widget> title,
  required List<Widget> info,
  required List<VoidCallback> onTap,
}) {
  assert(icons.length == title.length && title.length == info.length && info.length == onTap.length, 'All lists must be of the same length');

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
    child: Container(
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: white,
        border: Border.all(color: white),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _buildRow(icons, title, info, onTap),
      ),
    ),
  );
}

List<Widget> _buildRow(
  List<Widget> icons,
  List<Widget> title,
  List<Widget> info,
  List<VoidCallback> onTap,
) {
  List<Widget> rows = [];
  
  for (int i = 0; i < icons.length; i++) {
    rows.add(
      InkWell(
        onTap: onTap[i],
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 10.0, 10.0, 10.0),
              child: icons[i],
            ),
            title[i],
            const Spacer(),
            info[i],
          ],
        ),
      ),
    );
    if(icons.length > 1){
      if (i < icons.length - 1) {
        rows.add(myDivider());
      }
    }
  }
  return rows;
}

Widget myDivider() {
  return const Divider(
    color: grey,
    height: 1,
    thickness: 0.5,
    indent: 16,
    endIndent: 16,
  );
}