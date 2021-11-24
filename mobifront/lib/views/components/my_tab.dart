import 'package:flutter/material.dart';
import 'package:mobifront/utils/utl.dart';

class MyTab extends StatelessWidget {
  final String label;
  final IconData? icon;
  final double? radius;
  final bool Function()? isSelected;

  const MyTab(
      {Key? key,
      required this.label,
      this.radius,
      this.icon,
      required this.isSelected})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool selected = isSelected == null ? false : isSelected!();
    double diameter = (radius ??
            (Utl.isMobile ? MediaQuery.of(context).size.width / 10 : 35)) *
        2;
    // forçar diâmetro maximo de 70
    if (diameter > 70) diameter = 70;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
            height: diameter * 0.7,
            width: diameter * 0.7,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(diameter / 2),
                color: (selected) ? Colors.white : Colors.blue[800]),
            padding: const EdgeInsets.all(8),
            duration: const Duration(seconds: 1),
            child: SizedBox(
                width: diameter * 0.8,
                child: icon != null
                    ? Icon(
                        icon,
                        color: (selected)
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        size: diameter * 0.4,
                      )
                    : Center(
                        child: Text(label,
                            style: Theme.of(context).textTheme.bodyText1!.apply(
                                fontSizeDelta: -2,
                                fontWeightDelta: (selected) ? 2 : -2,
                                color: (selected)
                                    ? Theme.of(context).primaryColor
                                    : Colors.white)),
                      ))),
        if (icon != null)
          Text(label,
              style: Theme.of(context).textTheme.bodyText1!.apply(
                  fontSizeDelta: -2,
                  fontWeightDelta: (selected) ? 2 : -2,
                  color: Colors.white))
      ],
    );
  }
}
