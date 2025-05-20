import 'dart:convert';
import 'package:http/http.dart' as http;

class ArrivalService {
  final String baseUrl;
  final String? token;

  ArrivalService({required this.baseUrl, required this.token});

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> scanArrival({required String employeeId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/scan-qr'),
      headers: headers,
      body: jsonEncode({
        'employee_id': employeeId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrar la llegada/salida');
    }
  }
}
