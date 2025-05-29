import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserService {
  final String _baseUrl = 'https://sweetholidays-production-f2f2.up.railway.app/api';
  //https://sweetholidays-production-f2f2.up.railway.app/api/

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Obtener ausencias y festivos
  Future<Map<String, dynamic>> fetchHolidayData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {'success': false, 'message': 'Token no disponible'};
    }

    final url = Uri.parse('$_baseUrl/user/holidays');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'user': data['user'],
        'holidays': data['holidays'],
        'festives': data['festives'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Error when obtaining data',
      };
    }
  }

  /// Obtener perfil del usuario
  Future<UserProfile> fetchUserProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/user/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserProfile.fromJson(data);
    } else {
      throw Exception('Error al cargar perfil');
    }
  }

  /// Enviar solicitud de ausencia
  Future<Map<String, dynamic>> requestAbsence({
    required String reason,
    required String startDate,
    required String endDate,
  }) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'reason': reason,
      'start_date': startDate,
      'end_date': endDate,
    });

    final response = await http.post(
      Uri.parse('$_baseUrl/user/vacation-request'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 422) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error sending absence request');
    }
  }
}
