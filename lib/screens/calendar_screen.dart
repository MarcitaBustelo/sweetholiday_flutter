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

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  late Map<String, dynamic> holidayData;
  bool isLoading = true;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> allEvents = {};
  Color markerColor = Colors.pinkAccent;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime.now();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    fetchHolidayData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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

    try {
      final response = await http.get(
        Uri.parse(
            'https://sweetholidays-production-f2f2.up.railway.app/api/user/holidays'),
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
              'start_date': startDate.toIso8601String(),
              'end_date': endDate.toIso8601String(),
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

        _fadeController.forward();
        _slideController.forward();
      } else {
        throw Exception('Error fetching holiday data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading calendar data: ${e.toString()}'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final cleanDay = DateTime(day.year, day.month, day.day);
    return allEvents[cleanDay] ?? [];
  }

  // Función para obtener el color principal de un día (para el marcador)
  Color? _getPrimaryColorForDay(DateTime day) {
    final events = _getEventsForDay(day);
    if (events.isEmpty) return null;
    
    // Priorizar absence sobre festive
    for (var event in events) {
      if (event['type'] == 'absence' && event['color'] != null) {
        return _hexToColor(event['color']);
      }
    }
    
    // Si solo hay festives
    for (var event in events) {
      if (event['type'] == 'festive') {
        return const Color(0xFFED8936);
      }
    }
    
    return const Color(0xFF667EEA); // Color por defecto
  }

  // Builder personalizado para los marcadores
  Widget _buildEventMarker(DateTime day, List<dynamic> events) {
    if (events.isEmpty) return const SizedBox.shrink();
    
    final primaryColor = _getPrimaryColorForDay(day);
    if (primaryColor == null) return const SizedBox.shrink();
    
    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.5),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D3748),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Color(0xFF667EEA), size: 20),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MenuScreen(name: 'Menu')),
                  );
                },
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "My Calendar",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),

          // Loading or Content
          isLoading
              ? const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Loading your calendar...",
                          style: TextStyle(
                            color: Color(0xFF718096),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        // Modern Calendar Card
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: TableCalendar(
                                  firstDay: DateTime.utc(2020, 1, 1),
                                  lastDay: DateTime.utc(2030, 12, 31),
                                  focusedDay: focusedDay,
                                  selectedDayPredicate: (day) {
                                    return isSameDay(selectedDay, day);
                                  },
                                  calendarFormat: CalendarFormat.month,
                                  startingDayOfWeek: StartingDayOfWeek.monday,
                                  onDaySelected: (selected, focused) {
                                    setState(() {
                                      selectedDay = selected;
                                      focusedDay = focused;
                                    });
                                  },
                                  onPageChanged: (focusedDay) {
                                    setState(() {
                                      this.focusedDay = focusedDay;
                                    });
                                  },
                                  calendarStyle: CalendarStyle(
                                    // Today styling
                                    todayDecoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF667EEA),
                                          Color(0xFF764BA2)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF667EEA)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    todayTextStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),

                                    // Selected day styling
                                    selectedDecoration: BoxDecoration(
                                      color: const Color(0xFF4FD1C7),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4FD1C7)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    selectedTextStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),

                                    // Weekend styling
                                    weekendTextStyle: const TextStyle(
                                      color: Color(0xFFE53E3E),
                                      fontWeight: FontWeight.w500,
                                    ),

                                    // Default text styling
                                    defaultTextStyle: const TextStyle(
                                      color: Color(0xFF2D3748),
                                      fontWeight: FontWeight.w500,
                                    ),

                                    // Outside days
                                    outsideTextStyle: TextStyle(
                                      color: const Color(0xFF718096)
                                          .withOpacity(0.6),
                                      fontWeight: FontWeight.w400,
                                    ),

                                    // REMOVEMOS las propiedades de marker por defecto
                                    markersMaxCount: 0, // Importante: desactivar marcadores por defecto
                                  ),
                                  headerStyle: HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                    leftChevronIcon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF667EEA)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.chevron_left,
                                        color: Color(0xFF667EEA),
                                        size: 20,
                                      ),
                                    ),
                                    rightChevronIcon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF667EEA)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.chevron_right,
                                        color: Color(0xFF667EEA),
                                        size: 20,
                                      ),
                                    ),
                                    titleTextStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2D3748),
                                    ),
                                    headerPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  daysOfWeekStyle: const DaysOfWeekStyle(
                                    weekdayStyle: TextStyle(
                                      color: Color(0xFF718096),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    weekendStyle: TextStyle(
                                      color: Color(0xFFE53E3E),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  eventLoader: _getEventsForDay,
                                  // AGREGAR calendarBuilders para marcadores personalizados
                                  calendarBuilders: CalendarBuilders(
                                    markerBuilder: (context, day, events) {
                                      return _buildEventMarker(day, events);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Events Section
                        _buildEventsSection(),

                        const SizedBox(height: 24),

                        // Legend Section
                        _buildModernLegend(),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    final selectedEvents =
        selectedDay != null ? _getEventsForDay(selectedDay!) : [];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4FD1C7), Color(0xFF38B2AC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.event_note,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Events for Selected Day",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        if (selectedDay != null)
                          Text(
                            "${selectedDay!.day}/${selectedDay!.month}/${selectedDay!.year}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF718096),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${selectedEvents.length}",
                      style: const TextStyle(
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (selectedEvents.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "No events scheduled",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...selectedEvents.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                final isLast = index == selectedEvents.length - 1;

                return _buildModernEventCard(event, isLast);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernEventCard(Map<String, dynamic> event, bool isLast) {
    final isAbsence = event['type'] == 'absence';
    final label = event['label'];
    final color = isAbsence && event['color'] != null
        ? _hexToColor(event['color'])
        : (isAbsence ? const Color(0xFF667EEA) : const Color(0xFFED8936));

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, isLast ? 20 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isAbsence ? Icons.beach_access : Icons.celebration,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label, // Solo mostrar el tipo/label, sin fechas
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isAbsence ? "Absence" : "Holiday",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLegend() {
    final uniqueTypes = _getUniqueTypes();

    if (uniqueTypes.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFED8936), Color(0xFFDD6B20)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.legend_toggle,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Legend",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: uniqueTypes.entries.map((entry) {
                  return _buildModernLegendItem(entry.value, entry.key);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernLegendItem(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3748),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getUniqueTypes() {
    Map<String, Color> types = {};
    bool hasFestives = false;

    allEvents.values.forEach((eventList) {
      for (var event in eventList) {
        if (event['type'] == 'absence') {
          final typeLabel = event['label'] ?? 'Absence';
          final colorStr = event['color'] ?? '#667EEA';
          types[typeLabel] = _hexToColor(colorStr);
        } else if (event['type'] == 'festive') {
          hasFestives = true;
        }
      }
    });

    if (hasFestives) {
      types['Festives'] = const Color(0xFFED8936);
    }

    return types;
  }
}