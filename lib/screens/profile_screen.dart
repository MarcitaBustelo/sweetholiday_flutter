import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Imagen de fondo decorativa
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo.png'), // ⚠️ Asegúrate que esta imagen exista
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Capa blanca con opacidad (degradado)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.85)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          FutureBuilder<UserProfile>(
            future: UserService().fetchUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('❌ Error al cargar perfil'));
              }

              final profile = snapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta de usuario
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 6,
                      shadowColor: Colors.black26,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(profile.name,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('ID: ${profile.employeeId}'),
                                  Text('Delegación: ${profile.delegation}'),
                                  Text('Departamento: ${profile.department}'),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Estadísticas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDaysStat('Usados', profile.totalDaysUsed, Colors.orange, Icons.timer_outlined),
                        _buildDaysStat('Restantes', profile.remainingDays, Colors.green, Icons.check_circle_outline),
                        _buildDaysStat('Totales', profile.totalDays, Colors.blue, Icons.calendar_today_outlined),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Lista de ausencias
                    const Text('📅 Próximas ausencias',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 12),

                    if (profile.upcomingHolidays.isEmpty)
                      const Text('No hay ausencias programadas',
                          style: TextStyle(color: Colors.grey)),
                    ...profile.upcomingHolidays.map((h) => Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: ListTile(
                            leading: const Icon(Icons.event_busy, color: Colors.redAccent),
                            title: Text('${h.startDate} → ${h.endDate}'),
                            subtitle: Text('Ausencia programada'),
                          ),
                        )),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaysStat(String title, int value, Color color, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        Text(title, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}
