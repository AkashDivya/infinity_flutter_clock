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

import 'custom_hand.dart';
import 'stud.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

enum _Element {
  bgColor1,
  bgColor2,
  text,
  shadow,
  primaryColor,
  highlightColor,
  accentColor,
  backgroundColor,
}

final _lightTheme = {
  _Element.bgColor1: Color(0xFFc0c2c4),
  _Element.bgColor2: Color(0xFFe4e5e6),
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
  _Element.bgColor1: Color(0xFF414042),
  _Element.bgColor2: Color(0xFF5f6062),
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

  Widget _analogClockLandscape({@required colors}) {
    return Container(
      // Here we will update the BG Gradient

      child: Stack(
        alignment: Alignment.center,
        children: [
          // This Stack will contain Clock render with Dials.
          Center(
            // Here clock render is placed.
            child: Image(
              image: AssetImage(Theme.of(context).brightness == Brightness.light
                  ? 'assets/images/clock_frame_light.png'
                  : 'assets/images/clock_frame_dark.png'),
              fit: BoxFit.fitWidth,
            ),
          ),
          Row(
            // Here dials are placed.
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                // AM, PM Dial
                width: 54,
                height: 54,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      customHand(
                        xOffset: 0,
                        yOffset: -6.5,
                        imagePath: 'assets/images/hand_ampm.png',
                        angleRadians: 0.0,
                      ),
                      stud(context),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 115),
              Container(
                // Main clock's Dial
                width: 189,
                height: 189,
                child: Center(
                    child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // Example of a hand drawn with [CustomPainter].

                    customHand(
                      xOffset: 0,
                      yOffset: -32,
                      angleRadians: _now.minute * radiansPerTick,
                      imagePath:
                          Theme.of(context).brightness == Brightness.light
                              ? 'assets/images/hand_min_light.png'
                              : 'assets/images/hand_min_dark.png',
                    ),
                    customHand(
                      xOffset: 0,
                      yOffset: -22,
                      angleRadians: _now.hour * radiansPerHour +
                          (_now.minute / 60) * radiansPerHour,
                      imagePath:
                          Theme.of(context).brightness == Brightness.light
                              ? 'assets/images/hand_hr_light.png'
                              : 'assets/images/hand_hr_dark.png',
                    ),
                    customHand(
                      xOffset: 0,
                      yOffset: -34,
                      angleRadians: _now.second * radiansPerTick,
                      imagePath: 'assets/images/hand_sec.png',
                    ),
                    stud(context),
                  ],
                )),
              ),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            colors[_Element.bgColor1],
            colors[_Element.bgColor2],
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
    );
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
      child: Stack(
        children: <Widget>[
          _analogClockLandscape(colors: colors),
          Positioned(
            left: 0,
            top: 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: weatherInfo,
            ),
          ),
        ],
      ),
    );
  }
}
