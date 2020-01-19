import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'comet_controller.dart';
import 'sun_controller.dart';

class CosmicClock extends StatefulWidget {
  const CosmicClock(this.model);

  final ClockModel model;

  @override
  _CosmicClockState createState() => _CosmicClockState();
}

class _CosmicClockState extends State<CosmicClock> {
  DateTime _dateTime = DateTime.now();
  // Custom animation Controllers
  CometController _cometController;
  SunController _sunController;

  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _cometController = CometController();
    _sunController = SunController();
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(CosmicClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model
      ..removeListener(_updateModel)
      ..dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {});
  }

  void _updateTime() {
    setState(() {
      // the clock is ticking
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      _cometController.fullDay = widget.model.is24HourFormat;
      _sunController.fullDay = widget.model.is24HourFormat;

      _cometController.dateTime = _dateTime;
      _sunController.dateTime = _dateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FlareActor(
            'assets/comet.flr',
            controller: _cometController,
            alignment: Alignment.center,
            fit: BoxFit.fitHeight,
          ),
          FlareActor(
            'assets/sun.flr',
            controller: _sunController,
            fit: BoxFit.fitHeight,
          )
        ],
      ),
    );
  }
}
