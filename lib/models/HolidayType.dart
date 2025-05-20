class HolidayType {
  final int id;
  final String type;
  final String? color;

  HolidayType({
    required this.id,
    required this.type,
    this.color,
  });

  factory HolidayType.fromJson(Map<String, dynamic> json) => HolidayType(
        id: json['id'],
        type: json['type'],
        color: json['color'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'color': color,
      };
}
