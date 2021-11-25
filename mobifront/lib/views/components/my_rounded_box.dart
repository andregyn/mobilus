import 'package:flutter/material.dart';

class MyRoundedBox extends StatelessWidget {
  final Widget? child;
  final Color? color;

  const MyRoundedBox({Key? key, this.color, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color ?? const Color.fromARGB(255, 246, 247, 248),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color ?? Colors.grey.shade50)),
        child: child);
  }
}
