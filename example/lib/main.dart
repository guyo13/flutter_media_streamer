// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_media_streamer_example/pages/abstract.dart';

import 'package:flutter_media_streamer_example/pages/image.dart';

import 'pages/thumbnails.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) {
          return AbstractionExample();
        },
        '/getThumbnail': (BuildContext context) {
          return ThumbnailsExample();
        },
        '/getImage': (BuildContext context) {
          return GetImageExample();
        }
      },
    );
  }
}
