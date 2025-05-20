import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/menu_screen.dart';
// import 'screens/calendar_screen.dart';
// import 'screens/profile_screen.dart';
// import 'screens/request_absence_screen.dart';
// import 'screens/punch_in_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sweet Holidays',
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/menu':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => MenuScreen(name: args['name']),
            );
          // case '/calendar':
          //   return MaterialPageRoute(builder: (_) => const CalendarScreen());
          // case '/profile':
          //   return MaterialPageRoute(builder: (_) => const ProfileScreen());
          // case '/request-absence':
          //   return MaterialPageRoute(
          //       builder: (_) => const RequestAbsenceScreen());
          // case '/punch':
          //   return MaterialPageRoute(builder: (_) => const PunchInScreen());
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
