import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

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

  final String baseUrl =
      'https://sweetholidays-production-f2f2.up.railway.app/api'; // 🔁 CAMBIA esto a tu URL real
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Añade token si usas autenticación
  };

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

  Future<void> _scanArrival(String employeeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/scan-qr'),
        headers: headers,
        body: jsonEncode({'employee_id': employeeId}),
      );

      final data = jsonDecode(response.body);

      String message;
      if (response.statusCode == 201) {
        message = '✅ Llegada registrada correctamente.';
      } else if (response.statusCode == 200) {
        message = '✅ Salida registrada correctamente.';
      } else {
        message = data['message'] ?? 'Error inesperado.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR code'),
        backgroundColor: const Color(0xFF5C1E8A),
        centerTitle: true,
      ),
      body: !_hasPermission
          ? const Center(
              child:
                  Text('Camera permit denied', style: TextStyle(fontSize: 16)),
            )
          : Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: (BarcodeCapture capture) async {
                    final code = capture.barcodes.first.rawValue;
                    if (code != null && code != scannedCode) {
                      _controller.stop(); // Pausa escáner temporalmente
                      setState(() => scannedCode = code);
                      await _scanArrival(code);
                      await Future.delayed(const Duration(seconds: 2));
                      _controller.start(); // Reanuda escáner si quieres
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
                      child: Text(
                        'Scanned: $scannedCode',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
