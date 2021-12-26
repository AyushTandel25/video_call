import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

// class VideoCall {
//   static const MethodChannel _channel = MethodChannel('video_call');
//
//   static Future<String?> get platformVersion async {
//     final String? version = await _channel.invokeMethod('getPlatformVersion');
//     return version;
//   }
// }

class OpenTokConfig {
  static String API_KEY = "";
  static String SESSION_ID = "";
  static String TOKEN = "";

  static void message() {
    print('You are Calling Static Method');
  }
}

class VideoCall extends StatefulWidget {
  final String API_KEY;
  final String SESSION_ID;
  final String TOKEN;
  // final VoidCallback onUpdateState;

  const VideoCall(
      {Key? key,
      required this.API_KEY,
      required this.SESSION_ID,
      required this.TOKEN})
      : super(key: key);

  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  SdkState _sdkState = SdkState.LOGGED_OUT;
  bool _publishAudio = true;
  bool _publishVideo = true;

  static const platformMethodChannel =
      const MethodChannel('com.example.video_call');

  Future<dynamic> methodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'updateState':
        {
          setState(() {
            var arguments = 'SdkState.${methodCall.arguments}';
            _sdkState = SdkState.values.firstWhere((v) {
              return v.toString() == arguments;
            });
          });
        }
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  Future<void> _initSession() async {
    await requestPermissions();

    String token = "ALICE_TOKEN";
    dynamic params = {
      'apiKey': widget.API_KEY,
      'sessionId': widget.SESSION_ID,
      'token': widget.TOKEN
    };

    try {
      await platformMethodChannel.invokeMethod('initSession', params);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _makeCall() async {
    try {
      await requestPermissions();

      await platformMethodChannel.invokeMethod('makeCall');
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> requestPermissions() async {
    await [Permission.microphone, Permission.camera].request();
  }

  Future<void> _swapCamera() async {
    try {
      await platformMethodChannel.invokeMethod('swapCamera');
    } on PlatformException catch (e) {}
  }

  Future<void> _toggleAudio() async {
    _publishAudio = !_publishAudio;

    dynamic params = {'publishAudio': _publishAudio};

    try {
      await platformMethodChannel.invokeMethod('toggleAudio', params);
    } on PlatformException catch (e) {}
  }

  Future<void> _toggleVideo() async {
    _publishVideo = !_publishVideo;
    _updateView();

    dynamic params = {'publishVideo': _publishVideo};

    try {
      await platformMethodChannel.invokeMethod('toggleVideo', params);
    } on PlatformException catch (e) {}
  }

  @override
  void initState() {
    _initSession();
    platformMethodChannel.setMethodCallHandler(methodCallHandler);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[SizedBox(height: 64), _updateView()],
      ),
    );
  }

  Widget _updateView() {
    bool toggleVideoPressed = false;

    if (_sdkState == SdkState.LOGGED_OUT) {
      return ElevatedButton(
          onPressed: () {
            _initSession();
          },
          child: Text("Init session"));
    } else if (_sdkState == SdkState.WAIT) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_sdkState == SdkState.LOGGED_IN) {
      return Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: PlatformViewLink(
              viewType: 'opentok-video-container', // custom platform-view-type
              surfaceFactory:
                  (BuildContext context, PlatformViewController controller) {
                return PlatformViewSurface(
                  controller: controller,
                  gestureRecognizers: const <
                      Factory<OneSequenceGestureRecognizer>>{},
                  hitTestBehavior: PlatformViewHitTestBehavior.opaque,
                );
              },
              onCreatePlatformView: (PlatformViewCreationParams params) {
                return PlatformViewsService.initSurfaceAndroidView(
                  id: params.id,
                  viewType: 'opentok-video-container',
                  // custom platform-view-type,
                  layoutDirection: TextDirection.ltr,
                  creationParams: {},
                  creationParamsCodec: StandardMessageCodec(),
                )
                  ..addOnPlatformViewCreatedListener(
                      params.onPlatformViewCreated)
                  ..create();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _swapCamera();
                },
                child: Text("Swap " "Camera"),
              ),
              ElevatedButton(
                onPressed: () {
                  _toggleAudio();
                },
                child: Text("Toggle Audio"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (!_publishAudio) return Colors.grey;
                      return Colors.white; // Use the component's default.
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _toggleVideo();
                },
                child: Text("Toggle Video"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (!_publishVideo) return Colors.grey;
                      return Colors.white; // Use the component's default.
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Center(child: Text("ERROR"));
    }
  }
}

enum SdkState { LOGGED_OUT, LOGGED_IN, WAIT, ON_CALL, ERROR }
