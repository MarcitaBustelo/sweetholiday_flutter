import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  final String name;

  const MenuScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Image.asset('assets/images/Galleta.png', height: 40), // TU LOGO AQUÍ
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Welcome back!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5C1E8A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.account_circle, color: Color(0xFF5C1E8A)),
                    onSelected: (value) {
                      switch (value) {
                        case 'profile':
                          Navigator.pushNamed(context, '/profile');
                          break;
                        case 'calendar':
                          Navigator.pushNamed(context, '/calendar');
                          break;
                        case 'request':
                          Navigator.pushNamed(context, '/request-absence');
                          break;
                        case 'punch':
                          Navigator.pushNamed(context, '/punch');
                          break;
                        case 'logout':
                          Navigator.pushReplacementNamed(context, '/login');
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'profile', child: Text('Profile')),
                      const PopupMenuItem(value: 'calendar', child: Text('See Calendar')),
                      const PopupMenuItem(value: 'request', child: Text('Request Absence')),
                      const PopupMenuItem(value: 'punch', child: Text('Punch In')),
                      const PopupMenuDivider(),
                      const PopupMenuItem(value: 'logout', child: Text('Logout')),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 🌄 Fondo con imagen decorativa + capa blanca translúcida
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo.png'), // imagen decorativa
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.85),
          ),

          // Contenido del menú
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _animatedMenuCard(context, Icons.calendar_today, 'See Calendar', 'View your absences.', '/calendar'),
                    _animatedMenuCard(context, Icons.person, 'Profile', 'Manage your info.', '/profile'),
                    _animatedMenuCard(context, Icons.email, 'Request Absence', 'Submit vacation requests.', '/request-absence'),
                    _animatedMenuCard(context, Icons.qr_code_scanner, 'Punch In', 'Scan QR to clock in/out.', '/punch'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedMenuCard(BuildContext context, IconData icon, String title, String description, String route) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 2 - 30,
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, route),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            color: Colors.white,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: const Color(0xFF5C1E8A)),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C1E8A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
