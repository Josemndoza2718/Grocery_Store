import 'package:flutter/material.dart';

void showFloatingMessage({
  required BuildContext context,
  required String message,
  Color color = Colors.white,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.up,
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      duration: const Duration(seconds: 2),
      backgroundColor: color,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 10,
          right: 10),
    ),
  );
}
