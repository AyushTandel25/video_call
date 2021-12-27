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
              "1_MX40NzQwODQzMX5-MTY0MDU5OTI5Mjk1M35rbWhsQTNhWGdtVkszNWZNdlc3YWVtSmx-fg",
          TOKEN:
              "T1==cGFydG5lcl9pZD00NzQwODQzMSZzaWc9NDE4MTM3MzA4NmM2NTQ0YWM4YjUxNjMxNzYwNzM5MzJlMzUwODBjZjpzZXNzaW9uX2lkPTFfTVg0ME56UXdPRFF6TVg1LU1UWTBNRFU1T1RJNU1qazFNMzVyYldoc1FUTmhXR2R0Vmtzek5XWk5kbGMzWVdWdFNteC1mZyZjcmVhdGVfdGltZT0xNjQwNTk5MzE3Jm5vbmNlPTAuNjc5NDQ4MTk3NDQwODA3OCZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNjQwNjIwOTE2JmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9",
        ),
      ),
    );
  }
}
