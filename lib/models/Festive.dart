class Festive {
  final int id;
  final String name;
  final DateTime date;
  final int? delegationId;
  final bool national;

  Festive({
    required this.id,
    required this.name,
    required this.date,
    this.delegationId,
    required this.national,
  });

  factory Festive.fromJson(Map<String, dynamic> json) => Festive(
        id: json['id'],
        name: json['name'],
        date: DateTime.parse(json['date']),
        delegationId: json['delegation_id'],
        national: json['national'] == true || json['national'] == 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'delegation_id': delegationId,
        'national': national,
      };
}
