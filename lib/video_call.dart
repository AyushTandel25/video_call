import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> _cancelSession() async {
    try {
      await platformMethodChannel.invokeMethod('cancelSession');
    } on PlatformException catch (e) {}
  }

  Size _getSize() {
    return MediaQuery.of(context).size;
  }

  @override
  void initState() {
    _initSession();
    platformMethodChannel.setMethodCallHandler(methodCallHandler);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
      width: size.width,
      child: _updateView(),
    );
  }

  Widget _updateView() {
    bool toggleVideoPressed = false;

    if (_sdkState== SdkState.LOGGED_OUT) {
      return ElevatedButton(
          onPressed: () {
            _initSession();
          },
          child: Text("Init session"));
    } else if (_sdkState == SdkState.WAIT) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_sdkState == SdkState.LOGGED_IN ||
        _sdkState == SdkState.ON_CALL) {
      if(Platform.isAndroid){
        return Stack(
          children: [
            const AndroidView(
              viewType: 'opentok-video-container',
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{},
              creationParams: {},
              creationParamsCodec: StandardMessageCodec(),
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              layoutDirection: TextDirection.ltr,
            ),
            _sdkState == SdkState.LOGGED_IN
                ? const Positioned(
                    top: 100.0,
                    child: Text(
                      "Connecting",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    ),
                  )
                : Container(),
            _sdkState == SdkState.ON_CALL
                ? Positioned(
                    bottom: _getSize().height * 0.1,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: _getSize().height * 0.08,
                          width: _getSize().height * 0.08,
                          child: FittedBox(
                            child: FloatingActionButton(
                              onPressed: () async {
                                await _toggleAudio();
                                setState(() {});
                              },
                              backgroundColor: Colors.white,
                              child: Icon(
                                _publishAudio
                                    ? Icons.mic_off_outlined
                                    : Icons.mic_none_outlined,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: SizedBox(
                            height: _getSize().height * 0.1,
                            width: _getSize().height * 0.1,
                            child: FittedBox(
                              child: FloatingActionButton(
                                onPressed: () async {
                                  await _cancelSession();
                                },
                                backgroundColor: Colors.red,
                                child: const Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: _getSize().height * 0.08,
                          width: _getSize().height * 0.08,
                          child: FittedBox(
                            child: FloatingActionButton(
                              onPressed: () async {
                                await _toggleVideo();
                              },
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.flip_camera_android_outlined,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
          alignment: Alignment.center,
        );
      }
      else{
        return Stack(
          children: [
            const UiKitView(
              viewType: 'opentok-video-container',
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{},
              creationParams: {},
              creationParamsCodec: StandardMessageCodec(),
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              layoutDirection: TextDirection.ltr,
            ),
            _sdkState == SdkState.LOGGED_IN
                ? const Positioned(
              top: 100.0,
              child: Text(
                "Connecting",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
            )
                : Container(),
            _sdkState == SdkState.ON_CALL
                ? Positioned(
              bottom: _getSize().height * 0.1,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: _getSize().height * 0.08,
                    width: _getSize().height * 0.08,
                    child: FittedBox(
                      child: FloatingActionButton(
                        onPressed: () async {
                          await _toggleAudio();
                          setState(() {});
                        },
                        backgroundColor: Colors.white,
                        child: Icon(
                          _publishAudio
                              ? Icons.mic_off_outlined
                              : Icons.mic_none_outlined,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SizedBox(
                      height: _getSize().height * 0.1,
                      width: _getSize().height * 0.1,
                      child: FittedBox(
                        child: FloatingActionButton(
                          onPressed: () async {
                            await _cancelSession();
                          },
                          backgroundColor: Colors.red,
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _getSize().height * 0.08,
                    width: _getSize().height * 0.08,
                    child: FittedBox(
                      child: FloatingActionButton(
                        onPressed: () async {
                          await _toggleVideo();
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.flip_camera_android_outlined,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
                : Container(),
          ],
          alignment: Alignment.center,
        );
      }
    } else {
      return Center(child: Text("ERROR"));
    }
  }
}

enum SdkState { LOGGED_OUT, LOGGED_IN, WAIT, ON_CALL, ERROR }
