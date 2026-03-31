import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/api_config.dart';

const baseUrl = ApiConfig.baseUrl;

Future<List<String>> login(String roll) async {
  final res = await http.post(
    Uri.parse("$baseUrl/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"roll": roll}),
  );

  final data = jsonDecode(res.body);
  return List<String>.from(data["groups"]);
}

Future<List<dynamic>> fetchMessages(String group) async {
  final res = await http.get(Uri.parse("$baseUrl/messages/$group"));
  return jsonDecode(res.body);
}

Future<void> sendMessage(String group, String sender, String msg) async {
  await http.post(
    Uri.parse("$baseUrl/messages/$group"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "sender": sender,
      "message": msg,
    }),
  );
}
