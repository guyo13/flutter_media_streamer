import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_streamer/flutter_media_streamer.dart';
import 'package:flutter_media_streamer/model/android.dart';

import '../components.dart';

class ThumbnailsExample extends StatefulWidget {
  @override
  _ThumbnailsExampleState createState() => _ThumbnailsExampleState();
}

class _ThumbnailsExampleState extends State<ThumbnailsExample> {
  String _platformVersion = 'Unknown';
  // TODO - refactor this once ready
  List<String> _textResponse;
  List<AndroidImageMediaData> _response;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await FlutterMediaStreamer.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey("GetThumbnailDemo"),
      drawer: Drawer(
        child: Builder(
          builder: (context) {
            return ListView(
              children: [
                ListTile(
                  title: Text("Get Image example"),
                  onTap: () {
                    Navigator.of(context).pushNamed('/getImage');
                  },
                ),
              ],
            );
          },
        ),
      ),
      appBar: AppBar(
        title: const Text('Media Streamer thumbnail example'),
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Text('Running on: $_platformVersion\n'),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: FlatButton(
                    child: Text("Get images"),
                    onPressed: () async {
                      if (defaultTargetPlatform == TargetPlatform.iOS) {
                        final res = await FlutterMediaStreamer.instance
                            .rawImageMetadata(limit: 3).take(10)
                            .toList();
                        print(
                            "Got ${res.length} image metadata from iOS");
                        setState(() {
                          _textResponse = res;
                        });
                        for (var i in res) print(jsonDecode(i));
                      } else {
                        final res = await FlutterMediaStreamer.instance
                            .androidImagesMetadata(limit: 3).take(10)
                            .toList();
                        setState(() {
                          _response = res;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // FIXME - Android
          if (_response != null)
            Container(
              padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                children: [
                  for (var r in _response)
                    ThumbGridItem(
                      height: 200,
                      future: FlutterMediaStreamer.instance
                          .getThumbnail(r.contentUri),
                    )
                ],
              ),
            ),
          // FIXME - iOS
          if (_textResponse != null)
            Container(
              padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  if (index >= _textResponse.length) return null;
                  return ThumbGridItem(
                    height: 200,
                    future: FlutterMediaStreamer.instance
                        .getThumbnail(
                        (jsonDecode(_textResponse[index]) as Map<String, dynamic>)["localIdentifier"]
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
