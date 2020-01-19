import 'package:flare_flutter/flare.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'dart:math';

class SunController extends FlareController {
  // animations: rotate / texture / lash / color / meteor_rotate / meteor_move
  int _ticker;
  int _colorTicker;
  bool fullDay = true;
  int _divisor;
  var _luckyStar = Random();
  int _trigger;
  bool _jackpot = false;
  DateTime dateTime;

  FlutterActorArtboard _artboard;

  // Comet animation will be giving the hour
  FlareAnimationLayer _sunRotation;
  FlareAnimationLayer _sunTexture;
  FlareAnimationLayer _sunColor;
  FlareAnimationLayer _miniSun;
  FlareAnimationLayer _meteorRotate;
  FlareAnimationLayer _meteorMove;

  @override
  void initialize(FlutterActorArtboard artboard) {
    // reference to artboard at startup
    if (artboard.name.compareTo('Sun') == 0) {
      _artboard = artboard;
      _sunRotation = FlareAnimationLayer()
        ..animation = _artboard.getAnimation('rotate')
        ..mix = 1.0;
      _sunTexture = FlareAnimationLayer()
        ..animation = _artboard.getAnimation('texture')
        ..mix = 1.0;
      _sunColor = FlareAnimationLayer()
        ..animation = _artboard.getAnimation('color')
        ..mix = 1.0;
      _colorTicker = dateTime.hour;
      if (_colorTicker >= 6 && _colorTicker < 18) {
        _sunColor.time = 0;
      } else if (_colorTicker >= 18 || _colorTicker < 6) {
        _sunColor.time = 1;
      }
      _miniSun = FlareAnimationLayer()
        ..animation = _artboard.getAnimation('sunny')
        ..mix = 1.0;
      _ticker = ((dateTime.minute / 59) * _miniSun.duration) ~/ 1;
      _miniSun.time = (_ticker).toDouble();
      _meteorMove = FlareAnimationLayer()
        ..animation = _artboard.getAnimation('meteor_move')
        ..mix = 1.0;
      _meteorRotate = FlareAnimationLayer()
        ..animation = _artboard.getAnimation('meteor_rotate')
        ..mix = 1.0;
    }
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    if (artboard.name.compareTo('Sun') == 0) {
      _sunRotation.time = (_sunRotation.time + elapsed) % _sunRotation.duration;
      _sunRotation.apply(artboard);
      _sunTexture.time = (_sunTexture.time + elapsed) % _sunTexture.duration;
      _sunTexture.apply(artboard);
      // changing the color based on time of day
      _colorTicker = dateTime.hour;
      if (_colorTicker >= 6 && _colorTicker < 18) {
        _sunColor.time = 0;
      } else if (_colorTicker >= 18 || _colorTicker < 6) {
        _sunColor.time = 1;
      }
      _sunColor.mix = 0.1;
      _sunColor.apply(artboard);
      //controlling the animation so it stops and advance when needed
      _ticker = ((dateTime.minute / 59) * _miniSun.duration) ~/ 1;
      //print('timeSeconds: $_ticker');
      _miniSun.time = (_ticker).toDouble();
      _miniSun.mix = 0.1;

      //meteorite indicating the hour of the day
      _trigger = _luckyStar.nextInt(666);
      if (_trigger == 0 || _trigger == 69 || _trigger == 420 && !_jackpot) {
        _jackpot = true;
        _meteorMove.time = 0;
      }
      if (_jackpot && _meteorMove.time < _meteorMove.duration) {
        _meteorMove.time = _meteorMove.time + elapsed;
      } else {
        _jackpot = false;
      }
      //_meteorMove.time = (_meteorMove.time + elapsed) % _meteorMove.duration;
      _meteorMove.apply(artboard);

      //rotate the meteorite to match hour
      _divisor = fullDay ? 24 : 12;
      _meteorRotate.time = _colorTicker / _divisor;
      /* _meteorRotate.time = 
          (_meteorRotate.time + elapsed) % _meteorRotate.duration; */
      _meteorRotate.apply(artboard);

      _miniSun.apply(artboard);
    }

    return true;
  }
}
