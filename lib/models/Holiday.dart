class Holiday {
  final int id;
  final int employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final int holidayId;
  final String? comment;
  final String? file;

  Holiday({
    required this.id,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.holidayId,
    this.comment,
    this.file,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) => Holiday(
        id: json['id'],
        employeeId: json['employee_id'],
        startDate: DateTime.parse(json['start_date']),
        endDate: DateTime.parse(json['end_date']),
        holidayId: json['holiday_id'],
        comment: json['comment'],
        file: json['file'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee_id': employeeId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'holiday_id': holidayId,
        'comment': comment,
        'file': file,
      };
}
