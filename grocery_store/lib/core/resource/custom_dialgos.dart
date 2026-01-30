import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';

class CustomDialgos {
  static void showAlertDialog(
      {required BuildContext context,
      required String title,
      Widget? content,
      required Function onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: Theme.of(context).textTheme.bodyMedium,),
          content: content,
          //actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: Text('cancelar', style: Theme.of(context).textTheme.bodyMedium,),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('aceptar', style: Theme.of(context).textTheme.bodyMedium,),
              onPressed: () => onConfirm()
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
