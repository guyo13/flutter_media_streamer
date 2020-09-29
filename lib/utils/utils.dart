import 'dart:convert';

typedef JsonCallback = Future<Map<String, dynamic>>  Function(String);

Future<Map<String, dynamic>> defaultJsonDecode(String raw) async {
  return jsonDecode(raw) as Map<String, dynamic>;
}