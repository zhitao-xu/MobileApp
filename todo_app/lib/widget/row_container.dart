import 'package:flutter/material.dart';
import 'package:todo_app/utils/theme.dart';

class RowItem {
  final Widget? icon;
  final Widget? title;
  final Widget? info;
  final VoidCallback? onTap;

  RowItem({this.icon, this.title, this.info, this.onTap});
}

Widget buildContainer({
  required BuildContext context,
  required List<RowItem> items,
}) {
  assert(items.isNotEmpty, 'At least one item must be provided');

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
        children: _buildRow(items),
      ),
    ),
  );
}

List<Widget> _buildRow(List<RowItem> items) {
  List<Widget> rows = [];
  for (int i = 0; i < items.length; i++) {
    final item = items[i];
    rows.add(
      InkWell(
        onTap: item.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (item.icon != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 10.0, 10.0),
                child: item.icon!,
              ),
            if (item.title != null) item.title!,
            const Spacer(),
            if (item.info != null) item.info!,
          ],
        ),
      ),
    );
    if (items.length > 1 && i < items.length - 1) {
      rows.add(myDivider());
    }
  }
  return rows;
}

Widget myDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: const Divider(
      color: grey,
      height: 1,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
    ),
  );
}