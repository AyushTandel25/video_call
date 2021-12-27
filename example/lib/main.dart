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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: VideoCall(
          API_KEY: "47408431",
          SESSION_ID:
              "2_MX40NzQwODQzMX5-MTY0MDU3NzI2NDM1N35GMm5xRVg4ODZKYW1TRncwNk52QkovcCt-fg",
          TOKEN:
              "T1==cGFydG5lcl9pZD00NzQwODQzMSZzaWc9MDEyNjA5ZjZlNzM1NmIyMTFjYjkxOGUwZGJlM2E0Yzc2NTM1N2IzNzpzZXNzaW9uX2lkPTJfTVg0ME56UXdPRFF6TVg1LU1UWTBNRFUzTnpJMk5ETTFOMzVHTW01eFJWZzRPRFpLWVcxVFJuY3dOazUyUWtvdmNDdC1mZyZjcmVhdGVfdGltZT0xNjQwNTc3Mjc4Jm5vbmNlPTAuMTI3NTQyNjg4NjE5NTU2MSZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNjQwNTk4ODc4JmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9",
        ),
      ),
    );
  }
}
