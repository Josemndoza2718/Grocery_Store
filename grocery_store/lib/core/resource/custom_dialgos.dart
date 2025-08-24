import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';

class CustomDialgos {
  static void showAlertDialog(
      {required BuildContext context,
      required String title,
      Widget? content,
      required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(title)),
          content: content,
          actions: <Widget>[
            TextButton(
              child: const Text('alert_cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('alert_confirm'),
              onPressed: () {
                onConfirm();
              },
            ),
          ],
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        );
      },
    );
  }
}
