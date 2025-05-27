import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String? scannedCode;
  bool _hasPermission = false;
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  final String baseUrl = 'https://sweetholidays-production-f2f2.up.railway.app/api';

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  Future<void> _scanArrival(String scannedEmployeeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('⚠️ No token found. Please log in again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/user/scan-qr'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'employee_id': scannedEmployeeId}),
      );

      final data = jsonDecode(response.body);

      String message;
      if (response.statusCode == 201) {
        message = '✅ Arrival registered successfully.';
      } else if (response.statusCode == 200) {
        message = '✅ Departure registered successfully.';
      } else {
        message = data['message'] ?? 'Unexpected error occurred.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while trying to register: $e')),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: const Color(0xFF5C1E8A),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Logout',
          onPressed: _logout,
        ),
      ),
      body: !_hasPermission
          ? const Center(
              child: Text(
                'Camera permit denied',
                style: TextStyle(fontSize: 16),
              ),
            )
          : Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: (BarcodeCapture capture) async {
                    final code = capture.barcodes.first.rawValue;
                    if (code != null && code != scannedCode) {
                      _controller.stop();
                      setState(() => scannedCode = code);
                      await _scanArrival(code);
                    }
                  },
                ),
                if (scannedCode != null)
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Escaneado: $scannedCode',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                scannedCode = null;
                              });
                              _controller.start(); 
                            },
                            child: const Text('Reset to Scan Another QR code'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
