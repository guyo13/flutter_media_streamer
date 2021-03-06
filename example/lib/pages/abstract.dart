// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_streamer/flutter_media_streamer.dart';

import '../components.dart';

List<Map<String, dynamic>> decodeBatch(Iterable<String> rawItems) {
  final results = <Map<String, dynamic>>[];
  for (var item in rawItems) {
    results.add(jsonDecode(item) as Map<String, dynamic>);
  }
  return results;
}

Future<List<Map<String, dynamic>>> computeBatchJson(
    Iterable<String> rawItems) async {
  return await compute(decodeBatch, rawItems);
}

class AbstractionExample extends StatefulWidget {
  @override
  _AbstractionExampleState createState() => _AbstractionExampleState();
}

class _AbstractionExampleState extends State<AbstractionExample> {
  String _platformVersion = 'Unknown';
  List<AbstractMediaItem> _response;

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
      key: ValueKey("AbstractionDemo"),
      appBar: AppBar(
        title: const Text('Media Streamer'),
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
                  title: Text("Get Thumbnail example"),
                  onTap: () {
                    Navigator.of(context).pushNamed('/getThumbnail');
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
                      final res = await FlutterMediaStreamer.instance
                          .streamImageMetadata(
                              batchConvert: true,
                              batchJsonDecodeFn: computeBatchJson)
                          .take(100)
                          .toList();
                      print(
                          "Got ${res.length} image metadata items from platform");
                      setState(() {
                        _response = res;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_response != null)
            Container(
              padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  if (index >= _response.length) return null;
                  return ThumbGridItem(
                    height: 200,
                    future: FlutterMediaStreamer.instance
                        .getThumbnail(_response[index].mediaQueryIdentifier),
                  );
                },
                itemCount: _response.length,
              ),
            ),
        ],
      ),
    );
  }
}
