import 'package:flutter/material.dart';

Future<bool> showYesNoDialog(
  BuildContext context, {
  String? title,
  String? content,
  String yesText = "Yes",
  String noText = "No",
}) async {
  // set up the button
  Widget yesButton = TextButton(
    child: Text(
      yesText,
      style: Theme.of(context).textTheme.titleSmall,
    ),
    onPressed: () => Navigator.of(context).pop(true),
  );

  Widget noButton = TextButton(
    child: Text(
      noText,
      style: Theme.of(context).textTheme.titleSmall,
    ),
    onPressed: () => Navigator.of(context).pop(false),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: title != null ? Text(title) : null,
    content: content != null ? Text(content) : null,
    actions: [
      noButton,
      yesButton,
    ],
  );

  // show the dialog
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      ) ??
      false;
}
