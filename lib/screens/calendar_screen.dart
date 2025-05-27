import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<String, dynamic> holidayData;
  bool isLoading = true;
  DateTime focusedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> allEvents = {};
  Color markerColor = Colors.pinkAccent;

  @override
  void initState() {
    super.initState();
    fetchHolidayData();
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> fetchHolidayData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('Token no encontrado');

    final response = await http.get(
      Uri.parse('https://sweetholidays-production-f2f2.up.railway.app/api/user/holidays'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final holidays = List<Map<String, dynamic>>.from(data['holidays']);
      final festives = List<Map<String, dynamic>>.from(data['festives']);

      Map<DateTime, List<Map<String, dynamic>>> events = {};

      for (var holiday in holidays) {
        DateTime startDate = DateTime.parse(holiday['start_date']);
        DateTime endDate = DateTime.parse(holiday['end_date']);
        String label = holiday['holiday_type']['type'];
        String? color = holiday['holiday_type']['color'];

        for (DateTime date = startDate;
            !date.isAfter(endDate);
            date = date.add(const Duration(days: 1))) {
          DateTime cleanDate = DateTime(date.year, date.month, date.day);
          events.putIfAbsent(cleanDate, () => []);
          events[cleanDate]!.add({
            'type': 'absence',
            'label': label,
            'color': color,
          });
        }
      }

      for (var fest in festives) {
        DateTime date = DateTime.parse(fest['date']);
        DateTime cleanDate = DateTime(date.year, date.month, date.day);
        events.putIfAbsent(cleanDate, () => []);
        events[cleanDate]!.add({
          'type': 'festive',
          'label': fest['name'],
        });
      }

      setState(() {
        holidayData = data;
        allEvents = events;
        isLoading = false;
      });
    } else {
      throw Exception('Error fetching holiday data');
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final cleanDay = DateTime(day.year, day.month, day.day);
    return allEvents[cleanDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌄 Fondo con imagen y capa blanca encima
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.85),
          ),
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        // 🔙 Botón de volver
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Color(0xFF5C1E8A)),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MenuScreen(name: 'Menu')),
                              );
                            },
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.calendar_month,
                                color: Color(0xFF5C1E8A)),
                            SizedBox(width: 8),
                            Text(
                              "My Calendar",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C1E8A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TableCalendar(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: focusedDay,
                              calendarFormat: CalendarFormat.month,
                              onDaySelected: (selectedDay, newFocus) {
                                setState(() {
                                  focusedDay = newFocus;
                                });
                              },
                              calendarStyle: CalendarStyle(
                                todayDecoration: const BoxDecoration(
                                  color: Color(0xFF5C1E8A),
                                  shape: BoxShape.circle,
                                ),
                                markerDecoration: BoxDecoration(
                                  color: _getEventsForDay(focusedDay).isNotEmpty
                                      ? _hexToColor(_getEventsForDay(focusedDay)
                                              .first['color'] ??
                                          '#FF69B4')
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              eventLoader: _getEventsForDay,
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                titleTextStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5C1E8A)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _getEventsForDay(focusedDay).isEmpty
                              ? const Center(
                                  child: Text("No events that day"),
                                )
                              : ListView.builder(
                                  itemCount:
                                      _getEventsForDay(focusedDay).length,
                                  itemBuilder: (context, index) {
                                    final event =
                                        _getEventsForDay(focusedDay)[index];
                                    final isAbsence =
                                        event['type'] == 'absence';
                                    final label = event['label'];
                                    final color = isAbsence &&
                                            event['color'] != null
                                        ? _hexToColor(event['color'])
                                        : (isAbsence
                                            ? Colors.deepPurple
                                            : Colors.orange);

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: color,
                                          child: Icon(
                                            isAbsence
                                                ? Icons.beach_access
                                                : Icons.flag,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text(
                                          label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 12),
                        _buildLegend(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Leyend:",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5C1E8A)),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          children: [
            _legendItem(const Color.fromARGB(255, 252, 9, 187), "Festive"),
            _legendItem(const Color.fromARGB(255, 167, 13, 85), "Absence"),
            _legendItem(_hexToColor('#c4ca42'), "Vacation"),
          ],
        )
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Text(label),
      ],
    );
  }
}
