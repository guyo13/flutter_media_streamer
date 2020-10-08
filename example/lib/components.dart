// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/material.dart';

class ThumbGridItem extends StatelessWidget {
  final Future<Uint8List> future;
  final double height;
  final double width;

  const ThumbGridItem({Key key, @required this.future, this.height, this.width})
      : assert(future != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this.future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.data != null) {
              return Container(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
                  child: Image.memory(
                    snapshot.data,
                    width: width,
                    height: height,
                  ));
            } else {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text("Awww Something\nbad happened"),
              );
            }
            break;
          default:
            return Container(child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}