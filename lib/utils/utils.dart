// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:convert';

typedef JsonCallback = Future<Map<String, dynamic>>  Function(String);
typedef BatchJsonCallback = Future<Iterable<Map<String, dynamic>>>  Function(Iterable<String>);

Future<Map<String, dynamic>> defaultJsonDecode(String raw) async {
  return jsonDecode(raw) as Map<String, dynamic>;
}

Future<List<Map<String, dynamic>>> defaultBatchJsonDecode(Iterable<String> rawItems) async {
  final results = <Map<String, dynamic>> [];
  for (var item in rawItems) {
    results.add(jsonDecode(item) as Map<String, dynamic>);
  }
  return results;
}