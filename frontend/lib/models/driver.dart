class Driver {
  final int id;
  final String name;
  final String licenseNumber;
  final String phone;
  final String email;
  final String status;
  final DateTime createdAt;

  Driver({
    required this.id,
    required this.name,
    required this.licenseNumber,
    required this.phone,
    required this.email,
    required this.status,
    required this.createdAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      licenseNumber: json['license_number'],
      phone: json['phone'],
      email: json['email'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'license_number': licenseNumber,
      'phone': phone,
      'email': email,
      'status': status,
    };
  }
}