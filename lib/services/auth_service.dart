import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = 'http://172.20.10.2:8000/api';

  // LOGIN
  Future<Map<String, dynamic>> login(String employeeId, String password) async {
    final url = Uri.parse('$_baseUrl/loginApi');

    print('🌐 Enviando login a: $url');
    print('📦 Body: {"employee_id":"$employeeId","password":"$password"}');

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'employee_id': employeeId,
        'password': password,
      },
    );

    final data = jsonDecode(response.body);
    print('📥 Respuesta completa: $data');

    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['data']['token'];
      final name = data['data']['name'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return {
        'success': true,
        'name': name,
        'token': token,
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Login failed',
        'errors': data['errors'] ?? {},
      };
    }
  }

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String nif,
    required String delegationId,
    required String password,
    required String confirmPassword,
  }) async {
    final url = Uri.parse('$_baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'NIF': nif,
        'delegation_id': delegationId,
        'password': password,
        'c_password': confirmPassword,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['data']['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
        'errors': data['data'] ?? {}
      };
    }
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final url = Uri.parse('$_baseUrl/logout');
      await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      await prefs.remove('token');
    }
  }

  // CHEQUEAR SI ESTÁ LOGUEADO
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  // OBTENER EL TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
