import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:mobifront/utils/utl.dart';

class MyDialogs {
  static void showDialogError(BuildContext context, String title, String msg,
      [Function? onclose]) {
    // flutter defined function
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return BasicDialogAlert(
          title: Container(
              child: Column(
            children: <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              Text(
                title,
                style: TextStyle(fontSize: 24, color: Colors.red),
              ),
            ],
          )),
          content: Text(msg),
          actions: <Widget>[
            BasicDialogAction(
              title: Text("Fechar"),
              onPressed: () {
                Navigator.pop(context);
                if (onclose != null) onclose();
              },
            ),
          ],
        );
      },
    );
  }

  static void showDialogWarning(BuildContext context, String title, String msg,
      [Function? onclose]) {
    // flutter defined function
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return BasicDialogAlert(
          title: Container(
              color: Colors.yellow[50],
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.warning_outlined,
                    color: Colors.orange,
                    size: 64,
                  ),
                  Text(
                    title,
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ],
              )),
          content: Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            BasicDialogAction(
              title: Text("OK, Entendi."),
              onPressed: () {
                Navigator.pop(context);
                if (onclose != null) onclose();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> customDialog(BuildContext context, Widget body,
      [double height = 0]) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: height < 0
                    ? null
                    : height == 0
                        ? MediaQuery.of(context).size.height * 0.7
                        : height,
                child: SingleChildScrollView(child: body),
              ),
            );
          },
        ) ??
        false;
  }

  static Future<bool> showTimedDialog(
      BuildContext context, String title, String msg,
      [int seconds = 5]) async {
    return await showDialog(
            context: context,
            builder: (context) {
              Future.delayed(Duration(seconds: seconds), () {
                try {
                  Navigator.of(context).pop(true);
                } catch (e) {
                  Utl.log("erro", e);
                }
              });
              return AlertDialog(
                title: Text(title),
                content: Text(msg),
              );
            }) ??
        false;
  }

  static Future<bool> showDialogYesNo(
      BuildContext context, String title, String msg,
      {String labelYes = "SIM",
      String labelNo = "NÃO",
      double height: 32}) async {
    // calcular a largura do botão
    // double bwidth = 60 +
    //     (labelNo.length > labelYes.length ? labelNo.length : labelYes.length) *
    //         12.0;

    // flutter defined function
    return await showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return BasicDialogAlert(
          title: Text(title),
          content: Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            BasicDialogAction(
              title: Text(labelYes),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            BasicDialogAction(
              title: Text(labelNo),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
