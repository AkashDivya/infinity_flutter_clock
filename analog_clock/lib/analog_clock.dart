// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

// import 'container_hand.dart';
// import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

enum _Element {
  background,
  text,
  shadow,
  primaryColor,
  highlightColor,
  accentColor,
  backgroundColor,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
  _Element.primaryColor: Color(0xFF4285F4),
  // Minute hand.
  _Element.highlightColor: Color(0xFF8AB4F8),
  // Second hand.
  _Element.accentColor: Color(0xFF669DF6),
  _Element.backgroundColor: Color(0xFFD2E3FC),
};

final _darkTheme = {
  _Element.background: Colors.grey,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
  _Element.primaryColor: Color(0xFFD2E3FC),
  // Minute hand.
  _Element.highlightColor: Color(0xFF4285F4),
  // Second hand.
  _Element.accentColor: Color(0xFF8AB4F8),
  _Element.backgroundColor: Color(0xFF3C4043),
};

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    final time = DateFormat.Hms().format(DateTime.now());
    final weatherInfo = DefaultTextStyle(
      style: TextStyle(color: colors[_Element.primaryColor]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_temperature),
          Text(_temperatureRange),
          Text(_condition),
          Text(_location),
        ],
      ),
    );
    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: colors[
            _Element.backgroundColor], //Here we will update the BG Gradient
        child: Stack(
          children: [
            Center(
              child: Image(
                image: AssetImage('assets/images/clock_frame_light.png'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 280,
                  child: Container(color: Colors.yellow.withOpacity(0.5)),
                ),
                Expanded(
                  flex: 158,
                  child: Container(child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.pink.withOpacity(0.5),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.cyan.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),),
                ),
                Expanded(
                  flex: 364,
                  child: Container(color: Colors.yellow.withOpacity(0.5)),
                ),
                Expanded(
                  flex: 588,
                  child: Container(child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.pink.withOpacity(0.5),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.cyan.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),),
                ),
                Expanded(
                  flex: 275,
                  child: Container(color: Colors.yellow.withOpacity(0.5)),
                ),



                // Container(
                //   /// Small Dial Center
                //   width: 53,
                //   // color: Colors.green.withOpacity(0.5),
                //   child: Row(
                //     children: <Widget>[
                //       Expanded(
                //         flex: 1,
                //         child: Container(
                //           color: Colors.pink.withOpacity(0.5),
                //         ),
                //       ),
                //       Expanded(
                //         flex: 1,
                //         child: Container(
                //           color: Colors.cyan.withOpacity(0.5),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // Container(
                //   width: 111,
                // ),
                // Container(
                //   /// Main Dial Center
                //   width: 184,
                //   // color: Colors.green.withOpacity(0.5),
                //   child: Row(
                //     children: <Widget>[
                //       Expanded(
                //         flex: 1,
                //         child: Container(
                //           color: Colors.pink.withOpacity(0.5),
                //         ),
                //       ),
                //       Expanded(
                //         flex: 1,
                //         child: Container(
                //           color: Colors.cyan.withOpacity(0.5),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),

            // Example of a hand drawn with [CustomPainter].
            // DrawnHand(
            //   color: colors[_Element.accentColor],
            //   thickness: 4,
            //   size: 1,
            //   angleRadians: _now.second * radiansPerTick,
            // ),
            // DrawnHand(
            //   color: colors[_Element.highlightColor],
            //   thickness: 4,
            //   size: 0.9,
            //   angleRadians: _now.minute * radiansPerTick,
            // ),
            // // Example of a hand drawn with [Container].
            // ContainerHand(
            //   color: Colors.transparent,
            //   size: 0.5,
            //   angleRadians: _now.hour * radiansPerHour +
            //       (_now.minute / 60) * radiansPerHour,
            //   child: Transform.translate(
            //     offset: Offset(0.0, 75),
            //     child: Container(
            //       width: 4,
            //       height: 150,
            //       decoration: BoxDecoration(
            //         color: colors[_Element.primaryColor],
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: weatherInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
