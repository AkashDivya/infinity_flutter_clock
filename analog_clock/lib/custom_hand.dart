import 'package:flutter/material.dart';

Widget customHand({
  @required double angleRadians,
  @required String imagePath,
  @required double xOffset,
  @required double yOffset,
}) {
  return SizedBox(
    child: Transform.rotate(
      angle: angleRadians,
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(xOffset, yOffset),
        child: Container(
          child: Image(
            image: AssetImage(imagePath),
          ),
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: Offset(-2, 2),
                blurRadius: 5,
              ),
            ],
            borderRadius: BorderRadius.circular(7.5),
          ),
        ),
      ),
    ),
  );
}

Widget customHandAmPm({
  @required Animation<double> rotationAnimation,
}) {
  return SizedBox(
    child: RotationTransition(
      alignment: Alignment.center,
      turns: rotationAnimation,
      child: Transform.translate(
        offset: Offset(0.0, -6.5),
        child: Container(
          child: Image(
            image: AssetImage('assets/images/hand_ampm.png'),
          ),
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: Offset(-2, 2),
                blurRadius: 5,
              ),
            ],
            borderRadius: BorderRadius.circular(7.5),
          ),
        ),
      ),
    ),
  );
}
