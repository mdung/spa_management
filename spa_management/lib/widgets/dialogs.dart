import 'package:flutter/material.dart';

class Dialogs {
  static void showConfirmationDialog(BuildContext context, String title, String message,
      VoidCallback onConfirm, {
        String confirmLabel = 'Confirm',
        String cancelLabel = 'Cancel',
      }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(cancelLabel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(confirmLabel),
              onPressed: onConfirm,
            ),
          ],
        );
      },
    );
  }

  static void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
