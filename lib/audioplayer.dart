import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef void TimeChangeHandler(Duration duration);
typedef void ErrorHandler(String message);

class AudioPlayer {
  static const MethodChannel _channel =
      const MethodChannel('bz.rxla.flutter/audio');

  TimeChangeHandler durationHandler;
  TimeChangeHandler positionHandler;
  VoidCallback startHandler;
  VoidCallback completionHandler;
  ErrorHandler errorHandler;

  // TODO ? use a notifier ?...
  //ValueNotifier<Duration> durationNotifier;

  AudioPlayer() {
    _channel.setMethodCallHandler(platformCallHandler);
    //durationNotifier = new ValueNotifier(new Duration());
  }

  Future<int> play(String url, {bool isLocal: false}) =>
      _channel.invokeMethod('play', {"url": url, "isLocal": isLocal});

  Future<int> pause() => _channel.invokeMethod('pause');

  Future<int> stop() => _channel.invokeMethod('stop');

  Future<int> mute(bool muted) => _channel.invokeMethod('mute', muted);

  Future<int> seek(double seconds) => _channel.invokeMethod('seek', seconds);

  void setDurationHandler(TimeChangeHandler handler) {
    durationHandler = handler;
  }

  void setPositionHandler(TimeChangeHandler handler) {
    positionHandler = handler;
  }


  void setStartHandler(VoidCallback callback) {
    startHandler = callback;
  }

  void setCompletionHandler(VoidCallback callback) {
    completionHandler = callback;
  }

  void setErrorHandler(ErrorHandler handler) {
    errorHandler = handler;
  }

  Future platformCallHandler(MethodCall call) async {
    //    print("_platformCallHandler call ${call.method} ${call.arguments}");
    switch (call.method) {
      case "audio.onDuration":
        final duration = new Duration(milliseconds: call.arguments);
        if (durationHandler != null) {
          durationHandler(duration);
        }
        //durationNotifier.value = duration;
        break;
      case "audio.onCurrentPosition":
        if (positionHandler != null) {
          positionHandler(new Duration(milliseconds: call.arguments));
        }
        break;
      case "audio.onStart":
        if (startHandler != null) {
          startHandler();
        }
        break;
      case "audio.onComplete":
        if (completionHandler != null) {
          completionHandler();
        }
        break;
      case "audio.onError":
        if (errorHandler != null) {
          errorHandler(call.arguments);
        }
        break;
      default:
        print('Unknowm method ${call.method} ');
    }
  }
}
