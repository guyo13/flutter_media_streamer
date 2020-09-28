import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_media_streamer/flutter_media_streamer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List<String> _response;
  Future<bool> _permissionsGranted;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _permissionsGranted =
        FlutterMediaStreamer.requestStoragePermissions(timeout: 10);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterMediaStreamer.platformVersion;
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
      home: Builder(
        builder: (context) {
          final size = MediaQuery.of(context).size;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Stack(
              children: [
                PositionedDirectional(child: Text('Running on: $_platformVersion\n'),
                  top: 16.0,
                ),
                PositionedDirectional(
                  top: 32.0,
                  child: Container(
                    child: FutureBuilder(
                      initialData: false,
                      future: _permissionsGranted,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            return snapshot.data
                                ? FlatButton(
                              child: Text("Get image"),
                              onPressed: () async {
                                final res = await FlutterMediaStreamer.instance
                                    .streamGalleryImages(limit: 1).toList();
                                setState(() {
                                  _response = res;
                                });
                              },
                            )
                                : FlatButton(
                              child: Text("Grant Storage Permissions"),
                              onPressed: () async {
                                setState(() {
                                  _permissionsGranted = FlutterMediaStreamer
                                      .requestStoragePermissions();
                                  _permissionsGranted
                                      .then((value) => setState(() {}));
                                });
                              },
                            );
                          default:
                            return CircularProgressIndicator();
                        }
                      },
                    ),
                  ),
                ),
                if (_response != null)
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
                    child: ListView(
                      children: [for (var r in _response) Text(r)],
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
