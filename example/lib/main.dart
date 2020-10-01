import 'package:flutter/material.dart';

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
          return ThumbnailsExample();
        },
        '/getImage': (BuildContext context) {
          return GetImageExample();
        }
      },
    );
  }
}


