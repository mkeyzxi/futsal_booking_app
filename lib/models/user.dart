// lib/models/user.dart
enum UserRole { admin, user }

class User {
  final String id;
  final String username;
  final String email;
  final String? profileImageUrl;
  final UserRole role;
  double balance; // <--- TAMBAHKAN INI (tidak final agar bisa diubah)

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageUrl,
    this.role = UserRole.user,
    this.balance = 0.0, // <--- Beri nilai default
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'role': role.toString().split('.').last,
      'balance': balance, // <--- Tambahkan ke JSON
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.user,
      ),
      balance:
          (json['balance'] as num?)?.toDouble() ?? 0.0, // <--- Baca dari JSON
    );
  }
}
