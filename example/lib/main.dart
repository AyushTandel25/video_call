import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:video_call/video_call.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: VideoCall(
          API_KEY: "47408431",
          SESSION_ID:
              "1_MX40NzQwODQzMX5-MTY0MDYwNjQzNDI3NH51U1FFS3NqNXRDaHB3M3pSMEJKY2FwV2t-fg",
          TOKEN:
              "T1==cGFydG5lcl9pZD00NzQwODQzMSZzaWc9MTE4NTkwMTczODllNTk4Y2Y3YjQxN2YwODI1YTM5MGY5YWYyMjJkOTpzZXNzaW9uX2lkPTFfTVg0ME56UXdPRFF6TVg1LU1UWTBNRFl3TmpRek5ESTNOSDUxVTFGRlMzTnFOWFJEYUhCM00zcFNNRUpLWTJGd1YydC1mZyZjcmVhdGVfdGltZT0xNjQwNjA2NDUwJm5vbmNlPTAuNjAxNDU4Mzg5ODA1NDU3NyZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNjQwNjkyODQ4JmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9",
        ),
      ),
    );
  }
}
