// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:convert';

/// A definition of a Callback which converts a String to JSON (Map) Asynchronously
typedef JsonCallback = Future<Map<String, dynamic>>  Function(String);
/// A definition of a Callback which converts a batch of Strings to JSONs (Maps) Asynchronously
typedef BatchJsonCallback = Future<Iterable<Map<String, dynamic>>>  Function(Iterable<String>);

/// A default implementation of a [JsonCallback]
Future<Map<String, dynamic>> defaultJsonDecode(String raw) async {
  return jsonDecode(raw) as Map<String, dynamic>;
}

/// A default implementation of a [BatchJsonCallback]
Future<List<Map<String, dynamic>>> defaultBatchJsonDecode(Iterable<String> rawItems) async {
  final results = <Map<String, dynamic>> [];
  for (var item in rawItems) {
    results.add(jsonDecode(item) as Map<String, dynamic>);
  }
  return results;
}