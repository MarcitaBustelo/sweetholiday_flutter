import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl;
  final String? token;

  UserService({required this.baseUrl, required this.token});

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // Ver ausencias y festivos (calendario)
  Future<Map<String, dynamic>> fetchHolidayData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/holidays'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error fetching holiday data');
    }
  }

  // Ver perfil
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error fetching user profile');
    }
  }

  // Solicitar ausencia por correo
  Future<Map<String, dynamic>> requestAbsence({
    required String reason,
    required String startDate,
    required String endDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/vacation-request'),
      headers: headers,
      body: jsonEncode({
        'reason': reason,
        'start_date': startDate,
        'end_date': endDate,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 422) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error sending absence request');
    }
  }
}
