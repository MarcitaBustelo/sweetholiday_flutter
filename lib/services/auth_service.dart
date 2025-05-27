import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl =
      'https://sweetholidays-production-f2f2.up.railway.app/api';
  //https://sweetholidays-production-f2f2.up.railway.app/api/

  // LOGIN
  Future<Map<String, dynamic>> login(String employeeId, String password) async {
    final url = Uri.parse('$_baseUrl/loginApi');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'employee_id': employeeId,
          'password': password,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']['token'];
        final name = data['data']['name'];
        final employeeIdFromResponse = data['data']['employee_id'];
        final departmentName = data['data']['department']; // <- añade esto

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('employee_id', employeeIdFromResponse);
        await prefs.setString('department', departmentName); // <- y esto

        return {
          'success': true,
          'name': name,
          'token': token,
          'employee_id': employeeIdFromResponse,
          'department': departmentName,
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return {
          'success': false,
          'message': data['message'] ?? 'Unauthorized',
          'errors': data['errors'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
          'errors': data['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Please try again later.',
        'errors': {'exception': e.toString()},
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

  // CAMBIAR CONTRASEÑA
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {
        'success': false,
        'message': 'No token found. Please log in again.',
      };
    }

    final url = Uri.parse('$_baseUrl/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Password change failed.',
          'errors': (data['errors'] is Map)
              ? Map<String, dynamic>.from(data['errors'])
              : {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
        'errors': {'exception': e.toString()},
      };
    }
  }
}
