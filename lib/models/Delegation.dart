class Delegation {
  final int id;
  final String name;
  final int delegationId;

  Delegation({
    required this.id,
    required this.name,
    required this.delegationId,
  });

  factory Delegation.fromJson(Map<String, dynamic> json) => Delegation(
        id: json['id'],
        name: json['name'],
        delegationId: json['department_id'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'department_id': delegationId,
      };
}
