import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MyErrorContainer extends StatelessWidget {
  final String error;
  final Function? retry;

  const MyErrorContainer({
    Key? key,
    required this.error,
    this.retry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: 40.w,
            child: Center(
                child: Image.asset(
              'assets/images/sad_face.gif',
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "ERRO",
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .apply(color: Colors.red),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  error,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .apply(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          if (retry != null)
            Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: ElevatedButton(
                child: const Text("Tentar novamente"),
                onPressed: () {
                  Future.delayed(Duration.zero, () {
                    retry!();
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
