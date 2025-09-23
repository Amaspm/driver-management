class User {
  final String token;
  final int userId;
  final String username;
  final String? email;
  final String role;
  final Map<String, dynamic>? driver;
  final Map<String, dynamic>? profile;

  User({
    required this.token,
    required this.userId,
    required this.username,
    this.email,
    required this.role,
    this.driver,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'] ?? '',
      userId: json['user_id'] ?? json['driver_id'] ?? 0,
      username: json['username'] ?? json['email'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'driver',
      driver: json['driver'],
      profile: json['profile'],
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isDriver => role == 'driver';
  
  String get displayName => profile?['nama'] ?? username;
  String? get profilePhoto => profile?['foto_profil'];
  String? get city => profile?['kota'];
  String? get phone => profile?['no_hp'];
  String get status => profile?['status'] ?? 'unknown';
}