import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  final String name;

  const MenuScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $name'),
        backgroundColor: const Color(0xFF5C1E8A),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Aquí haces el logout
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      backgroundColor: const Color(0xFFF2EAF7), // Color pastel de fondo
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              context,
              icon: Icons.calendar_today,
              title: 'See Calendar',
              description: 'View your absences in a calendar format.',
              onTap: () {
                Navigator.pushNamed(context, '/calendar');
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.person,
              title: 'Profile',
              description: 'View and manage your personal info.',
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.request_page,
              title: 'Request Absence',
              description: 'Send a vacation or absence request.',
              onTap: () {
                Navigator.pushNamed(context, '/request-absence');
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.qr_code,
              title: 'Punch In',
              description: 'Scan a QR code to clock in or out.',
              onTap: () {
                Navigator.pushNamed(context, '/punch');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String description,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF5C1E8A)),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C1E8A))),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
