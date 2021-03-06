// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_streamer/flutter_media_streamer.dart';

import '../components.dart';

class ThumbnailsExample extends StatefulWidget {
  @override
  _ThumbnailsExampleState createState() => _ThumbnailsExampleState();
}

class _ThumbnailsExampleState extends State<ThumbnailsExample> {
  String _platformVersion = 'Unknown';
  List<IOSPHAsset> _iOSResponse;
  List<AndroidImageMediaData> _androidResponse;

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
      appBar: AppBar(
        title: const Text('Thumbnail example'),
      ),
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
                ListTile(
                  title: Text("Abstraction example"),
                  onTap: () {
                    Navigator.of(context).pushNamed('/');
                  },
                ),
              ],
            );
          },
        ),
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
                    child: Text("Get thumbnails"),
                    onPressed: () async {
                      if (defaultTargetPlatform == TargetPlatform.iOS) {
                        final res = await FlutterMediaStreamer.instance
                            .iOSImagesMetadata(limit: 3)
                            .take(100)
                            .toList();
                        setState(() {
                          _iOSResponse = res;
                        });
                        print("Got ${res.length} image metadata from iOS");
                      } else {
                        final res = await FlutterMediaStreamer.instance
                            .androidImagesMetadata(limit: 3)
                            .take(100)
                            .toList();
                        setState(() {
                          _androidResponse = res;
                        });
                        print(
                            "Got ${res.length} image metadata items from Android");
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // FIXME - Android
          if (_androidResponse != null)
            Container(
              padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  if (index >= _androidResponse.length) return null;
                  return ThumbGridItem(
                    height: 200,
                    future: FlutterMediaStreamer.instance
                        .getThumbnail(_androidResponse[index].contentUri),
                  );
                },
                itemCount: _androidResponse.length,
              ),
            ),
          // FIXME - iOS
          if (_iOSResponse != null)
            Container(
              padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  if (index >= _iOSResponse.length) return null;
                  return ThumbGridItem(
                    height: 200,
                    future: FlutterMediaStreamer.instance
                        .getThumbnail(_iOSResponse[index].localIdentifier),
                  );
                },
                itemCount: _iOSResponse.length,
              ),
            ),
        ],
      ),
    );
  }
}
