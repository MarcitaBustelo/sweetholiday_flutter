class UserProfile {
  final int id;
  final String name;
  final String employeeId;
  final String delegation;
  final String department;
  final int totalDays;
  final int remainingDays;
  final int vacationDaysUsed;
  final int absenceDaysUsed;
  final int totalDaysUsed;
  final List<Holiday> upcomingHolidays;

  UserProfile({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.delegation,
    required this.department,
    required this.totalDays,
    required this.remainingDays,
    required this.vacationDaysUsed,
    required this.absenceDaysUsed,
    required this.totalDaysUsed,
    required this.upcomingHolidays,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final user = json['data']['user'];
    final holidays = json['data']['upcoming_holidays'] as List;

    return UserProfile(
      id: user['id'],
      name: user['name'],
      employeeId: user['employee_id'],
      delegation: user['delegation'],
      department: user['department'],
      totalDays: user['total_days'],
      remainingDays: user['remaining_days'],
      vacationDaysUsed: json['data']['vacation_days_used'],
      absenceDaysUsed: json['data']['absence_days_used'],
      totalDaysUsed: json['data']['vacation_days_used'],
      upcomingHolidays: holidays.map((h) => Holiday.fromJson(h)).toList(),
    );
  }
}

class Holiday {
  final int id;
  final String startDate;
  final String endDate;
  final int holidayId;

  Holiday({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.holidayId,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      holidayId: json['holiday_id'],
    );
  }
}
