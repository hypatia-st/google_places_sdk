import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:google_places_sdk/google_places_sdk.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _placeName = "Unknown place";

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initPlaces();
  }

  Future<void> initPlaces() async {
    final client = await GooglePlacesSdk.initialize(
      androidApiKey: "<My Android API Key>",
      iosApiKey: "<My iOS API Key>",
    );
    final place = await client.getPlaceById('ChIJnQH53DoIZUgReQ0ap9xNHWY');
    setState(() {
      _placeName = place.name;
    });
  } 

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GooglePlacesSdk.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              Text('Place: $_placeName')
            ]
          ),
        ),
      ),
    );
  }
}
