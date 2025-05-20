class Arrival {
  final int id;
  final String employeeId;
  final DateTime date;
  final String arrivalTime;
  final String? departureTime;
  final bool late;

  Arrival({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.arrivalTime,
    this.departureTime,
    required this.late,
  });

  factory Arrival.fromJson(Map<String, dynamic> json) => Arrival(
        id: json['id'],
        employeeId: json['employee_id'],
        date: DateTime.parse(json['date']),
        arrivalTime: json['arrival_time'],
        departureTime: json['departure_time'],
        late: json['late'] == true || json['late'] == 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee_id': employeeId,
        'date': date.toIso8601String(),
        'arrival_time': arrivalTime,
        'departure_time': departureTime,
        'late': late,
      };
}
