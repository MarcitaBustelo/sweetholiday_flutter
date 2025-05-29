import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  final String name;

  const MenuScreen({super.key, required this.name});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuart));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting = hour < 12
        ? "Good Morning"
        : hour < 18
            ? "Good Afternoon"
            : "Good Evening";

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4C1A57),
              Color(0xFF3E0B54),
              Color(0xFF2A0A3D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildMenuContent(greeting),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Image.asset(
              'assets/images/Galleta.png',
              height: 32,
              width: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.cookie_outlined,
                  color: Colors.white,
                  size: 32,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SWEET HOLIDAYS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _buildProfileMenu(),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(
          Icons.account_circle_outlined,
          color: Colors.white,
          size: 28,
        ),
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 20,
        color: Colors.white,
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
            case 'changePassword':
              Navigator.pushNamed(context, '/change-password');
              break;
            case 'logout':
              Navigator.pushReplacementNamed(context, '/login');
              break;
          }
        },
        itemBuilder: (context) => [
          _buildPopupMenuItem(Icons.person_outline, 'Profile', 'profile'),
          _buildPopupMenuItem(
              Icons.calendar_today_outlined, 'See Calendar', 'calendar'),
          _buildPopupMenuItem(
              Icons.email_outlined, 'Request Absence', 'request'),
          _buildPopupMenuItem(
              Icons.qr_code_scanner_outlined, 'Punch In', 'punch'),
          _buildPopupMenuItem(
              Icons.password_outlined, 'Change Password', 'changePassword'),
          const PopupMenuDivider(),
          _buildPopupMenuItem(Icons.logout_outlined, 'Logout', 'logout',
              isLogout: true),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      IconData icon, String text, String value,
      {bool isLogout = false}) {
    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isLogout ? Colors.red[600] : const Color(0xFF6B2C91),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.red[600] : const Color(0xFF2A0A3D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuContent(String greeting) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildGreetingSection(greeting),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          const Text(
            'Main Menu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2A0A3D),
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuGrid(),
          const SizedBox(height: 32), // Más padding bottom para mejor scroll
        ],
      ),
    );
  }

  Widget _buildGreetingSection(String greeting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting !',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2A0A3D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What would you like to do today?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6B2C91).withOpacity(0.12),
            const Color(0xFF4C1A57).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6B2C91).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B2C91).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6B2C91).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.access_time_outlined,
              color: Color(0xFF6B2C91),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Check-in',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2A0A3D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to punch in/out quickly',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/punch'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B2C91), Color(0xFF4C1A57)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B2C91).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Punch In',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      MenuItemData(
          Icons.calendar_today_outlined,
          'See Calendar',
          'View your absences and schedule',
          '/calendar',
          const Color(0xFF4CAF50)),
      MenuItemData(Icons.person_outline, 'Profile', 'Manage your personal info',
          '/profile', const Color(0xFF2196F3)),
      MenuItemData(
          Icons.email_outlined,
          'Request Absence',
          'Submit vacation requests',
          '/request-absence',
          const Color(0xFFFF9800)),
      MenuItemData(Icons.qr_code_scanner_outlined, 'Punch In',
          'Scan QR to clock in/out', '/punch', const Color(0xFF9C27B0)),
    ];

    // Usamos un Column con Wrap en lugar de GridView para mejor control del espacio
    return Column(
      children: [
        for (int i = 0; i < menuItems.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 600 + (i * 150)),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: _buildModernMenuCard(menuItems[i]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < menuItems.length
                      ? TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration:
                              Duration(milliseconds: 600 + ((i + 1) * 150)),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: _buildModernMenuCard(menuItems[i + 1]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildModernMenuCard(MenuItemData item) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, item.route),
      child: Container(
        height: 200, // Altura más compacta
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: item.color.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      item.color.withOpacity(0.15),
                      item.color.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  size: 26,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2A0A3D),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String title;
  final String description;
  final String route;
  final Color color;

  MenuItemData(this.icon, this.title, this.description, this.route, this.color);
}
