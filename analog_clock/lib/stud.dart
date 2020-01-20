import 'package:flutter/material.dart';

// This widget acts as the Center Pin for the Clock.
Widget stud(BuildContext context) {
  return Container(
    child: Image(
      image: AssetImage(Theme.of(context).brightness == Brightness.light
          ? 'assets/images/stud_light.png'
          : 'assets/images/stud_dark.png'),
    ),
    decoration: BoxDecoration(
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          offset: Offset(-2, 2),
          blurRadius: 3,
        ),
      ],
      borderRadius: BorderRadius.circular(7.5),
    ),
  );
}
