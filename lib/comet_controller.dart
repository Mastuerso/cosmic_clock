import 'package:flare_flutter/flare.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:intl/intl.dart';

class CometController extends FlareController {
  //Animations: Flow / Rotate / Color / Blink
  DateTime dateTime;
  bool fullDay = true;
  int _colorTicker;

  FlutterActorArtboard _artboard;

  // Comet animation will be giving the time of the day
  FlareAnimationLayer _cometTravel;
  FlareAnimationLayer _cometFlow;
  FlareAnimationLayer _cometColor;
  FlareAnimationLayer _starsBlink;

  @override
  void initialize(FlutterActorArtboard artboard) {
    // reference to artboard at startup
    if (artboard.name.compareTo('Comet') == 0) {
      _artboard = artboard;
      _cometTravel = FlareAnimationLayer()
        ..animation = _artboard.getAnimation('Rotate')
        ..mix = 1.0;
      _cometFlow = FlareAnimationLayer()
        ..animation = _artboard.getAnimation('Flow')
        ..mix = 1.0;
      _cometColor = FlareAnimationLayer()
        ..animation = _artboard.getAnimation('Color')
        ..mix = 1.0;
      _colorTicker = dateTime.hour;
      if (_colorTicker >= 6 && _colorTicker < 18) {
        _cometColor.time = 0;
      } else if (_colorTicker >= 18 || _colorTicker < 6) {
        _cometColor.time = 1;
      }
      _starsBlink = FlareAnimationLayer()
        ..animation = _artboard.getAnimation('Blink')
        ..mix = 1.0;
    }
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    if (artboard.name.compareTo('Comet') == 0) {
      _cometTravel.time = timePercentage() * _cometTravel.duration;
      _cometTravel.mix = 1;

      _cometTravel.apply(artboard);

      _cometFlow.time = (_cometFlow.time + elapsed) % _cometFlow.duration;
      _cometFlow.apply(artboard);

      _starsBlink.time = (_starsBlink.time + elapsed) % _starsBlink.duration;
      _starsBlink.apply(artboard);

      _colorTicker = dateTime.hour;
      if (_colorTicker >= 6 && _colorTicker < 18) {
        _cometColor.time = 0;
      } else if (_colorTicker >= 18 || _colorTicker < 6) {
        _cometColor.time = 1;
      }
      _cometColor.mix = 0.1;
      _cometColor.apply(artboard);
    }

    return true;
  }

  double timePercentage() {
    // Advance the animation following time
    double percentage;
    int hour =
        fullDay ? dateTime.hour : int.parse(DateFormat('hh').format(dateTime));
    int minute = dateTime.minute;
    int second = dateTime.second;
    if (fullDay) {
      percentage = second / (59 * 59 * 23) + minute / (59 * 23) + hour / 23;
    } else {
      percentage = second / (59 * 59 * 12) + minute / (59 * 12) + hour / 12;
    }
    return percentage;
  }
}
