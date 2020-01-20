// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

// This imports widget that displays clock hands.
import 'custom_hand.dart';

// This imports center pin of the clock.
import 'stud.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

// These are Animation & Aimation Controller respectively for the hand that
// indicates the current Meridiem.
Animation<double> rotateAm2Pm;
AnimationController amPmHandController;

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
};

final _darkTheme = {
  _Element.bgColor1: Color(0xFF414042),
  _Element.bgColor2: Color(0xFF5f6062),
  _Element.text: Colors.white,
};

/// A basic analog clock.
///
/// I tried to do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock>
    with SingleTickerProviderStateMixin {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  var _meridiem;
  Timer _timer;
  String _activeHr;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);

    amPmHandController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    rotateAm2Pm =
        Tween<double>(begin: -0.25, end: 0).animate(amPmHandController);

    _updateMeridiem();
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

      _switchMeridiem();
      _updateActiveHr();

      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  // Check the current meridiem and updates the clock.
  void _updateMeridiem() {
    try {
      _meridiem = _now.hour < 12 ? 'am' : 'pm';
      _meridiem == 'am'
          ? amPmHandController.reverse()
          : amPmHandController.forward();
    } catch (e) {
      throw ('Faled to determine and update the current Meridiem. Error: $e');
    }
  }

  // Updates the meridiem when it changes at 12:00 hrs & 00:00 hrs.
  void _switchMeridiem() {
    _updateMeridiem();

    try {
      if (_now.hour == 12 && _now.minute == 00 && _meridiem == 'am') {
        amPmHandController.forward();
        _meridiem = 'pm';
      } else if (_now.hour == 00 && _now.minute == 00 && _meridiem == 'pm') {
        amPmHandController.reverse();
        _meridiem = 'am';
      }
    } catch (e) {
      throw ('Unable to determine the current Meridiem. Error: $e');
    }
  }

  // This function updates the active hour on clock by changing its color.
  void _updateActiveHr() {
    try {
      _activeHr = _now.hour == 01 || _now.hour == 13
          ? '01'
          : _now.hour == 02 || _now.hour == 14
              ? '02'
              : _now.hour == 03 || _now.hour == 15
                  ? '03'
                  : _now.hour == 04 || _now.hour == 16
                      ? '04'
                      : _now.hour == 05 || _now.hour == 17
                          ? '05'
                          : _now.hour == 06 || _now.hour == 18
                              ? '06'
                              : _now.hour == 07 || _now.hour == 19
                                  ? '07'
                                  : _now.hour == 08 || _now.hour == 20
                                      ? '08'
                                      : _now.hour == 09 || _now.hour == 21
                                          ? '09'
                                          : _now.hour == 10 || _now.hour == 22
                                              ? '10'
                                              : _now.hour == 11 ||
                                                      _now.hour == 23
                                                  ? '11'
                                                  : '12';
    } catch (e) {
      throw ('Failed to update Active Hour, hence can not update the display. Error: $e');
    }
  }

  // This function tries to determine the active hour and highlights it on
  // the clock when it succeeds.
  Widget _showActiveHr() {
    return _activeHr != null
        ? Center(
            child: Image(
              image: AssetImage('assets/images/active_$_activeHr.png'),
              fit: BoxFit.fitWidth,
            ),
          )
        : SizedBox(height: 0, width: 0);
  }

  // This function tries to determine the active meridiem and highlights it on
  // the clock when it succeeds.
  Widget _showActiveMeridiem() {
    return _meridiem != null
        ? Center(
            child: Image(
              image: AssetImage('assets/images/active_$_meridiem.png'),
              fit: BoxFit.fitWidth,
            ),
          )
        : SizedBox(height: 0, width: 0);
  }

  // This the the custom widget that displays the clock.
  Widget _infinityAnalogClock({@required colors}) {
    return Container(
      child: Stack(
        // This Stack contains the Clock and its Hands.
        alignment: Alignment.center,
        children: [
          // This contains Clock's render with dials.
          Center(
            child: Image(
              image: AssetImage(Theme.of(context).brightness == Brightness.light
                  ? 'assets/images/clock_frame_light.png'
                  : 'assets/images/clock_frame_dark.png'),
              fit: BoxFit.fitWidth,
            ),
          ),

          // Transform is used only to adjust dials in Portrait Mode.
          Transform.scale(
            scale: MediaQuery.of(context).orientation == Orientation.portrait
                ? 0.75
                : 1,
            child: Row(
              // this Row houses both hr, min & sec hands along with the one
              // that displays the curent meridiem.
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  // Meridiem Hand with Center Pin
                  width: 54,
                  height: 54,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Meridiem Hand
                        customHandAmPm(rotationAnimation: rotateAm2Pm),
                        // Center Pin.
                        stud(context),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 115),
                Container(
                  // Main Clock's Hands
                  width: 189,
                  height: 189,
                  child: Center(
                      child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Minute's Hand.
                      customHand(
                        xOffset: 0,
                        yOffset: -32,
                        angleRadians: _now.minute * radiansPerTick,
                        imagePath:
                            Theme.of(context).brightness == Brightness.light
                                ? 'assets/images/hand_min_light.png'
                                : 'assets/images/hand_min_dark.png',
                      ),
                      // Hour's Hand.
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
                      // Second's Hand
                      customHand(
                        xOffset: 0,
                        yOffset: -34,
                        angleRadians: _now.second * radiansPerTick,
                        imagePath: 'assets/images/hand_sec.png',
                      ),
                      // Center Pin.
                      stud(context),
                    ],
                  )),
                ),
              ],
            ),
          ),
          // This is Infinity symbol as the name of the clock.
          Center(
            child: Opacity(
              opacity:
                  Theme.of(context).brightness == Brightness.light ? 0.4 : 1,
              child: Image(
                image: AssetImage('assets/images/infinity.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          _showActiveHr(),
          _showActiveMeridiem(),
        ],
      ),

      // BG color Gradient.
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
          // The main Clock Widget.
          _infinityAnalogClock(colors: colors),
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
