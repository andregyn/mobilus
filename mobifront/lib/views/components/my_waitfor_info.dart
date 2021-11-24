import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MyWaitforInfo extends StatelessWidget {
  final String title;
  final String subtitle;

  const MyWaitforInfo({Key? key, required this.title, this.subtitle = ""})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h - 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor)),
            Text("Aguarde...", style: Theme.of(context).textTheme.headline5!),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .apply(color: Colors.grey)),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .apply(color: Colors.grey))
          ],
        ),
      ),
    );
  }
}
