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
  SdkState _sdkState = SdkState.WAIT;
  bool _publishAudio = true;
  bool _publishVideo = true;
  DateTime previousTime = DateTime.now();

  static const platformMethodChannel = MethodChannel('com.example.video_call');

  Future<dynamic> methodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'updateState':
        {
          var arguments = 'SdkState.${methodCall.arguments}';
          _sdkState = SdkState.values.firstWhere((v) {
            return v.toString() == arguments;
          });
          // if (_sdkState == SdkState.LOGGED_OUT) {
          //   Navigator.pop(context);
          // }
          setState(() {});
        }
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  Future<void> _initSession() async {
    await requestPermissions();

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

  IconData getCameraSwitchWidget() {
    if (Platform.isAndroid) {
      return Icons.flip_camera_android_outlined;
    } else {
      return Icons.flip_camera_ios_outlined;
    }
  }

  Widget _updateView() {

    if (_sdkState == SdkState.WAIT) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_sdkState == SdkState.LOGGED_IN ||
        _sdkState == SdkState.ON_CALL) {
      if (Platform.isAndroid) {
        return Stack(
          children: [
            const AndroidView(
              viewType: 'video-container',
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
            Positioned(
              bottom: _getSize().height * 0.1,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VideoCallButtons(
                    onPress: () async {
                      await _toggleAudio();
                      setState(() {});
                    },
                    icon: _publishAudio
                        ? Icons.mic_off_outlined
                        : Icons.mic_none_outlined,
                    isCancelCall: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: VideoCallButtons(
                      onPress: () async {
                        await _cancelSession();
                      },
                      icon: Icons.call_end_outlined,
                      isCancelCall: true,
                    ),
                  ),
                  VideoCallButtons(
                    onPress: () async {
                      await _swapCamera();
                      setState(() {});
                    },
                    icon: getCameraSwitchWidget(),
                    isCancelCall: false,
                  ),
                ],
              ),
            ),
          ],
          alignment: Alignment.center,
        );
      } else {
        return Stack(
          children: [
            const UiKitView(
              viewType: 'video-container',
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
            Positioned(
              bottom: _getSize().height * 0.1,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VideoCallButtons(
                    onPress: () async {
                      await _toggleAudio();
                      setState(() {});
                    },
                    icon: _publishAudio
                        ? Icons.mic_off_outlined
                        : Icons.mic_none_outlined,
                    isCancelCall: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: VideoCallButtons(
                      onPress: () async {
                        await _cancelSession();
                      },
                      icon: Icons.call_end_outlined,
                      isCancelCall: true,
                    ),
                  ),
                  VideoCallButtons(
                    onPress: () async {
                      await _swapCamera();
                      setState(() {});
                    },
                    icon: getCameraSwitchWidget(),
                    isCancelCall: false,
                  ),
                ],
              ),
            ),
          ],
          alignment: Alignment.center,
        );
      }
    } else {
      return Container();
    }
  }
}

class VideoCallButtons extends StatelessWidget {
  final VoidCallback onPress;
  final IconData icon;
  final bool isCancelCall;

  const VideoCallButtons(
      {Key? key,
      required this.onPress,
      required this.icon,
      required this.isCancelCall})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isCancelCall
          ? MediaQuery.of(context).size.height * 0.1
          : MediaQuery.of(context).size.height * 0.08,
      width: isCancelCall
          ? MediaQuery.of(context).size.height * 0.1
          : MediaQuery.of(context).size.height * 0.08,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: onPress,
          backgroundColor: !isCancelCall ? Colors.white : Colors.red,
          child: Icon(
            icon,
            color: !isCancelCall ? Colors.black45 : Colors.white,
          ),
        ),
      ),
    );
  }
}

enum SdkState { LOGGED_OUT, LOGGED_IN, WAIT, ON_CALL, ERROR }
