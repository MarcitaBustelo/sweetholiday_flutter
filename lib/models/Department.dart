class Department {
  final int id;
  final String name;
  final int departmentId;

  Department({
    required this.id,
    required this.name,
    required this.departmentId,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        id: json['id'],
        name: json['name'],
        departmentId: json['department_id'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'department_id': departmentId,
      };
}
