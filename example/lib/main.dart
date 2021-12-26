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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: VideoCall(
          API_KEY: "47408431",
          SESSION_ID: "2_MX40NzQwODQzMX5-MTY0MDQ5NjA4Mzc0OH5QYXgzUUsvbWRCQ09LZ2tUWk0rVUxPUE5-fg",
          TOKEN: "T1==cGFydG5lcl9pZD00NzQwODQzMSZzaWc9YWFhZTNmMGFiNzdlNjNjMjNjOGE0OTY1MzA0YThlZDQ0YzRkZjdiNDpzZXNzaW9uX2lkPTJfTVg0ME56UXdPRFF6TVg1LU1UWTBNRFE1TmpBNE16YzBPSDVRWVhnelVVc3ZiV1JDUTA5TFoydFVXazByVlV4UFVFNS1mZyZjcmVhdGVfdGltZT0xNjQwNDk2MTAxJm5vbmNlPTAuNjYwMjE4ODQwNTY3MjUzOCZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNjQwNTE3NzAyJmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9",
        )
      ),
    );
  }
}
