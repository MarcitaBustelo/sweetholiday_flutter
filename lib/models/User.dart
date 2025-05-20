class User {
  final int id;
  final String name;
  final String email;
  final String nif;
  final String role;
  final String phone;
  final String employeeId;
  final int? departmentId;
  final int? delegationId;
  final String? responsable;
  final int days;
  final int daysInTotal;
  final bool active;
  final String? startDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.nif,
    required this.role,
    required this.phone,
    required this.employeeId,
    this.departmentId,
    this.delegationId,
    this.responsable,
    required this.days,
    required this.daysInTotal,
    required this.active,
    this.startDate,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        nif: json['NIF'],
        role: json['role'] ?? '',
        phone: json['phone'] ?? '',
        employeeId: json['employee_id'],
        departmentId: json['department_id'],
        delegationId: json['delegation_id'],
        responsable: json['responsable'],
        days: json['days'],
        daysInTotal: json['days_in_total'],
        active: json['active'] == 1 || json['active'] == true,
        startDate: json['start_date'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'NIF': nif,
        'role': role,
        'phone': phone,
        'employee_id': employeeId,
        'department_id': departmentId,
        'delegation_id': delegationId,
        'responsable': responsable,
        'days': days,
        'days_in_total': daysInTotal,
        'active': active,
        'start_date': startDate,
      };
}
