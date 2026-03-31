import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class Api {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> login(
    String role,
    String roll,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'role': role, 'roll': roll, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  static Future<void> signup(
    String role,
    String name,
    String roll,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'role': role,
          'name': name,
          'roll': roll,
          'password': password,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Signup failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Signup error: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchPyqOptions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pyq/options'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception('Failed to fetch PYQ options: ${response.body}');
    } catch (e) {
      throw Exception('PYQ options error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPyqs({
    required String year,
    required String branch,
    required String semester,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/pyq').replace(
        queryParameters: {'year': year, 'branch': branch, 'semester': semester},
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as List<dynamic>;
        return body.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }

      throw Exception('Failed to fetch PYQs: ${response.body}');
    } catch (e) {
      throw Exception('PYQ list error: $e');
    }
  }

  static Future<void> uploadPyq({
    required String uploaderRoll,
    required String year,
    required String branch,
    required String semester,
    required String subject,
    required String driveLink,
  }) async {
    try {
      final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/pyq'));
      req.fields['uploader_roll'] = uploaderRoll;
      req.fields['year'] = year;
      req.fields['branch'] = branch;
      req.fields['semester'] = semester;
      req.fields['subject'] = subject;
      req.fields['drive_link'] = driveLink;

      final streamed = await req.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 201) {
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('PYQ upload error: $e');
    }
  }

  static String _clubPath(String clubName) => Uri.encodeComponent(clubName);

  static Future<Map<String, dynamic>> fetchClubAccess({
    required String clubName,
    required String studentRoll,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/clubs/${_clubPath(clubName)}/access',
    ).replace(queryParameters: {'student_roll': studentRoll});

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed club access fetch: ${response.body}');
    }
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  static Future<void> requestClubAccess({
    required String clubName,
    required String studentRoll,
    required String studentName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clubs/${_clubPath(clubName)}/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'student_roll': studentRoll,
        'student_name': studentName,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to request access: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchClubMessages({
    required String clubName,
    required String studentRoll,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/clubs/${_clubPath(clubName)}/messages',
    ).replace(queryParameters: {'student_roll': studentRoll});

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch club messages: ${response.body}');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> sendClubMessage({
    required String clubName,
    required String studentRoll,
    required String sender,
    required String text,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clubs/${_clubPath(clubName)}/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'student_roll': studentRoll,
        'sender': sender,
        'text': text,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send club message: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchClubRequests({
    required String clubName,
    required String adminRoll,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/clubs/${_clubPath(clubName)}/requests',
    ).replace(queryParameters: {'admin_roll': adminRoll});

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch club requests: ${response.body}');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> decideClubRequest({
    required String clubName,
    required int requestId,
    required String adminRoll,
    required String action,
    required bool canSendMessage,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/clubs/${_clubPath(clubName)}/requests/$requestId/decision',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'admin_roll': adminRoll,
        'action': action,
        'can_send_message': canSendMessage,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to decide request: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchClubMembers({
    required String clubName,
    required String adminRoll,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/clubs/${_clubPath(clubName)}/members',
    ).replace(queryParameters: {'admin_roll': adminRoll});

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch club members: ${response.body}');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> updateClubMemberMessagePermission({
    required String clubName,
    required String studentRoll,
    required String adminRoll,
    required bool canSendMessage,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/clubs/${_clubPath(clubName)}/members/$studentRoll/message-permission',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'admin_roll': adminRoll,
        'can_send_message': canSendMessage,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update message permission: ${response.body}');
    }
  }
  // Add these methods to your Api class

  // static Future<void> sendOTP(String role, String rollNumber, String email) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/send-otp'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({
  //       'role': role,
  //       'roll_number': rollNumber,
  //       'email': email,
  //     }),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception(json.decode(response.body)['error'] ?? 'Failed to send OTP');
  //   }
  // }

  // static Future<void> verifyOTP(String rollNumber, String otp) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/verify-otp'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({
  //       'roll_number': rollNumber,
  //       'otp': otp,
  //     }),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception(json.decode(response.body)['error'] ?? 'Invalid OTP');
  //   }
  // }
}
