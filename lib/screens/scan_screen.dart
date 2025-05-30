import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  String? scannedCode;
  bool _hasPermission = false;
  bool _isLoading = false;
  
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final String baseUrl = 'https://sweetholidays-production-f2f2.up.railway.app/api';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _requestCameraPermission();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    _pulseController.dispose();
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
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    // Vibration feedback
    HapticFeedback.mediumImpact();

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
      Color snackBarColor;
      IconData icon;

      if (response.statusCode == 201) {
        message = '✅ Arrival registered successfully.';
        snackBarColor = Colors.green;
        icon = Icons.check_circle;
      } else if (response.statusCode == 200) {
        message = '✅ Departure registered successfully.';
        snackBarColor = Colors.blue;
        icon = Icons.logout;
      } else {
        message = data['message'] ?? 'Unexpected error occurred.';
        snackBarColor = Colors.red;
        icon = Icons.error;
      }

      if (!mounted) return;
      
      _showModernSnackBar(message, snackBarColor, icon);
      
    } catch (e) {
      if (!mounted) return;
      _showModernSnackBar(
        'Error while trying to register: $e',
        Colors.red,
        Icons.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showModernSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _logout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.orange),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('login');
    }
  }

  Widget _buildPermissionDenied() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5C1E8A), Color(0xFF8B3A9F)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.white70,
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera Permission Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Please grant camera permission to scan QR codes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _requestCameraPermission,
              icon: const Icon(Icons.settings),
              label: const Text('Grant Permission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5C1E8A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Stack(
      children: [
        // Dark overlay
        Container(
          color: Colors.black54,
        ),
        
        // Scanning frame
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Corner indicators
                ...List.generate(4, (index) {
                  final positions = [
                    {'top': -1.0, 'left': -1.0}, // Top-left
                    {'top': -1.0, 'right': -1.0}, // Top-right
                    {'bottom': -1.0, 'left': -1.0}, // Bottom-left
                    {'bottom': -1.0, 'right': -1.0}, // Bottom-right
                  ];
                  final pos = positions[index];
                  
                  return Positioned(
                    top: pos['top'],
                    left: pos['left'],
                    right: pos['right'],
                    bottom: pos['bottom'],
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C1E8A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
                
                // Animated scan line
                AnimatedBuilder(
                  animation: _scanLineAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanLineAnimation.value * 220,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFF5C1E8A),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        
        // Instructions
        Positioned(
          bottom: 150,
          left: 20,
          right: 20,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF5C1E8A),
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        color: Color(0xFF5C1E8A),
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Position QR code within the frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScannedResult() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF5C1E8A),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _isLoading ? Icons.hourglass_empty : Icons.check_circle,
                  color: _isLoading ? Colors.orange : Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QR Code Scanned',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: $scannedCode',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () {
                  setState(() {
                    scannedCode = null;
                  });
                  _controller.start();
                },
                icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.qr_code_scanner),
                label: Text(_isLoading ? 'Processing...' : 'Scan Another QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C1E8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'QR Scanner',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
          tooltip: 'Logout',
          onPressed: _logout,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.flash_on,
              color: Colors.white,
            ),
            tooltip: 'Toggle Flash',
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: !_hasPermission
          ? _buildPermissionDenied()
          : Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: (BarcodeCapture capture) async {
                    final code = capture.barcodes.first.rawValue;
                    if (code != null && code != scannedCode && !_isLoading) {
                      _controller.stop();
                      setState(() => scannedCode = code);
                      await _scanArrival(code);
                    }
                  },
                ),
                if (scannedCode == null) _buildScanningOverlay(),
                if (scannedCode != null) _buildScannedResult(),
              ],
            ),
    );
  }
}