import 'package:flutter/material.dart';
import 'package:sweetholiday_flutter/services/auth_service.dart'; // 👈 ajusta si tu ruta es distinta

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberMe = false;
  bool isLoading = false;

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E0B54),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cookie,
                    size: 80, color: Color.fromARGB(255, 135, 78, 21)),
                const SizedBox(height: 12),
                const Text(
                  'SWEET HOLIDAYS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C1E8A),
                  ),
                ),
                const SizedBox(height: 16),
                _buildMiniCalendar(),
                const SizedBox(height: 24),
                _buildTextField(
                  icon: Icons.badge,
                  hintText: 'Employee ID',
                  controller: _employeeIdController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  icon: Icons.lock,
                  hintText: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    const Text('Remember me'),
                  ],
                ),
                const SizedBox(height: 16),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _login,
                        icon: const Icon(Icons.login,
                            color: Colors.white), // Icono blanco
                        label: const Text(
                          'Log In',
                          style: TextStyle(color: Colors.white), // Texto blanco
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C1E8A), // Morado
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCalendar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'May 2025',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const ['M', 'T', 'W', 'T', 'F']
                .map((day) =>
                    Text(day, style: TextStyle(fontWeight: FontWeight.w500)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF5C1E8A)),
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _login() async {
    setState(() => isLoading = true);

    final employeeId = _employeeIdController.text.trim();
    final password = _passwordController.text.trim();

    final result = await _authService.login(employeeId, password);

    setState(() => isLoading = false);

    if (result['success'] && result['user'] != null) {
      final user = result['user'];
      final name = user['name'] ?? 'Usuario'; // Por si 'name' viene null

      Navigator.pushReplacementNamed(
        context,
        '/menu',
        arguments: {'name': name},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al iniciar sesión.')),
      );
    }
  }
}
